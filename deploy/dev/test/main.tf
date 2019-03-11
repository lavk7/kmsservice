provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_cloudwatch_log_group" "test" {
  name = "/ecs/test"
}

