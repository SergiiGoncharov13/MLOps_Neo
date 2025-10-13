resource "kubernetes_namespace" "infra_tools" {
  metadata {
    name = "infra-tools"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "infra-tools"
  version    = "5.51.6"

  create_namespace = true
  timeout          = 600

  values = [file("${path.module}/values/argocd-values.yaml")]
}
