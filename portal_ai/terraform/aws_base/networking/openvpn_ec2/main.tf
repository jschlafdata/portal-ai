resource "aws_security_group" "openvpn" {
  name        = "openvpn"
  description = "Allow inbound UDP access to OpenVPN and unrestricted egress"

  vpc_id = var.vpc_id

  tags = {
    Name        = var.prefix_portal
    Provisioner = "Terraform"
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_from_local" {
  name        = "ssh-from-local"
  description = "Allow SSH access only from local machine"

  vpc_id = var.vpc_id

  tags = {
    Name        = var.prefix_portal
    Provisioner = "Terraform"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.local_ip_address]
  }
}


data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}


resource "aws_instance" "openvpn" {
  ami                         = data.aws_ami.amazon_linux_2.id
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = var.ovpn_ssh_key_name
  subnet_id                   = var.openvpn_public_subnet

  vpc_security_group_ids = [
    aws_security_group.openvpn.id,
    aws_security_group.ssh_from_local.id,
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.instance_root_block_device_volume_size
    delete_on_termination = true
  }

  tags = {
    Name        = var.prefix_portal
    Provisioner = "Terraform"
    Item = "openvpn"
  }

  # lifecycle {
  #   ignore_changes = [
  #     ami,
  #     tags["Item"]
  #     // Add other attributes here as needed
  #   ]
  # }
}

resource "aws_eip" "openvpn_eip" {
  instance = aws_instance.openvpn.id
  domain = "vpc"
}

resource "null_resource" "openvpn_bootstrap" {

  triggers = {
    instance_size = aws_instance.openvpn.instance_type
  }

  connection {
    type        = "ssh"
    host        = aws_eip.openvpn_eip.public_ip
    user        = var.ec2_username
    port        = "22"
    private_key = file("${var.ovpn_ssh_private_key_file}")
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "curl -O ${var.openvpn_install_script_location}",
      "chmod +x openvpn-install.sh",
      <<EOT
      sudo AUTO_INSTALL=y \
           APPROVE_IP=${aws_eip.openvpn_eip.public_ip} \
           ENDPOINT=${aws_eip.openvpn_eip.public_dns} \
           ./openvpn-install.sh
      
EOT
      ,
    ]
  }
}

resource "null_resource" "openvpn_update_users_script" {
  depends_on = [null_resource.openvpn_bootstrap]

  triggers = {
    ovpn_users = join(" ", var.ovpn_users)
    instance_size = aws_instance.openvpn.instance_type
  }

  connection {
    type        = "ssh"
    host        = aws_eip.openvpn_eip.public_ip
    user        = var.ec2_username
    port        = "22"
    private_key = file("${var.ovpn_ssh_private_key_file}")
    agent       = false
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_users.sh"
    destination = "/home/${var.ec2_username}/update_users.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ~${var.ec2_username}/update_users.sh",
      "sudo ~${var.ec2_username}/update_users.sh ${join(" ", var.ovpn_users)}",
    ]
  }
}

resource "null_resource" "openvpn_download_configurations" {
  depends_on = [null_resource.openvpn_update_users_script]

  triggers = {
    ovpn_users = join(" ", var.ovpn_users)
    instance_size = aws_instance.openvpn.instance_type
  }

  provisioner "local-exec" {
    command = <<EOT
    mkdir -p ${var.ovpn_config_directory};
    scp -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -i ${var.ovpn_ssh_private_key_file} ${var.ec2_username}@${aws_eip.openvpn_eip.public_ip}:/home/${var.ec2_username}/*.ovpn ${var.ovpn_config_directory}/
    
EOT

  }
}

