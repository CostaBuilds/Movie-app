# 🔄 Guia de Migração - SwiftData Schema Changes

## ⚠️ Problema

Quando você adiciona, remove ou modifica propriedades nos modelos SwiftData (`@Model`), o app pode crashar com:

```
Failed to configure SwiftData container: SwiftDataError(_error: SwiftData.SwiftDataError._Error.loadIssueModelContainer)
```

**Causa**: O schema do banco de dados mudou, mas o SwiftData ainda tem dados salvos com o schema antigo.

## ✅ Solução Automática

O app agora tem **migração automática**! Quando detecta uma mudança de schema:

1. ⚠️ Detecta o erro de migração
2. 🗑️ Deleta os arquivos antigos do banco de dados
3. 🔄 Recria o container com o novo schema
4. ✅ App inicia normalmente (dados antigos serão perdidos)

### Logs no Console

Você verá algo assim no Xcode Console:

```
⚠️ SwiftData migration error: ...
🔄 Deletando store antigo e recriando...
🗑️ Arquivos antigos deletados
✅ Container recriado com sucesso!
```

## 🛠️ Solução Manual (se necessário)

### Opção 1: Script de Limpeza

Execute o script:

```bash
./clear_app_data.sh
```

Isso vai:
- Encontrar simuladores em execução
- Desinstalar o app
- Limpar todos os dados

### Opção 2: Deletar App Manualmente

**No Simulador**:
1. Mantenha pressionado o ícone do app
2. Clique em "Remove App" → "Delete App"
3. Rebuild no Xcode (Cmd + R)

**No Dispositivo Físico**:
1. Configurações → Geral → Armazenamento do iPhone
2. Encontre "RunRunApp" → Excluir App
3. Rebuild no Xcode

### Opção 3: Reset Simulador Completo

```bash
xcrun simctl erase all
```

⚠️ **CUIDADO**: Isso reseta TODOS os simuladores!

## 📝 Mudanças Recentes no Schema

### Run Model
- ✅ Adicionado: `isHighlighted: Bool` (para corridas em destaque no perfil)

## 🔮 Futuro: Schema Versionado

Para produção, vamos implementar:
- `VersionedSchema` do SwiftData
- `SchemaMigrationPlan` para migrações sem perda de dados
- Testes de migração automatizados

## 💡 Dicas de Desenvolvimento

1. **Durante desenvolvimento**: Migração automática é OK (perda de dados)
2. **Em produção**: Sempre use `SchemaMigrationPlan` para preservar dados dos usuários
3. **Teste sempre**: Após mudanças no schema, delete o app e reinstale

## 🐛 Troubleshooting

### App ainda crasha após migração automática?

1. Limpe o build folder: Xcode → Product → Clean Build Folder (Cmd + Shift + K)
2. Delete Derived Data:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. Restart Xcode
4. Delete o app manualmente do simulador
5. Rebuild

### Container fica em memória?

Se você ver: `✅ Container em memória criado`

Isso significa que a migração falhou e o app está usando armazenamento temporário.

**Dados serão perdidos ao fechar o app!**

Solução: Delete o app e reinstale.

---

**Criado em**: 13 Jan 2026
**Última atualização**: v1.0 - Adição de isHighlighted ao Run model
