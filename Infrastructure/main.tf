resource "aws_vpc" "api_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    name = "api-proj-vpc"
  }
}


resource "aws_internet_gateway" "api_gw" {
  vpc_id     = aws_vpc.api_vpc.id
  depends_on = [aws_vpc.api_vpc]
  tags = {
    Name = "api-proj-gw"
  }
}

resource "aws_subnet" "api_pub_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.api_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "api-public-subnet-${count.index}"
  }
  depends_on = [aws_vpc.api_vpc]
}

resource "aws_subnet" "api_pri_subnet" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.api_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "api-private-subnet-${count.index}"
  }
  depends_on = [aws_vpc.api_vpc]
}

resource "aws_eip" "api_eip" {
  count      = 2
  domain     = "vpc"
  depends_on = [aws_internet_gateway.api_gw]
}

resource "aws_nat_gateway" "api_ngw" {
  count         = 2
  allocation_id = aws_eip.api_eip[count.index].id
  subnet_id     = element(aws_subnet.api_pub_subnet[*].id, count.index)
  depends_on    = [aws_internet_gateway.api_gw]
}

resource "aws_route_table" "api_pub_route_table" {
  count  = 2
  vpc_id = aws_vpc.api_vpc.id
  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.api_gw.id
  }
}

resource "aws_route_table" "api_pri_route_table" {
  count  = 2
  vpc_id = aws_vpc.api_vpc.id
  route {
    cidr_block = var.cidr_block
    gateway_id = aws_nat_gateway.api_ngw[count.index].id
  }
}

resource "aws_route_table_association" "api_pri_route_table" {
  count          = length(aws_subnet.api_pri_subnet)
  subnet_id      = aws_subnet.api_pri_subnet[count.index].id
  route_table_id = aws_route_table.api_pri_route_table[count.index].id
}

resource "aws_route_table_association" "api_pub_route_table" {
  count          = length(aws_subnet.api_pub_subnet)
  subnet_id      = aws_subnet.api_pub_subnet[count.index].id
  route_table_id = aws_route_table.api_pub_route_table[count.index].id
}


resource "aws_eks_cluster" "api_eks_cluster" {
  name     = "api-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids              = aws_subnet.api_pri_subnet[*].id
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [aws_security_group.api_eks_node_group_sg.id]
  }
  version    = var.eks_version
  depends_on = [aws_iam_role_policy_attachment.api-AmazonEKSClusterPolicy]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.api_eks_cluster.name
  addon_name   = "vpc-cni"
  depends_on   = [aws_eks_cluster.api_eks_cluster]
}

# Add Kube Proxy (kube-proxy)
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.api_eks_cluster.name
  addon_name   = "kube-proxy"
  depends_on   = [aws_eks_cluster.api_eks_cluster]
}

# Add CoreDNS (coredns)
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.api_eks_cluster.name
  addon_name   = "coredns"
  depends_on   = [aws_eks_cluster.api_eks_cluster]
}

# Ensure that the cluster is created before addons


# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["eks.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "eks_role" {
#   name = "api-eks-cluster-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "api-AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_role.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.eks_role.name
# }

resource "aws_eks_node_group" "api_eks_group" {
  cluster_name    = aws_eks_cluster.api_eks_cluster.name
  node_group_name = "api-node-group"
  node_role_arn   = aws_iam_role.api_eks_node_group.arn
  subnet_ids      = aws_subnet.api_pri_subnet[*].id
  depends_on      = [aws_eks_cluster.api_eks_cluster]


  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }
  instance_types = ["t2.micro"]
  ami_type       = "AL2_x86_64"
  tags = {
    Name = "api-eks_node_group"
  }
}

# resource "aws_security_group_attachment" "eks_primary_sg_attachment" {
#   security_group_id = data.aws_security_group.api_cluster_sg.id
#   target_id         = aws_eks_node_group.api_eks_group.node_security_group_id
# }

resource "aws_iam_role" "api_eks_node_group" {
  name = "api-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
  depends_on = [aws_eks_cluster.api_eks_cluster]
}


# resource "aws_iam_role_policy_attachment" "api-AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.api_eks_node_group.name
# }

resource "aws_iam_role_policy_attachment" "api-node_group_policy_attachments" {
  count      = length(["AmazonEKSWorkerNodePolicy", "AmazonEC2ContainerRegistryReadOnly", "AmazonEKS_CNI_Policy"])
  policy_arn = "arn:aws:iam::aws:policy/${element(["AmazonEKSWorkerNodePolicy", "AmazonEC2ContainerRegistryReadOnly", "AmazonEKS_CNI_Policy"], count.index)}"
  role       = aws_iam_role.api_eks_node_group.name
}
# resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.api_eks_node_group
# }

resource "aws_eks_fargate_profile" "api_eks_fargate_profile" {
  cluster_name           = aws_eks_cluster.api_eks_cluster.name
  fargate_profile_name   = "api-eks-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_role.arn
  subnet_ids             = aws_subnet.api_pri_subnet[*].id
  depends_on             = [aws_eks_node_group.api_eks_group]
  selector {
    namespace = "default"
  }
}

# resource "aws_iam_role" "alb_ingress_controller" {
#   name = "alb-ingress-controller-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "eks.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = aws_iam_openid_connect_provider.api_eks_connect.arn
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "${aws_iam_openid_connect_provider.api_eks_connect.url}:sub" = "system:serviceaccount:kube-system:alb-ingress-controller-service-account"
#           }
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "alb_ingress_controller_policy" {
#   name        = "alb-ingress-controller-policy"
#   description = "Policy for the AWS Load Balancer Controller"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "elasticloadbalancing:*",
#           "ec2:Describe*",
#           "ec2:AuthorizeSecurityGroupIngress",
#           "ec2:RevokeSecurityGroupIngress",
#           "ec2:CreateSecurityGroup",
#           "ec2:DeleteSecurityGroup",
#           "iam:CreateServiceLinkedRole",
#           "iam:GetServerCertificate",
#           "iam:ListServerCertificates",
#           "cognito-idp:DescribeUserPoolClient",
#           "waf:GetWebACL",
#           "waf-regional:GetWebACLForResource",
#           "waf-regional:AssociateWebACL",
#           "waf-regional:DisassociateWebACL",
#           "tag:GetResources",
#           "tag:TagResources",
#           "wafv2:GetWebACL",
#           "wafv2:GetWebACLForResource",
#           "wafv2:AssociateWebACL",
#           "wafv2:DisassociateWebACL"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "alb_ingress_controller_attach" {
#   role       = aws_iam_role.alb_ingress_controller.name
#   policy_arn = aws_iam_policy.alb_ingress_controller_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "alb_ingress_controller_policy" {
#   role       = aws_iam_role.alb_ingress_controller.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
# }

# resource "aws_iam_openid_connect_provider" "api_eks_connect" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [aws_eks_cluster.api_eks_cluster.certificate_authority.0.data]
#   url             = aws_eks_cluster.api_eks_cluster.identity[0].oidc[0].issuer
# }
