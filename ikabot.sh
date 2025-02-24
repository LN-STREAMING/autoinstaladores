#!/bin/bash

# Configuração para evitar prompts interativos
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Atualizar pacotes
echo "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instalar pacotes necessários
echo "Instalando dependências..."
sudo apt install -y python3 python3-dev python3-pip python3-venv gcc git wget

# Baixar e instalar o get-pip.py
echo "Baixando e instalando o gerenciador de pacotes pip..."
wget -q https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo pip3 install psutil

# Clonar o repositório do Ikabot e instalar
echo "Baixando e instalando o Ikabot..."
sudo git clone https://github.com/Ikabot-Collective/ikabot
cd ikabot
sudo python3 -m pip install --user -e .

# Solicitar email e senha do usuário
read -p "Digite seu e-mail do Ikabot: " email
read -s -p "Digite sua senha do Ikabot: " senha
echo ""

# Executar o Ikabot com as credenciais fornecidas
echo "Iniciando o Ikabot..."
python3 -m ikabot "$email" "$senha"

echo "Instalação concluída! O Ikabot está rodando."
