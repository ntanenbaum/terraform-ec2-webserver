# IAM Roles and policies
resource "aws_iam_role" "nt_iam_log_role" {
  name = "${var.prefix}-flow-log-role"
  assume_role_policy = data.template_file.nt_assume_role_policy.rendered
}

resource "aws_iam_role_policy" "nt_log_policy" {
  name = "${var.prefix}-flow-log-policy"
  role = aws_iam_role.nt_iam_log_role.id
  policy = data.template_file.nt_log_policy.rendered
}

