# K8S Cluster in Hetzner Cloud with terraform and ansible [Kubespray]

Deploy a k8s cluster in Hetzner Cloud using terraform and ansible.

## Terraform

```bash
cd hetzner_infra

terraform init
terraform apply
```

## Ansible

```bash
docker build -t ansible-k8s-kubespray ./ansible

docker run --rm -it \
-v inventory.yml:/ansible/inventory.yml \
-v ./hetzner_infra/.ssh/k8s_hetzner_key:/secrets/ssh_key \
-v ./hetzner_infra/.ssh/k8s_hetzner_key.pub:/secrets/ssh_key.pub \
ansible-k8s-kubespray

ansible-playbook playbook_k8s_deploy.yml

cat kubeconfig
```

or use the [prebuilt](https://hub.docker.com/repository/docker/ujstor/ansible-k8s-kubespray/general) image:

```bash
docker run --rm -it \
-v ./inventory.yml:/ansible/inventory.yml \
-v ./hetzner_infra/.ssh/k3s_hetzner_key:/secrets/ssh_key \
-v ./hetzner_infra/.ssh/k3s_hetzner_key.pub:/secrets/ssh_key.pub \
ansible-k8s-kubespray:0.0.1
```
