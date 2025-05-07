#!/bin/bash

set -e 

echo "==> Removendo a fonte xfonts-terminus..."
sudo apt remove --purge -y xfonts-terminus

echo "==> Atualizando a lista de pacotes..."
sudo apt update

echo "==> Instalando a fonte Verdana (via ttf-mscorefonts-installer)..."
sudo apt install -y ttf-mscorefonts-installer

# Verificando e atualizando configuração de fontes
if [ -f /etc/fonts/fontsbackup.conf ]; then
    echo "Backup de configuração encontrado. Substituindo arquivos de configuração de fontes..."
    sudo mv /etc/fonts/fonts.conf /etc/fonts/fontsterminus.conf
    sudo mv /etc/fonts/fontsbackup.conf /etc/fonts/fonts.conf
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
  </match>' /etc/fonts/fonts.conf
    echo "==> Trecho de configuração de fonte adicionado."
fi

echo "==> Atualizando o cache de fontes..."
sudo fc-cache -fv

echo "==> Remoção da fonte Terminus e substituição por Verdana concluída com sucesso."
