resource "yandex_vpc_network" "network" {
  name      = "develop-fops"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "develop-fops-subnet-a"
  network_id     = yandex_vpc_network.network.id
  folder_id      = var.folder_id
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.128.0.0/24"]
}

resource "yandex_vpc_address" "lb_ip" {
  name      = "nginx-lb-address"
  folder_id = var.folder_id

  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_lb_target_group" "target_group" {
  name      = "nginx-target-group"
  folder_id = var.folder_id

  dynamic "target" {
    for_each = yandex_compute_instance.vm
    content {
      address   = target.value.network_interface[0].ip_address  # Используем внутренний IP
      subnet_id = yandex_vpc_subnet.subnet_a.id
    }
  }
}

resource "yandex_lb_network_load_balancer" "nlb" {
  name      = "nginx-lb"
  folder_id = var.folder_id

  listener {
    name        = "http-listener"
    port        = 80
    protocol    = "tcp"
    target_port = 80

    external_address_spec {
      address    = yandex_vpc_address.lb_ip.external_ipv4_address[0].address  # Используем статический IP
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.target_group.id

    healthcheck {
      name                = "http-hc"
      interval            = 5
      timeout             = 3
      healthy_threshold   = 2
      unhealthy_threshold = 3

      http_options {
        path = "/"
        port = 80
      }
    }
  }
}

output "lb_ip_address" {
  description = "Внешний IP балансировщика"
  value       = yandex_vpc_address.lb_ip.external_ipv4_address[0].address
}