output "environment_id" {
  description = "ID of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.env.id
}

output "environment_name" {
  description = "Name of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.env.name
}

output "endpoint_url" {
  description = "Endpoint URL of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.env.endpoint_url
}

output "security_group_id" {
  description = "ID of the security group for the Elastic Beanstalk environment"
  value       = aws_security_group.beanstalk.id
}

output "instance_profile_name" {
  description = "Name of the instance profile for the Elastic Beanstalk environment"
  value       = aws_iam_instance_profile.beanstalk.name
}