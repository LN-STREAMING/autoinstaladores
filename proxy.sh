#!/bin/bash

clear

# Função para exibir mensagens formatadas
log() {
    echo -e "\e[1;32m[INFO] $1\e[0m"
}

# Função para exibir uma barra de progresso real
show_progress() {
    command="$1"
    total_steps="$2"
    progress=0
    bar_length=30

    { $command; echo "done"; } | while read -r line; do
        ((progress++))
        percent=$((progress * 100 / total_steps))
        filled=$((progress * bar_length / total_steps))
        empty=$((bar_length - filled))
        
        echo -ne "["
        printf '#%.0s' $(seq 1 $filled)
        printf ' %.0s' $(seq 1 $empty)
        echo -ne "] $percent%\r"
    done
    echo -ne "\n"
}

# Atualizar pacotes e instalar Squid e Apache2-utils
log "🔄 Atualizando pacotes e instalando Squid..."
show_progress "sudo apt update -y && sudo apt install -y squid apache2-utils" 5

# Criar usuário e senha para autenticação sem interação manual
log "🔑 Criando usuário para o Squid..."
USER_SQUID="ikariam"
PASS_SQUID="mairaki"
echo "$USER_SQUID:$PASS_SQUID" | sudo tee /etc/squid/passwords &>/dev/null
sudo chmod 640 /etc/squid/passwords &>/dev/null
log "✅ Usuário criado!"

# Criar backup da configuração original do Squid
log "📂 Fazendo backup da configuração original do Squid..."
show_progress "sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak" 2

# Criar nova configuração do Squid
log "⚙️ Configurando Squid..."
PORT_SQUID="12554"
sudo tee /etc/squid/squid.conf &>/dev/null <<EOF
http_port $PORT_SQUID
acl all src all
http_access allow all

# Outras configurações de segurança
visible_hostname proxy.example.com
logfile_rotate 5
forwarded_for delete
request_header_access User-Agent deny all
request_header_access Referer deny all
request_header_access Accept-Encoding deny all
request_header_access Accept deny all

# Configurações de timeout
dns_nameservers 8.8.8.8 8.8.4.4
tcp_outgoing_address 0.0.0.0

# Segurança adicional para evitar abuso
deny_info ERR_ACCESS_DENIED all

# Portas seguras
acl Safe_ports port 80
acl Safe_ports port 443
http_access deny !Safe_ports
EOF
log "✅ Configuração do Squid aplicada!"

# Reiniciar o serviço do Squid
log "🔄 Reiniciando Squid..."
show_progress "sudo systemctl restart squid" 3

# Obter o IP público da máquina
IP_MACHINE=$(curl -s ifconfig.me)

# Exibir informações finais
log "✅ Instalação concluída! Detalhes do proxy:"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
echo -e "\e[1;32m🌍 IP da Máquina:\e[0m $IP_MACHINE"
echo -e "\e[1;32m🔌 Porta do Squid:\e[0m $PORT_SQUID"
echo -e "\e[1;32m👤 Usuário:\e[0m $USER_SQUID"
echo -e "\e[1;32m🔒 Senha:\e[0m $PASS_SQUID"
echo -e "\e[1;32m🌍 Proxy:\e[0m $IP_MACHINE:$PORT_SQUID:$USER_SQUID:$PASS_SQUID"
echo -e "\e[1;33m━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
