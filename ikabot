#!/bin/bash

# Função para exibir mensagens formatadas
log() {
    echo -e "\e[1;32m[INFO] $1\e[0m"
}

# Atualizar pacotes do sistema
log "Atualizando pacotes do sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instalar dependências do Python e GCC
log "Instalando dependências..."
sudo apt install -y python3 python3-dev python3-pip python3-venv gcc

# Baixar e instalar get-pip.py
log "Baixando e instalando get-pip.py..."
sudo wget -q https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
sudo pip3 install psutil

# Clonar o repositório Ikabot e instalar
log "Baixando e instalando Ikabot..."
sudo git clone https://github.com/Ikabot-Collective/ikabot
cd ikabot
sudo python3 -m pip install --user -e .

# Solicitar email e senha
echo -e "\e[1;34mDigite seu email para o Ikabot:\e[0m"
read EMAIL
echo -e "\e[1;34mDigite sua senha para o Ikabot:\e[0m"
read -s SENHA  # O "-s" oculta a senha enquanto o usuário digita

# Executar Ikabot automaticamente com os dados fornecidos
log "Executando Ikabot..."
python3 -m ikabot "$EMAIL" "$SENHA"

# Exibir mensagem final
log "Instalação concluída com sucesso!"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;32mIkabot foi instalado e está rodando com suas credenciais!\e[0m"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
