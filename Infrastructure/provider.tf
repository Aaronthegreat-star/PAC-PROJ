provider "aws" {
  region = "us-east-1"
  # profile = "aaron-profile" 
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    # time = {
    #   source = "hashicorp/time"
    #   version = ">= 0.7.0"
    # }
  }
}
provider "kubernetes" {
  host                   = aws_eks_cluster.api_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.api_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.api_cluster_auth.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    
    command = "aws"
    args = [ "eks", "get-token", "--cluster-name", aws_eks_cluster.api_eks_cluster.name]
  }
}