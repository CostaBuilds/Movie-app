#!/bin/bash

# Script para limpar dados do app no simulador
# Use quando houver mudanças no schema do SwiftData

echo "🧹 Limpando dados do app RunRunApp..."

# Encontrar todos os simuladores em execução
SIMULATORS=$(xcrun simctl list devices | grep "Booted" | grep -oE "[A-F0-9-]{36}")

if [ -z "$SIMULATORS" ]; then
    echo "⚠️  Nenhum simulador em execução"
    echo "📱 Por favor, inicie o simulador primeiro"
    exit 1
fi

# Para cada simulador em execução
for SIMULATOR_ID in $SIMULATORS; do
    echo "🔍 Procurando app no simulador $SIMULATOR_ID..."

    # Encontrar o bundle ID do app
    BUNDLE_ID="com.runrunapp.runrunapp"

    # Desinstalar o app
    xcrun simctl uninstall "$SIMULATOR_ID" "$BUNDLE_ID" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✅ App desinstalado com sucesso!"
    else
        echo "ℹ️  App não encontrado neste simulador"
    fi
done

echo ""
echo "✨ Pronto! Agora você pode buildar o app novamente com o schema atualizado"
echo "   Execute no Xcode: Cmd + R"
