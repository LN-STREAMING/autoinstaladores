#!/bin/bash

# Atualiza pacotes e instala o Squid
apt update -y && apt install -y squid apache2-utils

# Define a porta do Squid
SQUID_PORT="12554"

# Caminho do arquivo de configuração do Squid
SQUID_CONF="/etc/squid/squid.conf"

# Limpa a configuração antiga e adiciona a nova
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

# Cria usuário e senha
htpasswd -c -b /etc/squid/passwd ikariam mairaki

# Reinicia o Squid
systemctl restart squid
systemctl enable squid

# Obtém o IP do servidor
IP=$(curl -s ifconfig.me)

# Exibe os dados de conexão
echo "--------------------------------------"
echo "Squid Proxy instalado com sucesso!"
echo "Use os seguintes dados para conexão:"
echo "$IP:$SQUID_PORT:ikariam:mairaki"
echo "--------------------------------------"
