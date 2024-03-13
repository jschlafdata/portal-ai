

resource "aws_key_pair" "openvpn" {
  key_name   = var.ovpn_ssh_key_name
  public_key = file("${var.ovpn_ssh_public_key_file}")
}

resource "aws_key_pair" "kops" {
  key_name   = var.kops_ssh_key_name
  public_key = file("${var.kops_ssh_public_key_file}")
}
