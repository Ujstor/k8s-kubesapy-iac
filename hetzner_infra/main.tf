module "ssh_key_k8s" {
  source = "github.com/Ujstor/terraform-hetzner-modules//modules/ssh_key?ref=v0.0.4"

  ssh_key_name = "k8s_hetzner_key"
  ssh_key_path = ".ssh" #create dir before appling tf config if you use custom paths for ssh keys
}

module "servers" {
  source = "github.com/Ujstor/terraform-hetzner-modules//modules/server?ref=v0.0.4"

  server_config = {
    server-1 = {
      location    = "fsn1"
      server_type = "cx22"
      labels = {
        control_plane : "true"
        cluster : "k8s-cluster"
      }
      ipv4_enabled = true
      ipv6_enabled = false
      subnet_id    = module.vpc_subnets.subnet_id.subnet-1.subnet_id
      subnet_ip    = "10.0.1.1"
    }
    server-2 = {
      location    = "hel1"
      server_type = "cx22"
      labels = {
        control_plane : "true"
        cluster : "k8s-cluster"
      }
      ipv4_enabled = true
      ipv6_enabled = false
      subnet_id    = module.vpc_subnets.subnet_id.subnet-1.subnet_id
      subnet_ip    = "10.0.1.2"
    }
    server-3 = {
      location    = "fsn1"
      server_type = "cx22"
      labels = {
        control_plane : "true"
        cluster : "k8s-cluster"
      }
      ipv4_enabled = true
      ipv6_enabled = false
      subnet_id    = module.vpc_subnets.subnet_id.subnet-1.subnet_id
      subnet_ip    = "10.0.1.3"
    }
    server-4 = {
      location    = "hel1"
      server_type = "cx32"
      labels = {
        node : "true"
        cluster : "k8s-cluster"
        rook-storage-node : "true"
      }
      ipv4_enabled = true
      ipv6_enabled = false
      subnet_id    = module.vpc_subnets.subnet_id.subnet-2.subnet_id
      subnet_ip    = "10.0.2.1"
    }
    server-5 = {
      location    = "fsn1"
      server_type = "cx32"
      labels = {
        node : "true"
        cluster : "k8s-cluster"
        rook-storage-node : "true"
      }
      ipv4_enabled = true
      ipv6_enabled = false
      subnet_id    = module.vpc_subnets.subnet_id.subnet-2.subnet_id
      subnet_ip    = "10.0.2.2"
    }
    server-6 = {
      location    = "nbg1"
      server_type = "cx32"
      labels = {
        node : "true"
        cluster : "k8s-cluster"
        rook-storage-node : "true"
      }
      ipv4_enabled = true
      ipv6_enabled = false
      subnet_id    = module.vpc_subnets.subnet_id.subnet-2.subnet_id
      subnet_ip    = "10.0.2.3"
    }
  }

  hcloud_ssh_key_id = [module.ssh_key_k8s.hcloud_ssh_key_id]

  use_network = true

  depends_on = [module.ssh_key_k8s]
}

module "cloudflare_record" {
  source = "github.com/Ujstor/terraform-hetzner-modules//modules/network/cloudflare_record?ref=v0.0.4"

  cloudflare_record = {
    kube_api = {
      zone_id = var.cloudflare_zone_id
      name    = "api.k8s"
      content = module.load_balancer.lb_status.k8s-api.lb_ip
      type    = "A"
      ttl     = 3600
      proxied = false
    }
  }
  depends_on = [module.servers]
}

module "vpc_subnets" {
  source = "github.com/Ujstor/terraform-hetzner-modules//modules/network/vpc_subnet?ref=v0.0.4"

  vpc_config = {
    vpc_name     = "k8s-vpc"
    vpc_ip_range = "10.0.0.0/16"
  }

  subnet_config = {
    subnet-1 = {
      subnet_ip_range = "10.0.1.0/24"
    }
    subnet-2 = {
      subnet_ip_range = "10.0.2.0/24"
    }
  }

  network_type = "cloud"
  network_zone = "eu-central"
}

module "load_balancer" {
  source = "github.com/Ujstor/terraform-hetzner-modules//modules/network/loadbalancer?ref=v0.0.5"
  lb_config = {
    k8s-api = {
      name               = "k8s-api-lb"
      load_balancer_type = "lb11"
      network_zone       = module.vpc_subnets.subnet_id.subnet-1.network_zone
      load_balancer_target = [
        {
          type           = "label_selector"
          label_selector = "cluster"
        }

      ]
    }
  }
  depends_on = [module.vpc_subnets, module.servers]
}
