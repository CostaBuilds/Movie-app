#!/bin/bash

# Lista de arquivos novos para adicionar
NEW_FILES=(
    "runrunapp/Core/Models/RunEvent.swift"
    "runrunapp/Core/Models/EventParticipant.swift"
    "runrunapp/Core/Services/RunEventService.swift"
    "runrunapp/Core/ViewModels/RunEventViewModel.swift"
    "runrunapp/Core/Views/Events/EventMapView.swift"
    "runrunapp/Core/Views/Events/EventDetailView.swift"
    "runrunapp/Core/Views/Events/ActiveEventView.swift"
)

echo "⚠️  IMPORTANTE:"
echo "Os seguintes arquivos precisam ser adicionados ao Xcode manualmente:"
echo ""
for file in "${NEW_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ $file (não encontrado)"
    fi
done
echo ""
echo "📌 Passos no Xcode:"
echo "1. Abra o projeto no Xcode"
echo "2. Para cada arquivo acima:"
echo "   - Clique com botão direito na pasta correspondente"
echo "   - Selecione 'Add Files to runrunapp...'"
echo "   - Marque 'Copy items if needed' e 'Add to targets: runrunapp'"
echo "3. Build o projeto (Cmd+B)"
