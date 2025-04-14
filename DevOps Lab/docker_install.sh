#!/bin/bash

echo Atualizando os pacotes do sistema
sudo apt update
sudo apt upgrade -y

echo Instalando dependências necessárias
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

echo Adicionando chaves GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg

echo Adicionando repositório oficial do Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo Atualizando os pacotes novamente
sudo apt update

echo Instalando o Docker
sudo apt install docker-ce docker-ce-cli containerd.io -y

echo Verificando a versão do Docker
docker --version

echo Configurando para não precisar de Sudo
sudo usermod -aG docker $USER

echo Instalação Concluida! Reiniciando o sistema para aplicar configuração Sudo!
sudo reboot