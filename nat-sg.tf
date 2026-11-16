resource "yandex_vpc_security_group" "nat_sg" {
  name        = "nat-sg"
  description = "Security group for NAT instance"
  network_id  = yandex_vpc_network.netology.id

  # SSH только из публичной подсети
  ingress {
    protocol       = "TCP"
    description    = "SSH from public subnet"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 22
  }

  # Трафик из приватной подсети для NAT
  ingress {
    protocol       = "ANY"
    description    = "Traffic from private subnet"
    v4_cidr_blocks = ["192.168.20.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  # Исходящий трафик
  egress {
    protocol       = "ANY"
    description    = "Allow outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
