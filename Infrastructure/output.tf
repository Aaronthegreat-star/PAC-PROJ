output "eks_cluster_id" {
  value = aws_eks_cluster.api_eks_cluster.id
}
output "vpc_id" {
  value = aws_vpc.api_vpc.id
}
output "private_subnets" {
  value = aws_subnet.api_pri_subnet[*].id
}

output "public_subnets" {
  value = aws_subnet.api_pub_subnet[*].id
}
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.api_eks_cluster.endpoint
}
# output "ingress_load_balancer_dns" {
#   value = kubernetes_ingress_v1.api_eks_ingress.status[0].load_balancer[0].ingress[0].hostname
# }
# output "eks_oidc_issuer_url" {
#   value = ks_cluster.api_eks_cluster.identity[0].oidc[0].issuer
# }