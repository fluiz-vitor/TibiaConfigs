#!/bin/bash

set -e

echo "==> Verificando se xfonts-terminus está instalado..."
if dpkg -l | grep -q "^ii\s\+xfonts-terminus"; then
    echo "==> Removendo a fonte xfonts-terminus..."
    sudo apt remove --purge -y xfonts-terminus > /dev/null 2>&1
else
    echo "==> xfonts-terminus não está instalado. Pulando remoção."
fi

echo "==> Atualizando a lista de pacotes..."
sudo apt update > /dev/null 2>&1

echo "==> Verificando se a fonte Verdana já está instalada..."
if fc-list | grep -qi "verdana"; then
    echo "==> Verdana já está instalada. Pulando instalação."
else
    echo "==> Instalando a fonte Verdana (via ttf-mscorefonts-installer)..."
    sudo apt install -y ttf-mscorefonts-installer
fi

echo "==> Verificando e atualizando configuração de fontes"
if [ -f /etc/fonts/fontsverdana.conf ]; then
    echo "==> Backup de configuração encontrado. Substituindo arquivos de configuração de fontes..."
    sudo mv /etc/fonts/fonts.conf /etc/fonts/fontsterminus.conf > /dev/null 2>&1
    sudo mv /etc/fonts/fontsverdana.conf /etc/fonts/fonts.conf > /dev/null 2>&1
else
    echo "==> Nenhum backup encontrado. Adicionando configuração de hinting para Verdana ao fonts.conf..."
    sudo sed -i '$i \
  <match target="font">\
    <test name="family" compare="contains">\
      <string>Verdana</string>\
    </test>\
    <edit name="hintstyle" mode="assign">\
      <const>hintfull</const>\
    </edit>\
  </match>' /etc/fonts/fonts.conf > /dev/null 2>&1
    echo "==> Trecho de configuração de fonte adicionado."
fi

echo "==> Atualizando o cache de fontes..."
sudo fc-cache -fv > /dev/null 2>&1

echo "==> Concluído."
