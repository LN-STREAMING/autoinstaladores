#!/bin/bash

# Script para alterar a senha do usuário root

echo "Digite a nova senha para o usuário root:"
read -s nova_senha

# Usando sudo para garantir que o comando tenha permissão de root
echo "root:$nova_senha" | sudo chpasswd

echo "Senha do root alterada com sucesso!"
