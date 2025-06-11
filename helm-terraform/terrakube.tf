resource "helm_release" "terrakube" {
  name             = "terrakube"
  namespace        = "terrakube"
  create_namespace = true

  repository = "https://AzBuilder.github.io/terrakube-helm-chart"
  chart      = "terrakube"

  values = [file("${path.module}/terrakube-values-new.yaml")] # Reference the values file

  version = "3.24.0" 
}