resource "kubernetes_config_map" "datasources" {
  metadata {
    name = "datasource"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
  }

  data = {
    "all.yml" = yamlencode({
      datasources = [
        {
          access = "proxy"
          editable = false
          is_default = true
          name = "Prometheus"
          org_id = 1
          type = "prometheus"
          url = "http://${kubernetes_service.prometheus.metadata[0].name}.statistics:9090"
          version = 1
        },
	{
          access = "proxy"
          editable = false
          is_default = false
          name = "Logs"
          type = "loki"
          url = "http://${helm_release.loki-stack.name}:3100"
          version = 1
        }
      ]
    })
  }
}


resource "kubernetes_config_map" "dashboard_config" {
  metadata {
    name = "dashboard-config"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
  }
  data = {
    "all.yml" = yamlencode([{
      name = "default"
      ord_id = 1,
      folder = "",
      type = "file"
      options: {
        folder = "/var/lib/grafana/dashboards"
      }
    }])
  }
}

resource "kubernetes_config_map" "default_dashboard" {
  metadata {
    name = "dashboard"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
  }
  data = {
    "node-dashboard.json" = file("${path.module}/node_dashboard.json")
    "kubernetes-dashboard.json" = file("${path.module}/kubernetes_dashboard.json")
    "stats_dashboard.json" = file("${path.module}/stats_dashboard.json")
  }
}

resource "kubernetes_config_map" "renderer" {
  metadata {
    name = "renderer"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
  }
  data = {
    "config.json" = file("${path.module}/renderer-config.json")
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name = "grafana"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
    labels = {
      app = "grafana"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "grafana"
      }
    }
    template {
      metadata {
        name = "grafana"
        #namespace = kubernetes_namespace.stats.metadata[0].name
        namespace = "statistics"
        labels = {
          app = "grafana"
        }
      }
      spec {
        container {
          name  = "renderer"
          image = "grafana/grafana-image-renderer:3.5.0"

          port {
            container_port = 8081
          }

          volume_mount {
            mount_path    = "/usr/src/app/config.json"
            name          = "renderer-config"
            sub_path      = "config.json"
          }
        }
        container {
          name = "grafana"
          image = "grafana/grafana:7.5.10"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "GF_RENDERING_SERVER_URL"
            value = "http://renderer:8081/render"
          }

          env {
            name  = "GF_RENDERING_CALLBACK_URL"
            value = "http://grafana:3000/"
          }

          env {
            name  = "GF_LOG_FILTERS"
            value = "rendering:debug"
          }

          volume_mount {
            mount_path = "/etc/grafana/provisioning/datasources"
            name = "datasource"
          }
          volume_mount {
            mount_path = "/etc/grafana/provisioning/dashboards"
            name = "config"
          }
          volume_mount {
            mount_path = "/var/lib/grafana/dashboards"
            name = "dashboard"
          }
          port {
            container_port = 3000
          }
        }
        volume {
          name = "renderer-config"
          config_map {
            name = kubernetes_config_map.renderer.metadata[0].name
          }
        }
        volume {
          name = "datasource"
          config_map {
            name = kubernetes_config_map.datasources.metadata[0].name
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.dashboard_config.metadata[0].name
          }
        }
        volume {
          name = "dashboard"
          config_map {
            name = kubernetes_config_map.default_dashboard.metadata[0].name
          }
        }
      }
    }
  }
}



resource "kubernetes_service" "grafana" {
  depends_on = [kubernetes_deployment.prometheus]
  metadata {
    name = "grafana"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
    labels = {
      app = "grafana"
    }
  }
  spec {
    selector = {
      app = "grafana"
    }
    external_name = "grafana"
    port {
      name = "grafana"
      port = 3000
      target_port = 3000
    }
  }
}



resource "kubernetes_ingress" "grafana" {
  wait_for_load_balancer = true
  depends_on = [
    kubernetes_service.grafana
  ]
  metadata {
    name = "grafana-ingress"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "nginx.ingress.kubernetes.io/rewrite-target": "/$1"
      "nginx.ingress.kubernetes.io/ssl-redirect": "false"
    }
  }
  spec {
    rule {
      host = var.stat_domain
      http {
        path {
          path = "/(.*)"
          backend {
            service_name = kubernetes_service.grafana.metadata[0].name
            service_port = 3000
          }
        }
      }
    }
  }
}
