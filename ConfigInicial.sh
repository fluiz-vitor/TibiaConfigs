#!/bin/bash

set -e  # Encerra o script se qualquer comando falhar

echo "==> Atualizando pacotes..."
sudo apt update -qq > /dev/null
sudo apt upgrade -y -qq > /dev/null

echo "==> Instalando pacotes necessários..."
sudo apt install -y -qq \
  pciutils \
  ttf-mscorefonts-installer \
  gedit \
  python3-tk python3-dev \
  xdotool \
  libxkbcommon-x11-0 libxcb-cursor0 \
  git-all \
  pipx \
  ffmpeg libavcodec-extra \
  libevent-dev \
  unzip > /dev/null

echo "==> Instalando Poetry com pipx..."
sudo pipx install poetry > /dev/null || echo "❗ Falha ao instalar via pipx (pode já estar instalado)."

echo "==> Instalando Poetry com python3..."
sudo apt install -y python3-poetry > /dev/null || echo "❗ Poetry via apt já instalado ou falhou."

echo "==> Modificando /etc/fonts/fonts.conf para melhorar renderização da Verdana..."
sudo touch /etc/fonts/fonts.conf

if ! grep -q "<string>Verdana</string>" /etc/fonts/fonts.conf; then
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
else
  echo "==> O trecho já existe no arquivo. Nenhuma alteração feita."
fi

echo "==> Atualizando cache de fontes..."
sudo fc-cache -f > /dev/null

echo "==> Desabilitando teclas de acessibilidade no Xfce..."
if command -v xfconf-query >/dev/null; then
  xfconf-query -c xfwm4 -p /general/easy_click -s false || echo "❗ Falha ao desabilitar Easy Click"
  xfconf-query -c xfwm4 -p /general/use_compositing -s true
else
  echo "⚠️ xfconf-query não encontrado. Pulei configuração de acessibilidade no Xfce."
fi

echo "==> Desativando notificações do sistema (Xfce)..."
if command -v xfconf-query >/dev/null; then
  if xfconf-query -c xfce4-notifyd -p /do-not-disturb >/dev/null 2>&1; then
    xfconf-query -c xfce4-notifyd -p /do-not-disturb -s true
  else
    xfconf-query -c xfce4-notifyd -p /do-not-disturb --create -t bool -s true
  fi
  echo "==> Notificações desativadas."
else
  echo "⚠️ xfconf-query não encontrado. Pulei configuração de notificações."
fi

echo "==> Configurando apenas 1 workspace ativo (Xfce)..."
if command -v xfconf-query >/dev/null; then
  xfconf-query -c xfwm4 -p /general/workspace_count -s 1 || echo "❗ Falha ao definir número de workspaces"
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super+Page_Up>" -r
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super+Page_Down>" -r
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Control+Alt+Right>" -r
  xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Control+Alt+Left>" -r
  echo "==> Workspaces limitados a 1 e atalhos de troca desativados."
else
  echo "⚠️ xfconf-query não encontrado. Pulei configuração de workspaces."
fi

echo "==> Baixando cliente Tibia..."
wget -q https://static.tibia.com/download/tibia.x64.tar.gz -O tibia.x64.tar.gz

echo "==> Extraindo cliente Tibia na Área de Trabalho..."
tar -xzf tibia.x64.tar.gz
rm tibia.x64.tar.gz

echo "==> Baixando minimap do TibiaMaps (sem marcadores)..."
cd /tmp
wget -q https://tibiamaps.io/downloads/minimap-without-markers -O minimap.zip

echo "==> Extraindo minimap no diretório de dados do Tibia..."
MINIMAP_DEST="$HOME/.local/share/CipSoft GmbH/Tibia/packages/Tibia/"
mkdir -p "$MINIMAP_DEST"
unzip -o minimap.zip -d "$MINIMAP_DEST" > /dev/null
rm minimap.zip

echo "✅ Script concluído com sucesso!"
