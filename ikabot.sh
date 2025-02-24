#!/bin/bash

# Definir modo não interativo para evitar prompts
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Redirecionar saídas para /dev/null para suprimir mensagens
exec &>/dev/null

# Atualizar pacotes silenciosamente
apt update -y
apt upgrade -y

# Instalar dependências necessárias sem exibir saída
apt install -y python3 python3-dev python3-pip python3-venv gcc git wget

# Baixar e instalar o get-pip.py silenciosamente
wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
python3 /tmp/get-pip.py

# Instalar o psutil silenciosamente
pip3 install psutil

# Clonar repositório do Ikabot
if [ ! -d "ikabot" ]; then
    git clone https://github.com/Ikabot-Collective/ikabot
fi
cd ikabot

# Instalar o Ikabot silenciosamente
python3 -m pip install --user -e .

# Solicitar credenciais do usuário
read -p "Digite seu e-mail do Ikabot: " email
read -s -p "Digite sua senha do Ikabot: " senha
echo ""

# Executar Ikabot
python3 -m ikabot "$email" "$senha" &>/dev/null
