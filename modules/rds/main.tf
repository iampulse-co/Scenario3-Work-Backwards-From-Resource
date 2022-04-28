variable "vpc_main_id" {}
variable "rds_sg_id" {}
variable "db_subnets_id" {}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "dev-scenario-three-rds"

  engine            = "mysql"
  engine_version    = "5.7.25"
  instance_class    = "db.t2.small"
  allocated_storage = 5

  db_name             = "scenarioThreeRds"
  username            = "user"
  port                = "3306"
  publicly_accessible = true

  # Permit authenticating to RDS with IAM
  iam_database_authentication_enabled = true

  vpc_security_group_ids = [var.rds_sg_id]
  monitoring_interval    = "30"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = true

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.db_subnets_id

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  tags = {
    Environment = "dev"
  }
}