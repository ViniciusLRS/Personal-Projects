#!/bin/bash

echo Desativando o Swap!
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo Configurando os modulos do Kernel
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

echo Instalando o container runtime!
sudo apt update
sudo apt install -y containerd

echo Configurando o containerd!
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

echo Reiniciando o serviço!
sudo systemctl restart containerd
sudo systemctl enable containerd

echo Adicionando o repositório do Kubernetes!
sudo apt update && sudo apt install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo Instalando o kubeadm, kubelet e kubectl!
sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo Inicializando o cluster! 

# Inicializa o cluster e salva a saída num arquivo temporário
INIT_LOG=$(mktemp)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | tee $INIT_LOG

# Extrai a linha do kubeadm join
JOIN_CMD=$(grep -A2 "kubeadm join" "$INIT_LOG")

# Exibe o comando formatado
echo -e "\n Comando para adicionar workers ao cluster:"
echo "$JOIN_CMD"

# Salvar em um arquivo fixo
echo "$JOIN_CMD" > ~/kubeadm-join.txt

echo Configurando o kubectl para usuário atual!
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo Instalando a rede do cluster!
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml

#Permitir pods no master
#kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo Testando a instalação!
kubectl get nodes
kubectl get pods -A

echo Instalação Concluida!