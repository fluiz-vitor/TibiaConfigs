#!/bin/bash

set -e

echo "==> Removendo fonte Terminus..."
sudo apt remove --purge -y xfonts-terminus || true

echo "==> Removendo arquivos da fonte Terminus dos diretórios comuns..."
find /usr/share/fonts -iname "*terminus*" -exec sudo rm -v {} \;
find /usr/local/share/fonts -iname "*terminus*" -exec sudo rm -v {} \;

# Diretórios do usuário onde fontes podem estar
for DIR in ~/.fonts ~/.local/share/fonts; do
    if [ -d "$DIR" ]; then
        echo "==> Removendo Terminus do diretório $DIR..."
        find "$DIR" -iname "*terminus*" -exec rm -v {} \;
    fi
done

echo "==> Fazendo backup de /etc/fonts/fonts.conf (se ainda não existir)..."
sudo cp -n /etc/fonts/fonts.conf /etc/fonts/fonts.conf.bak

echo "==> Removendo trecho relacionado à fonte Terminus do /etc/fonts/fonts.conf..."
sudo sed -i '/<match target="font">/,/<\/match>/ {
    /<string>Terminus<\/string>/,/<\/match>/d
}' /etc/fonts/fonts.conf

echo "==> Instalando fonte Verdana..."
sudo apt update
sudo apt install -y ttf-mscorefonts-installer

# Bloco de substituição Terminus → Verdana
FONT_REPLACE_XML='<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="pattern">
        <test qual="any" name="family">
            <string>Terminus</string>
        </test>
        <edit name="family" mode="assign" binding="strong">
            <string>Verdana</string>
        </edit>
    </match>

    <!-- Mapeia Terminus Bold para Verdana Bold -->
    <match target="pattern">
        <test name="family" qual="any">
            <string>Terminus</string>
        </test>
        <test name="weight" compare="more_eq">
            <int>200</int>
        </test>
        <edit name="family" mode="assign">
            <string>Verdana</string>
        </edit>
    </match>
</fontconfig>
'

echo "==> Criando configuração local (usuário) para substituição de Terminus por Verdana..."
mkdir -p ~/.config/fontconfig
echo "$FONT_REPLACE_XML" > ~/.config/fontconfig/fonts.conf

echo "==> Criando configuração global (todos os usuários) para substituição de Terminus por Verdana..."
echo "$FONT_REPLACE_XML" | sudo tee /etc/fonts/conf.d/99-terminus-to-verdana.conf > /dev/null

echo "==> Atualizando cache de fontes..."
fc-cache -f -v

echo "==> Fonte Terminus removida e substituída por Verdana com sucesso (local e globalmente)."
