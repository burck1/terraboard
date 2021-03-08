resource "aws_cloudwatch_log_group" "terraboard" {
  name              = "${var.cloudwatch_log_group_prefix}/terraboard"
  retention_in_days = 30
  tags              = merge(var.tags, { Name = "${var.cloudwatch_log_group_prefix}/terraboard" })
}

resource "aws_cloudwatch_log_group" "postgres" {
  name              = "${var.cloudwatch_log_group_prefix}/postgres"
  retention_in_days = 30
  tags              = merge(var.tags, { Name = "${var.cloudwatch_log_group_prefix}/postgres" })
}
