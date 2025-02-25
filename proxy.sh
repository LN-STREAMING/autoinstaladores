#!/bin/bash

clear

# Função para exibir mensagens formatadas
log() {
    echo -e "\e[1;32m[INFO] $1\e[0m"
}

# Verifica se um comando falhou
check_command() {
    if [ $? -ne 0 ]; then
        echo -e "\e[1;31m[ERRO] $1 falhou. Verifique os logs acima.\e[0m"
        exit 1
    fi
}

# Atualizar pacotes e instalar Squid e Apache2-utils
log "🔄 Atualizando pacotes..."
sudo apt update -y
check_command "Atualização de pacotes"

log "📦 Instalando Squid e Apache2-utils..."
sudo apt install -y squid apache2-utils
check_command "Instalação do Squid"

# Criar usuário e senha para autenticação sem interação manual
log "🔑 Criando usuário para o Squid..."
USER_SQUID="ikariam"
PASS_SQUID="mairaki"

# Remove arquivo de senhas anterior (se existir) e recria
sudo rm -f /etc/squid/passwords
echo "$PASS_SQUID" | sudo htpasswd -ci /etc/squid/passwords "$USER_SQUID"
check_command "Criação do usuário Squid"

sudo chmod 640 /etc/squid/passwords
log "✅ Usuário criado com sucesso!"

# Criar backup da configuração original do Squid
if [ ! -f "/etc/squid/squid.conf.bak" ]; then
    log "📂 Criando backup da configuração original..."
    sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak
fi

# Criar nova configuração do Squid
log "⚙️ Aplicando nova configuração do Squid..."
PORT_SQUID="12554"
sudo tee /etc/squid/squid.conf > /dev/null <<EOF
http_port $PORT_SQUID
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwords
auth_param basic realm Proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated

# Remover o hostname visível
visible_hostname unknown

# Evitar que o Squid adicione cabeçalhos identificáveis
forwarded_for off
via off
request_header_access From deny all
request_header_access Server deny all
request_header_access WWW-Authenticate deny all

# Configurar DNS para evitar detecção
dns_nameservers 8.8.8.8 8.8.4.4
tcp_outgoing_address 0.0.0.0

# Melhor controle de segurança
acl Safe_ports port 80
acl Safe_ports port 443
http_access deny !Safe_ports

request_header_access Via deny all
request_header_access Forwarded-For deny all
request_header_access X-Forwarded-For deny all
request_header_access Referer deny all
request_header_access Accept-Encoding deny all
request_header_access Accept deny all
forwarded_for delete
via off

access_log none
cache_log /dev/null
cache_store_log none
EOF
check_command "Configuração do Squid"

# Reiniciar o serviço do Squid
log "🔄 Reiniciando Squid..."
sudo systemctl restart squid
check_command "Reinício do Squid"

# Habilitar Squid na inicialização
sudo systemctl enable squid
log "✅ Squid habilitado para iniciar automaticamente!"

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
