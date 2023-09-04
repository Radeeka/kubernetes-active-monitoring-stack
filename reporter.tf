resource "kubernetes_cron_job" "grafana_stats" {
  metadata {
    name      = "grafana-stats"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
  }

  spec {
    schedule = "*/5 * * * *"

    job_template {
      metadata {
        name = "grafana-stats"
      }
      spec {
        template {
          metadata {
            name = "grafana-stats"
          }
          spec {
            image_pull_secrets {
              name = kubernetes_secret.gitlab_registry.metadata[0].name
            }

            container {
              name  = "grafana-stats"
              image = "${var.image_prefix}/grafana_stats_reporter:latest"
              env {
                name  = "dashboard_uid"
                value = var.dashboard_uid
              }
              env {
                name  = "out_file"
                value = var.out_file
              }
              env {
                name  = "mail_subject"
                value = var.mail_subject
              }
              env {
                name  = "mail_body"
                value = var.mail_body
              }
              env {
                name  = "pod_ip"
                value = kubernetes_service.grafana.metadata[0].name
              }
              volume_mount {
                mount_path = "/app/email.txt"
                name       = "email-config"
                sub_path   = "email.txt"
              }
            }
            restart_policy = "OnFailure"

            volume {
              config_map {
                name = kubernetes_config_map.email-configmap.metadata[0].name
              }
              name = "email-config"
            }

          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "gitlab_registry" {
  metadata {
    name = "gitlab-registry"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths": {
        "registry.gitlab.com": {
          "username": var.gitlab_user,
          "password": var.gitlab_token
        }
      }
    })
  }
  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_config_map" "email-configmap" {
  metadata {
    name = "email-configmap"
    #namespace = kubernetes_namespace.stats.metadata[0].name
    namespace = "statistics"
  }
  data = {
    "email.txt" = file("${path.module}/email.txt")
  }
}