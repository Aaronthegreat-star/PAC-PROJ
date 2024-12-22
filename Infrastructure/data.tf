data "aws_eks_cluster" "api_eks_cluster" {
  name = aws_eks_cluster.api_eks_cluster.name
}

# data "aws_security_group" "api_cluster_sg" {
#   id = data.aws_eks_cluster.api_eks_cluster.cluster_security_group_id
# }

data "aws_eks_cluster_auth" "api_cluster_auth" {
  name = data.aws_eks_cluster.api_eks_cluster.name
}
