data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    var.security_group_id
  ]

  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash

    apt-get update -y
    apt-get install -y nginx

    systemctl enable nginx
    systemctl start nginx

    cat <<'HTML' > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
    <head>
        <title>HUG Week 3 - Two Tier Application</title>
    </head>
    <body>
        <h1>Two-Tier Application</h1>
        <p>Deployed with Terraform on AWS.</p>
        <p>EC2 + Nginx is running successfully.</p>
    </body>
    </html>
    HTML
  EOF

  tags = {
    Name        = "${var.project_name}-web-server"
    Project     = var.project_name
    Environment = "dev"
    Tier        = "Public"
    Role        = "Web"
    ManagedBy   = "Terraform"
  }
}