
# Create Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Node_Red_Security_Group.id, aws_security_group.Out_Security_Group.id]
  subnets            = [aws_subnet.Public_Subnet1.id, aws_subnet.Public_Subnet2.id]

  tags = {
    Name = "app-lb"
  }
}

# Create ALB Target Group
resource "aws_lb_target_group" "app_tg" {
  name   = "app-tg"
  protocol = "TCP"
  port   = 1880
  vpc_id = aws_vpc.Node_Red_VPC.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200,302"
    path                = "/"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# Create ALB Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "1880"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Output the Load Balancer DNS name
output "Frontend_Load_Balancer_DNS" {
  value = aws_lb.app_lb.dns_name
}



# Create Application Load Balancer
resource "aws_lb" "backend_app_lb" {
  name               = "backend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Back_End_Security_Group.id, aws_security_group.Out_Security_Group.id]
  subnets            = [aws_subnet.Private_Subnet1.id, aws_subnet.Private_Subnet2.id]

  tags = {
    Name = "backend-lb"
  }
}

# Create ALB Target Group
resource "aws_lb_target_group" "backend_tg" {
  name   = "backend-tg"
  protocol = "TCP"
  port   = 3000
  vpc_id = aws_vpc.Node_Red_VPC.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200,302"
    path                = "/"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# Create ALB Listener
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_app_lb.arn
  port              = "3000"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Output the Load Balancer DNS name
output "Backend_Load_Balancer_DNS" {
  value = aws_lb.backend_app_lb.dns_name
}
