variable "vpc_cidr" {
  default     = "192.165.0.0/16"
  description = "cidr block for the vpc"
  type        = string
}

variable "cidr_block" {
  default     = "0.0.0.0/0"
  description = "cidr block notations"
  type        = string

}
variable "public_subnet_cidrs" {
  default     = ["192.165.1.0/24", "192.165.2.0/24"]
  description = "cidr blocks for the public subnet"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  default     = ["192.165.3.0/24", "192.165.4.0/24"]
  description = "cidr blocks for the private subnet"
  type        = list(string)
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  description = "The availability zones where the subnet belongs"
  type        = list(string)
}


variable "cluster-name" {
  description = "The name of the EKS Cluster"
  type        = string
  default     = "eks-api-cluster"
}


variable "eks_version" {
  type    = string
  default = "1.31"
}
