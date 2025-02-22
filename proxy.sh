#!/bin/bash

# Função para exibir mensagens formatadas
log() {
    echo -e "\e[1;32m[INFO] $1\e[0m"
}

# Atualizar pacotes e instalar Squid e Apache2-utils
log "Atualizando pacotes e instalando Squid..."
sudo apt update -y && sudo apt install -y squid apache2-utils

# Criar usuário e senha para autenticação sem interação manual
log "Criando usuário para o Squid..."
echo "ikariam:mairaki" | sudo tee /etc/squid/passwords > /dev/null
sudo chmod 640 /etc/squid/passwords

# Criar backup da configuração original do Squid
log "Fazendo backup da configuração original do Squid..."
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Criar nova configuração do Squid
log "Configurando Squid..."
sudo tee /etc/squid/squid.conf > /dev/null <<EOF
http_port 12554
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

# Reiniciar o serviço do Squid
log "Reiniciando Squid..."
sudo systemctl restart squid

log "Instalação concluída! O Squid está rodando na porta 12554."
