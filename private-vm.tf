# Группа безопасности приватной машины
resource "yandex_vpc_security_group" "private_sg" {
  name        = "private-sg"
  description = "Security group for private VM"
  network_id  = yandex_vpc_network.netology.id

  # SSH только с публичной виртуальной машины
  ingress {
    protocol       = "TCP"
    description    = "SSH from public VM"
    v4_cidr_blocks = ["${yandex_compute_instance.public_vm.network_interface[0].ip_address}/32"]
    port           = 22
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

# Приватная виртуальная машина
resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    ip_address         = "192.168.20.10"
    nat                = false
    security_group_ids = [yandex_vpc_security_group.private_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(file(pathexpand("~/.ssh/netology_15_1.pub")))}"
  }
}
