resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = var.open_vpn_external_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.prefix_portal}-${var.environment}-customer-gateway"
  }
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = var.vpn_gateway_id
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  static_routes_only  = true
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  for_each               = var.private_route_tables
  route_table_id         = each.value.id
  destination_cidr_block = var.open_vpn_static_route_ip
  gateway_id             = var.vpn_gateway_id
}
