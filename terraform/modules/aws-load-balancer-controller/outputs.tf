output "load_balancer_controller_role_arn" {
  description = "ARN of the IAM role for the AWS Load Balancer Controller"
  value = module.load_balancer_controller_irsa_role.iam_role_arn
}