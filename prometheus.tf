
resource "kubernetes_config_map" "prometheus" {
  metadata {
    name = "prometheus"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
  }
  data = {
    "config.yaml" = file("${path.module}/config.yaml")
  }
}

/*
resource "kubernetes_persistent_volume_claim" "prometheus" {
  metadata {
    name = "prometheus"
    namespace = kubernetes_namespace.stats.metadata[0].name
  }
  spec {
    access_modes = [
      "ReadWriteOnce"
    ]
    resources {
      requests = {
        storage = "8Gi"
      }
    }
  }
}
*/

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name = "prometheus"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
    labels = {
      app = "prometheus"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "prometheus"
      }
    }
    template {
      metadata {
        name = "prometheus"
        #namespace = kubernetes_namespace.stats.metadata[0].name
        namespace = "statistics"
        labels = {
          app = "prometheus"
        }
      }
      spec {
        container {
          name = "prometheus"
          image = "prom/prometheus:v2.28.1"
          image_pull_policy = "IfNotPresent"

          volume_mount {
            mount_path = "/etc/prometheus"
            name = "configs"
          }
          volume_mount {
            mount_path = "/prometheus"
            name = "data"
          }
          args = [
            "--config.file=/etc/prometheus/config.yaml",
            "--storage.tsdb.path=/prometheus",
            "--storage.tsdb.retention.time=90d",
            "--web.console.libraries=/usr/share/prometheus/console_libraries",
            "--web.console.templates=/usr/share/prometheus/consoles"
          ]
          port {
            container_port = 9090
          }
        }
        volume {
          name = "configs"
          config_map {
            name = kubernetes_config_map.prometheus.metadata[0].name
          }
        }
        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "prometheus"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prometheus" {
  depends_on = [kubernetes_deployment.prometheus]
  metadata {
    name = "prometheus"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
    labels = {
      app = "prometheus"
    }
  }
  spec {
    selector = {
      app = "prometheus"
    }
    external_name = "prometheus"
    port {
      name = "prometheus"
      port = 9090
      target_port = 9090
    }
  }
}
