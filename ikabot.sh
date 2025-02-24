#!/bin/bash

# Definir modo silencioso para evitar prompts interativos
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Atualizar pacotes sem exibir saídas
echo "Atualizando pacotes..."
sudo apt update -y &>/dev/null
sudo apt upgrade -y &>/dev/null

# Instalar dependências necessárias sem exibir saídas
echo "Instalando dependências..."
sudo apt install -y python3 python3-dev python3-pip python3-venv gcc git wget &>/dev/null

# Baixar e instalar o get-pip.py silenciosamente
echo "Instalando gerenciador de pacotes..."
wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
sudo python3 /tmp/get-pip.py &>/dev/null
sudo pip3 install psutil &>/dev/null

# Clonar repositório do Ikabot
echo "Baixando e instalando o Ikabot..."
if [ ! -d "ikabot" ]; then
    sudo git clone https://github.com/Ikabot-Collective/ikabot &>/dev/null
fi
cd ikabot
sudo python3 -m pip install --user -e . &>/dev/null

# Solicitar email e senha do usuário
read -p "Digite seu e-mail do Ikabot: " email
read -s -p "Digite sua senha do Ikabot: " senha
echo ""

# Executar Ikabot com os dados informados
echo "Iniciando Ikabot..."
python3 -m ikabot "$email" "$senha" &>/dev/null

echo "✅ Instalação concluída! O Ikabot está rodando."
