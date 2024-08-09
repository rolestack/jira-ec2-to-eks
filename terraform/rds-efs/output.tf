output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.default.endpoint
}

output "rds_address" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.default.address
}

output "efs_dns_name" {
  description = "The DNS name for the EFS file system"
  value       = aws_efs_file_system.default.dns_name
}

output "efs_mount_targets" {
  value = {
    for subnet, mount_target in aws_efs_mount_target.default :
    subnet => mount_target.ip_address
  }
  description = "The DNS names for the EFS mount targets"
}

output "mount-helper" {
  value = "file_system_id.efs.aws-region.amazonaws.com:/ mount_point nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0"
  description = "The mount helper command for the EFS file system"
}