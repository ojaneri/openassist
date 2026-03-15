#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENASSIST_DIR="$HOME/.openassist"

# Verifica OPENROUTER_API_KEY
if [ -z "$OPENROUTER_API_KEY" ]; then
    echo ""
    echo "⚠  OPENROUTER_API_KEY não encontrada no ambiente."
    echo ""
    read -rp "Digite sua chave OpenRouter API: " input_key
    if [ -z "$input_key" ]; then
        echo "Erro: nenhuma chave fornecida. Abortando."
        exit 1
    fi
    export OPENROUTER_API_KEY="$input_key"

    # Persiste na shell do usuário
    SHELL_RC=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    elif [ -f "$HOME/.profile" ]; then
        SHELL_RC="$HOME/.profile"
    fi

    if [ -n "$SHELL_RC" ]; then
        if ! grep -q "OPENROUTER_API_KEY" "$SHELL_RC" 2>/dev/null; then
            echo "" >> "$SHELL_RC"
            echo "export OPENROUTER_API_KEY='$input_key'" >> "$SHELL_RC"
            echo "✓ Chave salva em $SHELL_RC"
        fi
    fi
fi

# Cria diretório ~/.openassist/
mkdir -p "$OPENASSIST_DIR"

# Copia arquivos skill-* do diretório do repositório para ~/.openassist/
copied=0
for skill_file in "$SCRIPT_DIR"/skill-*; do
    if [ -f "$skill_file" ]; then
        cp "$skill_file" "$OPENASSIST_DIR/"
        copied=$((copied + 1))
    fi
done

if [ "$copied" -gt 0 ]; then
    echo "✓ $copied skill(s) copiada(s) para $OPENASSIST_DIR"
fi

# Instala o binário em /opt/openassist e coloca no PATH
INSTALL_DIR="/opt/openassist"
sudo mkdir -p "$INSTALL_DIR"
sudo cp "$SCRIPT_DIR/openassist" "$INSTALL_DIR/openassist"
sudo chmod +x "$INSTALL_DIR/openassist"

# Adiciona /opt/openassist ao PATH se ainda não estiver
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    SHELL_RC_PATH=""
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_RC_PATH="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC_PATH="$HOME/.bashrc"
    elif [ -f "$HOME/.profile" ]; then
        SHELL_RC_PATH="$HOME/.profile"
    fi

    if [ -n "$SHELL_RC_PATH" ]; then
        if ! grep -q "$INSTALL_DIR" "$SHELL_RC_PATH" 2>/dev/null; then
            echo "" >> "$SHELL_RC_PATH"
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC_PATH"
            echo "✓ $INSTALL_DIR adicionado ao PATH em $SHELL_RC_PATH"
        fi
    fi
    export PATH="$INSTALL_DIR:$PATH"
fi

echo "✓ openassist instalado em $INSTALL_DIR"

# Executa openassist
exec "$INSTALL_DIR/openassist" "$@"
