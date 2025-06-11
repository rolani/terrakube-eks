# Define the Helm release for cert-manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"

  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }
}


# Define the IAM policy for cert-manager
resource "aws_iam_policy" "cert_manager_acme_dns01_route53" {
  name        = "cert-manager-acme-dns01-route53"
  description = "This policy allows cert-manager to manage ACME DNS01 records in Route53 hosted zones. See https://cert-manager.io/docs/configuration/acme/dns01/route53"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "route53:GetChange"
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
        ]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect   = "Allow"
        Action   = "route53:ListHostedZonesByName"
        Resource = "*"
      },
    ]
  })
}

# Get the AWS account ID 
data "aws_caller_identity" "current" {}


# Create the IAM service account in the cert-manager namespace
resource "aws_eks_service_account" "cert_manager_acme_dns01_route53" {
  cluster_name = var.cluster_name # cluster name
  namespace    = "cert-manager"
  name         = "cert-manager-acme-dns01-route53" # The service account name

}

# Attach the policy to the service account's role
resource "aws_iam_policy_attachment" "cert_manager_acme_dns01_route53_attachment" {
  name       = "cert-manager-acme-dns01-route53-attachment"
  policy_arn = aws_iam_policy.cert_manager_acme_dns01_route53.arn
  roles      = [aws_eks_service_account.cert_manager_acme_dns01_route53.role_arn]
}

# Role for token request
resource "kubernetes_role" "cert_manager_acme_dns01_route53_tokenrequest" {
  metadata {
    name      = "cert-manager-acme-dns01-route53-tokenrequest"
    namespace = "cert-manager"
  }
  rule {
    api_groups    = [""]
    resources     = ["serviceaccounts/token"]
    resource_names = [aws_eks_service_account.cert_manager_acme_dns01_route53.name] # Reference the service account name
    verbs         = ["create"]
  }
}

# RoleBinding for token request
resource "kubernetes_role_binding" "cert_manager_acme_dns01_route53_tokenrequest" {
  metadata {
    name      = "cert-manager-acme-dns01-route53-tokenrequest"
    namespace = "cert-manager"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager" # The cert-manager service account
    namespace = "cert-manager"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cert_manager_acme_dns01_route53_tokenrequest.metadata[0].name # Reference the Role
  }
}

# ClusterIssuer
resource "kubernetes_manifest" "letsencrypt_production_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-production"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "ofreshng@gmail.com" # Your email address
        privateKeySecretRef = {
          name = "letsencrypt-staging" # Or a more appropriate name
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region = "us-east-1" # Your region
                role   = aws_eks_service_account.cert_manager_acme_dns01_route53.role_arn # Use the output from the service account resource
                auth = {
                  kubernetes = {
                    serviceAccountRef = {
                      name = aws_eks_service_account.cert_manager_acme_dns01_route53.name # Reference the service account
                    }
                  }
                }
              }
            }
          },
        ]
      }
    }
  }
  depends_on = [
    aws_iam_policy_attachment.cert_manager_acme_dns01_route53_attachment,
    kubernetes_role_binding.cert_manager_acme_dns01_route53_tokenrequest
  ]
}

# Certificate
resource "kubernetes_manifest" "terrakube_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name = "terrakube"
    }
    spec = {
      secretName = "www-richolaniyan"
      dnsNames = [
        "*.richolaniyan.com",
        "richolaniyan.com",
      ]
      usages = [
        "digital signature",
        "key encipherment",
        "server auth",
      ]
      issuerRef = {
        name = "letsencrypt-production"
        kind = "ClusterIssuer"
      }
    }
  }
  depends_on = [
    kubernetes_manifest.letsencrypt_production_cluster_issuer
  ]
}

