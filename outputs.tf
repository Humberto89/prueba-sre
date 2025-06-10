output "eks_deploy_cluster_endpoint" {
  value = module.eks_deploy.cluster_endpoint
}

output "eks_dev_cluster_endpoint" {
  value = module.eks_dev.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
