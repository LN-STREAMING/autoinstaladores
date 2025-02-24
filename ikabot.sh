#!/bin/bash

# Função para exibir uma barra de carregamento
show_progress() {
    local duration=$1
    local progress=0
    local bar_length=30

    while [ $progress -lt $bar_length ]; do
        sleep $(echo "$duration/$bar_length" | bc -l)
        progress=$((progress + 1))
        echo -ne "["
        for ((i = 0; i < progress; i++)); do echo -ne "#"; done
        for ((i = progress; i < bar_length; i++)); do echo -ne " "; done
        echo -ne "] $((progress * 100 / bar_length))%\r"
    done
    echo -ne "\n"
}

# Modo silencioso para evitar prompts interativos
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "🔄 Atualizando pacotes..."
sudo apt update -y &>/dev/null
sudo apt upgrade -y &>/dev/null
show_progress 6

echo "📦 Instalando dependências..."
sudo apt install -y python3 python3-dev python3-pip python3-venv gcc git wget &>/dev/null
show_progress 5

echo "📥 Baixando e instalando o Ikabot..."
if [ ! -d "ikabot" ]; then
    sudo git clone https://github.com/Ikabot-Collective/ikabot &>/dev/null
fi
cd ikabot
sudo python3 -m pip install --user -e . &>/dev/null
show_progress 4

# Solicitar email e senha do usuário
read -p "✉️  Digite seu e-mail do Ikabot: " email
read -s -p "🔑 Digite sua senha do Ikabot: " senha
echo ""

# Executar Ikabot com os dados informados
echo "🚀 Iniciando Ikabot..."
python3 -m ikabot "$email" "$senha" &>/dev/null
show_progress 3

echo "✅ Instalação concluída! O Ikabot está rodando."
