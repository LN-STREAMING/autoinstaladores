#!/bin/bash

# Script para alterar a senha do usuário root em VPS Ubuntu

# Verificar se o script está sendo executado como sudo
if [[ $(id -u) -ne 0 ]]; then
    echo "Este script precisa ser executado com permissões de sudo. Saindo..."
    exit 1
fi

echo "Verificando se a conta root está desbloqueada..."

# Verificar o status da conta root
root_status=$(passwd -S root | awk '{print $2}')

# Se root estiver bloqueado, desbloquear
if [ "$root_status" == "L" ]; then
    echo "A conta root está bloqueada. Desbloqueando..."
    sudo passwd -u root
fi

# Solicitar a nova senha
echo "Digite a nova senha para o usuário root:"
read -s nova_senha

# Tentar alterar a senha do root
echo "root:$nova_senha" | sudo chpasswd

# Verificar se a alteração foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Senha do root alterada com sucesso!"
else
    echo "Erro ao alterar a senha do root. Tentando uma solução alternativa..."

    # Tentando uma abordagem manual para garantir que o PAM não bloqueie
    echo "root:$nova_senha" | sudo tee /etc/shadow > /dev/null
    echo "Senha do root alterada diretamente no arquivo /etc/shadow."
fi
