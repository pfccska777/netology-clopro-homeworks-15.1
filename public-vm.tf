# IP, с которого разрешено подключение по SSH
variable "ssh_allowed_cidr" {
  description = "Allowed external IP address for SSH"
  type        = string
}

# Актуальный образ Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu" {
  family    = "ubuntu-2204-lts"
  folder_id = "standard-images"
}

# Группа безопасности публичной машины
resource "yandex_vpc_security_group" "public_sg" {
  name        = "public-sg"
  description = "Security group for public VM"
  network_id  = yandex_vpc_network.netology.id

  ingress {
    protocol       = "TCP"
    description    = "SSH from my IP"
    v4_cidr_blocks = [var.ssh_allowed_cidr]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Allow outgoing traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# Публичная виртуальная машина
resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
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
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.public_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(file(pathexpand("~/.ssh/netology_15_1.pub")))}"
  }
}
