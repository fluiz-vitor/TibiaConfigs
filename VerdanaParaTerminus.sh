#!/bin/bash

set -e

echo "==> Removendo pacotes de fontes da Microsoft (incluindo Verdana)..."
sudo apt remove --purge -y ttf-mscorefonts-installer msttcorefonts || true

echo "==> Removendo arquivos da fonte Verdana dos diretórios comuns..."
find /usr/share/fonts -iname "*verdana*" -exec sudo rm -v {} \;
find /usr/local/share/fonts -iname "*verdana*" -exec sudo rm -v {} \;

# Diretórios do usuário onde fontes podem estar
for DIR in ~/.fonts ~/.local/share/fonts; do
    if [ -d "$DIR" ]; then
        echo "==> Removendo Verdana do diretório $DIR..."
        find "$DIR" -iname "*verdana*" -exec rm -v {} \;
    fi
done

echo "==> Fazendo backup de /etc/fonts/fonts.conf (se ainda não existir)..."
sudo cp -n /etc/fonts/fonts.conf /etc/fonts/fonts.conf.bak

echo "==> Removendo trecho relacionado à fonte Verdana do /etc/fonts/fonts.conf..."
sudo sed -i '/<match target="font">/,/<\/match>/ {
    /<string>Verdana<\/string>/,/<\/match>/d
}' /etc/fonts/fonts.conf

echo "==> Instalando fonte Terminus..."
sudo apt update
sudo apt install -y xfonts-terminus

# Bloco de substituição Verdana → Terminus
FONT_REPLACE_XML='<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="pattern">
        <test qual="any" name="family">
            <string>Verdana</string>
        </test>
        <edit name="family" mode="assign" binding="strong">
            <string>Terminus</string>
        </edit>
    </match>

    <!-- Mapeia Verdana Bold para Terminus Bold -->
    <match target="pattern">
        <test name="family" qual="any">
            <string>Verdana</string>
        </test>
        <test name="weight" compare="more_eq">
            <int>200</int>
        </test>
        <edit name="family" mode="assign">
            <string>Terminus</string>
        </edit>
    </match>
</fontconfig>
'

echo "==> Criando configuração local (usuário) para substituição de Verdana por Terminus..."
mkdir -p ~/.config/fontconfig
echo "$FONT_REPLACE_XML" > ~/.config/fontconfig/fonts.conf

echo "==> Criando configuração global (todos os usuários) para substituição de Verdana por Terminus..."
echo "$FONT_REPLACE_XML" | sudo tee /etc/fonts/conf.d/99-verdana-to-terminus.conf > /dev/null

echo "==> Atualizando cache de fontes..."
fc-cache -f -v

echo "==> Fonte Verdana removida e substituída por Terminus com sucesso (local e globalmente)."
