resource "aws_iam_policy" "external_dns" {
  name        = "externalDNS-policy"
  description = "Policy for ExternalDNS to manage Route 53 records"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = "route53:ChangeResourceRecordSets"
        Resource = "arn:aws:route53:::hostedzone/Z03363812U8ONWBTLW4I4"
      },
      {
        Sid    = "VisualEditor1"
        Effect = "Allow"
        Action = [
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ]
        Resource = "arn:aws:route53:::hostedzone/Z03363812U8ONWBTLW4I4"
      },
      {
        Sid    = "VisualEditor2"
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones"
        ]
        Resource = "*"
      }
    ]
  })
}


# Create the IAM service account in the specified EKS cluster and namespace.
resource "aws_eks_service_account" "external_dns" {
  cluster_name = var.cluster_name # cluster name
  namespace    = "default"
  name         = "external-dns"

  # Attach the policy to the service account.
  # Note:  The aws_iam_policy_attachment resource handles the association.
}

resource "aws_iam_policy_attachment" "external_dns_policy_attachment" {
  name       = "external-dns-policy-attachment"
  policy_arn = aws_iam_policy.external_dns_policy.arn
  roles      = [aws_eks_service_account.external_dns.role_arn] # Important: Use the role_arn from the service account resource.
}

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "pods", "nodes"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns" {
  metadata {
    name = "external-dns-viewer"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns.metadata[0].name # Reference the ClusterRole
  }
  subject {
    kind      = "ServiceAccount"
    name      = aws_eks_service_account.external_dns.name # Reference the ServiceAccount
    namespace = aws_eks_service_account.external_dns.namespace # Reference the ServiceAccount namespace
  }
}

resource "kubernetes_deployment" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }

  spec {
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "external-dns"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "external-dns"
        }
      }

      spec {
        service_account_name = aws_eks_service_account.external_dns.name # Reference the ServiceAccount

        container {
          name  = "external-dns"
          image = "registry.k8s.io/external-dns/external-dns:v0.14.0"

          args = [
            "--source=service",
            "--source=ingress",
            "--domain-filter=richolaniyan.com",
            "--provider=aws",
            "--aws-zone-type=public",
            "--registry=txt",
            "--txt-owner-id=external-dns"
          ]

          env {
            name  = "AWS_DEFAULT_REGION"
            value = "us-east-1"
          }
        }

        security_context {
          fs_group = 65534
        }
      }
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding.external_dns_viewer, # Ensure binding exists first
    aws_iam_policy_attachment.external_dns_policy_attachment # Ensure IAM role is attached
  ]
}

