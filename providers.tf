provider "aws" {
  region  = var.aws_region
  profile = "rene.reyes"
}

# ↓↓↓ COMENTAR TODO ESTO TEMPORALMENTE ↓↓↓

# data "aws_eks_cluster" "eks_deploy" {
#   name = module.eks_deploy.cluster_name
# }

# data "aws_eks_cluster_auth" "eks_deploy" {
#   name = module.eks_deploy.cluster_name
# }

# data "aws_eks_cluster" "eks_dev" {
#   name = module.eks_dev.cluster_name
# }

# data "aws_eks_cluster_auth" "eks_dev" {
#   name = module.eks_dev.cluster_name
# }

# provider "kubernetes" {
#   alias                  = "eks_deploy"
#   host                   = data.aws_eks_cluster.eks_deploy.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_deploy.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks_deploy.token
# }

# provider "kubernetes" {
#   alias                  = "eks_dev"
#   host                   = data.aws_eks_cluster.eks_dev.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_dev.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.eks_dev.token
# }
