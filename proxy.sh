#!/bin/bash

# Atualizar pacotes e instalar Squid e Apache2-utils
echo "Atualizando pacotes e instalando Squid..."
sudo apt update && sudo apt install squid apache2-utils -y

# Criar usuário e senha para autenticação
echo "Criando usuário para o Squid..."
sudo htpasswd -c /etc/squid/passwords ikariam <<EOF
mairaki
mairaki
EOF

# Criar backup da configuração original do Squid
echo "Fazendo backup da configuração original do Squid..."
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

# Criar nova configuração do Squid
echo "Configurando Squid..."
sudo bash -c 'cat > /etc/squid/squid.conf <<EOF
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
EOF'

# Reiniciar o serviço do Squid
echo "Reiniciando Squid..."
sudo systemctl restart squid

echo "Instalação concluída! O Squid está rodando na porta 12554."
