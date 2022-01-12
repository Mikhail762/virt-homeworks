output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "current_region" {
  value = data.aws_region.current.name
}

output "private_ip" {
  value = resource.aws_instance.test.private_ip
}

output "network_id" {
  value = resource.aws_network_interface.test_if.subnet_id
}

