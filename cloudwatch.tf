# Cloudwatch log group
resource "aws_cloudwatch_log_group" "nt_flow_log_group" {
  name = var.log_group_name == "" ? local.default_log_group_name : var.log_group_name
}

# Network Traffic Flow Logs
resource "aws_flow_log" "ntvpcflowlog" {
  log_destination = aws_cloudwatch_log_group.nt_flow_log_group.arn
  iam_role_arn    = aws_iam_role.nt_iam_log_role.arn
  vpc_id          = aws_vpc.ntvpc.id
  traffic_type    = var.traffic_type
}

