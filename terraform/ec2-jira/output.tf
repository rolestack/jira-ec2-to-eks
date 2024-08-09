output "ec2_eip" {
  value             = {
    for idx in range(length(aws_instance.jira-node)) :
        aws_instance.jira-node[idx].tags["Name"] => aws_eip.jira_node_eip[idx].public_ip
  }
}

output "jira-node-id" {
  value = {
    for idx in range(length(aws_instance.jira-node)) :
        aws_instance.jira-node[idx].tags["Name"] => aws_instance.jira-node[idx].id
  } 
}