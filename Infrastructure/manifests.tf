resource "kubernetes_namespace" "api_eks_namespace" {
  metadata {
    name = "api-eks-namespace"
  }
  depends_on = [aws_eks_node_group.api_eks_group]
}

resource "kubernetes_pod" "api_pod" {
  metadata {
    name      = "api-eks-app-pod"
    namespace = "api-eks-namespace"
    labels = {
      app = "api-application"
    }
  }

  spec {
    container {
      image = "aaronhood/api-current-time:1"
      name  = "api-eks-container"

      port {
        container_port = 8000
      }
    }
  }
  depends_on = [aws_eks_node_group.api_eks_group]
}

resource "kubernetes_deployment" "api_eks_deployment" {
  metadata {
    name      = "api-eks-app-deployment"
    namespace = kubernetes_namespace.api_eks_namespace.metadata[0].name
    labels = {
      app = "api-application"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "api-application"
      }
    }

    template {
      metadata {
        labels = {
          app = "api-application"
        }
      }

      spec {
        container {
          name  = "api-eks-container"
          image = "aaronhood/api-current-time:1"


          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
  depends_on = [aws_eks_node_group.api_eks_group]
}

resource "kubernetes_service" "api_eks_service" {
  metadata {
    name      = "api-service"
    namespace = "api-eks-namespace"
  }

  spec {
    selector = {
      app = "api-application"
    }

    port {
      protocol    = "TCP"
      port        = 80   # External port (used by clients)
      target_port = 8000 # Maps to container_port in the Pod
    }

      type = "LoadBalancer"
  }
  depends_on = [aws_eks_node_group.api_eks_group]
}

# resource "kubernetes_ingress_v1" "api_eks_ingress" {
#   wait_for_load_balancer = true
#   metadata {
#     name      = "api-eks-ingress-v1"
#     namespace = "api-eks-namespace"
#     annotations = {
#       "kubernetes.io/ingress.class"            = "alb"
#       "alb.ingress.kubernetes.io/scheme"       = "internet-facing" # Used for public access over the internet
#       "alb.ingress.kubernetes.io/target-type"  = "ip"              # Use "instance" for EC2 instance targets
#       "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80, \"HTTPS\": 443}]"
#     }
#   }

#   spec {
#     ingress_class_name = "alb" # Use "alb" to link with the AWS Load Balancer Controller
#     rule {
#       http {
#         path {
#           path      = "/current_time"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = kubernetes_service.api_eks_service.metadata[0].name
#               port {
#                 number = 8000
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service_account" "alb_ingress_service_account" {
#   metadata {
#     name      = "alb-ingress-controller-service-account"
#     namespace = kubernetes_namespace.api_eks_namespace.metadata[0].name
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller.arn
#     }
#   }
# }
