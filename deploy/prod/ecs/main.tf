provider "aws" {
  region    =   "ap-southeast-1"
}



resource "aws_iam_role" "ecs-task-execution" {
    name = "ecsTaskExecutionRole"
    assume_role_policy = "${file("./assume-policy.json")}"
}

resource "aws_iam_role_policy" "ecs-task-execution-role-policy" {
    name = "ecsTaskExecutionRolePolicy"
    policy = "${file("./policy-ecs.json")}"
    role = "${aws_iam_role.ecs-task-execution.id}"
}

resource "aws_iam_role" "ecs-access-dynamodb" {
    name = "ecsTaskAccessDynamoDb"
    assume_role_policy = "${file("./assume-policy.json")}"
}

resource "aws_iam_role_policy" "ecs-access-dynamo-db-role-policy" {
    name = "vaultAccessDynamoDb"
    policy = "${file("./policy-dynamo.json")}"
    role = "${aws_iam_role.ecs-access-dynamodb.id}"
}

resource "aws_ecs_cluster" "kms-cluster" {
  name = "kms-cluster"
}

resource "aws_ecs_task_definition" "kms-td" {
    family = "kms"
    execution_role_arn = "${aws_iam_role.ecs-task-execution.arn}"
    container_definitions = "${file("./task-definitions/kms/task.json")}"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    cpu = 1024
    memory = 2048
    task_role_arn = "${aws_iam_role.ecs-access-dynamodb.arn}"
}

resource "aws_ecs_task_definition" "vault-td" {
    family = "vault"
    execution_role_arn = "${aws_iam_role.ecs-task-execution.arn}"
    container_definitions = "${file("./task-definitions/vault/task.json")}"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    cpu = 1024
    memory = 2048
    task_role_arn = "${aws_iam_role.ecs-access-dynamodb.arn}"

}


resource "aws_ecs_service" "kms-svc" {
  name            = "kms-service"
  cluster         = "${aws_ecs_cluster.kms-cluster.id}"
  task_definition = "${aws_ecs_task_definition.kms-td.arn}"
  desired_count   = 3
  launch_type = "FARGATE"
  
  network_configuration {
    subnets = ["${aws_subnet.subnet-a.id}"]
    security_groups = ["${aws_security_group.alb-sg.id}"]
    assign_public_ip = true
  }

  load_balancer {
    container_name = "kmsservice"
    container_port = "8001"
    target_group_arn = "${aws_lb_target_group.kms-service-tg.arn}"
    #elb_name = "kms-lb"
  }

  depends_on = ["aws_lb.kmsservice-lb"]
}

data "aws_route_table" "subnet-a-rt" {  
    subnet_id = "${aws_subnet.subnet-a.id}"
}
resource "aws_route" "to_igw" {
    route_table_id = "${data.aws_route_table.subnet-a-rt.id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
    depends_on = ["aws_subnet.subnet-a", "aws_internet_gateway.igw"]
}



resource "aws_ecs_service" "vault-svc" {
  name            = "vault-service"
  cluster         = "${aws_ecs_cluster.kms-cluster.id}"
  task_definition = "${aws_ecs_task_definition.vault-td.arn}"
  desired_count   = 3
  launch_type = "FARGATE"

  network_configuration {
    subnets = ["${aws_subnet.subnet-a.id}"]
    security_groups = ["${aws_security_group.alb-sg.id}"]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.servicediscovery.arn}"
    container_name = "vault"
  }


}

resource "aws_lb_target_group" "kms-service-tg" {
  port = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = "${aws_vpc.vpc-kms.id}"

  health_check {
    matcher = "200"
    port = "8001"
    path = "/health"
  }

}




resource "aws_service_discovery_private_dns_namespace" "servicediscover_dns" {
  name        = "local"
  description = "service discovery"
  vpc         = "${aws_vpc.vpc-kms.id}"
}

resource "aws_service_discovery_service" "servicediscovery" {
  name = "service_discovery_kms"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.servicediscover_dns.id}"

    dns_records {
      ttl  = 60
      type = "A"
    }
  }

}


resource "aws_subnet" "subnet-a" {
  cidr_block = "10.0.0.1/24"
  availability_zone = "ap-southeast-1a"
  vpc_id = "${aws_vpc.vpc-kms.id}"  
}

resource "aws_subnet" "subnet-b" {
  cidr_block = "10.0.1.1/24"
  availability_zone = "ap-southeast-1b"
  vpc_id = "${aws_vpc.vpc-kms.id}"  
}

resource "aws_vpc" "vpc-kms" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_lb" "kmsservice-lb" {
  name               = "kms-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb-sg.id}"]
  subnets            = ["${aws_subnet.subnet-a.id}", "${aws_subnet.subnet-b.id}"]

  enable_deletion_protection = false
  

}

resource "aws_lb_listener" "kmsservice-lb-listner" {
  load_balancer_arn = "${aws_lb.kmsservice-lb.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.kms-service-tg.arn}"
  }
}




resource "aws_security_group" "alb-sg" {
  name = "kms-internet-facing-lb"
  vpc_id = "${aws_vpc.vpc-kms.id}"
  tags {
      Name = "sg-internet-facing-lb"
  }
  ingress {
      protocol = -1
      from_port = 0
      to_port = 0
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      protocol = "-1"
      from_port = 0
      to_port = 0
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc-kms.id}"
}


resource "aws_cloudwatch_log_group" "kmslog" {
  name = "/ecs/service"
}

resource "aws_cloudwatch_log_group" "vaultlog" {
  name = "/ecs/vault"
}

output "dns_name" {
  value = "${aws_lb.kmsservice-lb.dns_name}"
}
