#!/bin/bash

# Script para alterar a senha do usuário root em VPS Ubuntu

echo "Verificando se a conta root está desbloqueada..."

# Verificar o status da conta root
root_status=$(sudo passwd -S root | awk '{print $2}')

# Se root estiver bloqueado, desbloquear
if [ "$root_status" == "L" ]; then
  echo "A conta root está bloqueada. Desbloqueando..."
  sudo passwd -u root
fi

# Solicitar a nova senha
echo "Digite a nova senha para o usuário root:"
read -s nova_senha

# Alterar a senha do root
echo "root:$nova_senha" | sudo chpasswd

# Confirmação
if [ $? -eq 0 ]; then
  echo "Senha do root alterada com sucesso!"
else
  echo "Erro ao alterar a senha do root. Verifique as permissões e tente novamente."
fi
