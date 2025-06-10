module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "multi"
  }
}

module "eks_deploy" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name_deploy
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  enable_irsa                  = true
  manage_aws_auth_configmap    = false  # ✅ dejar solo este

  eks_managed_node_groups = {
    jenkins_nodes = {
      desired_size   = 2
      max_size       = 2
      min_size       = 2
      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Env = "deployment"
  }
}

module "eks_dev" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = var.cluster_name_dev
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  enable_irsa                  = true
  manage_aws_auth_configmap    = false  # ✅ evitar el error

  eks_managed_node_groups = {
    dev_nodes = {
      desired_size   = 2
      max_size       = 2
      min_size       = 2
      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Env = "development"
  }
}
