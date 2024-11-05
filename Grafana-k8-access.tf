
variable "namespace" {
  type    = string
  default = "default"
}

variable "cluster_name" {
  type    = string
  default = "my-cluster"
}

variable "externalservices_prometheus_host" {
  type    = string
  default = "https://prometheus-prod-36-prod-us-west-0.grafana.net"
}

variable "externalservices_prometheus_basicauth_username" {
  type    = number
  default = 1779411
}

variable "externalservices_prometheus_basicauth_password" {
  type    = string
  default = "REPLACE_WITH_ACCESS_POLICY_TOKEN"
}

variable "externalservices_loki_host" {
  type    = string
  default = "https://logs-prod-021.grafana.net"
}

variable "externalservices_loki_basicauth_username" {
  type    = number
  default = 988992
}

variable "externalservices_loki_basicauth_password" {
  type    = string
  default = "REPLACE_WITH_ACCESS_POLICY_TOKEN"
}

variable "externalservices_tempo_host" {
  type    = string
  default = "https://tempo-prod-15-prod-us-west-0.grafana.net:443"
}

variable "externalservices_tempo_basicauth_username" {
  type    = number
  default = 983307
}

variable "externalservices_tempo_basicauth_password" {
  type    = string
  default = "REPLACE_WITH_ACCESS_POLICY_TOKEN"
}

resource "helm_release" "grafana-k8s-monitoring" {
  name             = "grafana-k8s-monitoring"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "k8s-monitoring"
  namespace        = var.namespace
  create_namespace = true
  atomic           = true
  timeout          = 300

  values = [file("${path.module}/values/values.yaml")]

  set {
    name  = "cluster.name"
    value = var.cluster_name
  }

  set {
    name  = "externalServices.prometheus.host"
    value = var.externalservices_prometheus_host
  }

  set_sensitive {
    name  = "externalServices.prometheus.basicAuth.username"
    value = var.externalservices_prometheus_basicauth_username
  }

  set_sensitive {
    name  = "externalServices.prometheus.basicAuth.password"
    value = var.externalservices_prometheus_basicauth_password
  }

  set {
    name  = "externalServices.loki.host"
    value = var.externalservices_loki_host
  }

  set_sensitive {
    name  = "externalServices.loki.basicAuth.username"
    value = var.externalservices_loki_basicauth_username
  }

  set_sensitive {
    name  = "externalServices.loki.basicAuth.password"
    value = var.externalservices_loki_basicauth_password
  }

  set {
    name  = "externalServices.tempo.host"
    value = var.externalservices_tempo_host
  }

  set_sensitive {
    name  = "externalServices.tempo.basicAuth.username"
    value = var.externalservices_tempo_basicauth_username
  }

  set_sensitive {
    name  = "externalServices.tempo.basicAuth.password"
    value = var.externalservices_tempo_basicauth_password
  }

  set {
    name  = "opencost.opencost.exporter.defaultClusterId"
    value = var.cluster_name
  }

  set {
    name  = "opencost.opencost.prometheus.external.url"
    value = format("%s/api/prom", var.externalservices_prometheus_host)
  }
}