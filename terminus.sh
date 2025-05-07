#!/bin/bash

set -e

echo "==> Verificando se Verdana está instalada..."
if fc-list | grep -iq "verdana"; then
    echo "==> Verdana encontrada. Removendo pacotes de fontes da Microsoft..."
    sudo apt remove --purge -y ttf-mscorefonts-installer msttcorefonts > /dev/null 2>&1

    echo "==> Removendo arquivos da fonte Verdana dos diretórios comuns..."
    find /usr/share/fonts -iname "*verdana*" -exec sudo rm -v {} \; > /dev/null 2>&1
    find /usr/local/share/fonts -iname "*verdana*" -exec sudo rm -v {} \; > /dev/null 2>&1
else
    echo "==> Verdana não encontrada. Pulando remoção."
fi

echo "==> Verificando se /etc/fonts/fontsterminus.conf existe..."
if [ -f /etc/fonts/fontsterminus.conf ]; then
    echo "==> fontsterminus.conf encontrado. Alternando configurações..."
    sudo mv /etc/fonts/fonts.conf /etc/fonts/fontsverdana.conf > /dev/null 2>&1
    sudo mv /etc/fonts/fontsterminus.conf /etc/fonts/fonts.conf > /dev/null 2>&1
else
    echo "==> fontsterminus.conf não encontrado. Criando novo fonts.conf..."
    echo "==> Fazendo backup do /etc/fonts/fonts.conf..."
    sudo cp /etc/fonts/fonts.conf /etc/fonts/fontsverdana.conf > /dev/null 2>&1

    echo "==> Substituindo conteúdo de /etc/fonts/fonts.conf com nova configuração..."
    sudo tee /etc/fonts/fonts.conf > /dev/null << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
    <description>Default configuration file</description>
    <dir>/usr/share/fonts</dir>
    <dir>/usr/local/share/fonts</dir>
    <dir prefix="xdg">fonts</dir>
    <dir>~/.fonts</dir>

    <match target="pattern">
        <test qual="any" name="family">
            <string>mono</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>monospace</string>
        </edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family">
            <string>sans serif</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>sans-serif</string>
        </edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family">
            <string>sans</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>sans-serif</string>
        </edit>
    </match>

    <match target="pattern">
        <test qual="any" name="family">
            <string>system ui</string>
        </test>
        <edit name="family" mode="assign" binding="same">
            <string>system-ui</string>
        </edit>
    </match>

    <selectfont><rejectfont><glob>*.dpkg-tmp</glob></rejectfont></selectfont>
    <selectfont><rejectfont><glob>*.dpkg-new</glob></rejectfont></selectfont>

    <include ignore_missing="yes">conf.d</include>
    <cachedir>/var/cache/fontconfig</cachedir>
    <cachedir prefix="xdg">fontconfig</cachedir>
    <cachedir>~/.fontconfig</cachedir>

    <config>
        <rescan><int>30</int></rescan>
    </config>

    <match target="pattern">
        <test qual="any" name="family">
            <string>Verdana</string>
        </test>
        <edit name="family" mode="assign" binding="strong">
            <string>Terminus</string>
        </edit>
    </match>

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
EOF
fi

echo "==> Instalando fonte Terminus..."
sudo apt update > /dev/null 2>&1
sudo apt install -y xfonts-terminus > /dev/null 2>&1

echo "==> Criando diretório de configuração local de fontes se necessário..."
mkdir -p ~/.config/fontconfig > /dev/null 2>&1

LOCAL_FONTS_CONF=~/.config/fontconfig/fonts.conf

if [ -f "$LOCAL_FONTS_CONF" ]; then
    echo "==> Configuração local já existe em $LOCAL_FONTS_CONF. Mantendo arquivo original."
else
    echo "==> Criando configuração local para substituir Verdana por Terminus..."
    cat > "$LOCAL_FONTS_CONF" << EOF
<?xml version="1.0"?>
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
EOF
fi

echo "==> Atualizando cache de fontes..."
fc-cache -f -v > /dev/null 2>&1

echo "==> Remoção da Verdana e substituição por Terminus concluída com sucesso."
