#!/bin/bash

clear
echo "Atualizando pacotes..."
apt update -y > /dev/null 2>&1 && apt install -y squid apache2-utils > /dev/null 2>&1
echo "Pacotes instalados!"

SQUID_PORT="12554"
SQUID_CONF="/etc/squid/squid.conf"

echo "Configurando Squid..."
cat <<EOF > $SQUID_CONF
http_port $SQUID_PORT

# Permitir todo tráfego
acl all src all
http_access allow all

# Outras configurações essenciais
visible_hostname livetim.tim.com.br
logfile_rotate 5

# Remover cabeçalhos que denunciam proxy
forwarded_for off
via off
request_header_access X-Forwarded-For deny all
request_header_access Proxy-Authorization deny all
request_header_access Proxy-Connection deny all
request_header_access Via deny all
request_header_access Forwarded deny all
request_header_access From deny all

# Configuração de DNS (use Cloudflare e Google)
dns_nameservers 1.1.1.1 8.8.8.8

# Saída de rede dinâmica
tcp_outgoing_address 0.0.0.0

# Portas permitidas
acl Safe_ports port 80
acl Safe_ports port 443
http_access deny !Safe_ports

# Configuração de autenticação
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm Proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
EOF
echo "Configuração aplicada!"

echo "Criando usuário de autenticação..."
htpasswd -c -b /etc/squid/passwd ikariam mairaki > /dev/null 2>&1
echo "Usuário criado!"

echo "Reiniciando Squid..."
systemctl restart squid && systemctl enable squid > /dev/null 2>&1
echo "Squid iniciado!"

IP=$(curl -s ifconfig.me)
echo "--------------------------------------"
echo "Squid Proxy instalado com sucesso!"
echo "Use os seguintes dados para conexão:"
echo "$IP:$SQUID_PORT:ikariam:mairaki"
echo "--------------------------------------"
