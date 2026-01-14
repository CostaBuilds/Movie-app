# 🎯 Sistema de Eventos de Corrida (Raids)

Sistema similar às Raids do Pokémon GO, onde usuários podem participar de eventos de corrida em localizações específicas com tempo limitado.

## 📋 Visão Geral

### Conceito
- **Eventos com localização fixa**: Pontos marcados no mapa (ex: parques, orlas)
- **Tempo limitado**: Eventos com hora de início e fim
- **Zona de participação**: Círculo geográfico de 100-200m de raio
- **Tracking em tempo real**: Métricas atualizadas durante o evento
- **Leaderboard ao vivo**: Ranking dos participantes
- **Recompensas**: Pontos e badges por participação

## 🏗️ Arquitetura

### Modelos de Dados

#### RunEvent (`@Model`)
Representa um evento de corrida:
- **Localização**: latitude, longitude, raio
- **Timing**: startTime, endTime, duration
- **Detalhes**: nome, descrição, tipo, dificuldade
- **Participação**: min/max participantes, contador
- **Status**: "scheduled", "active", "completed"
- **Recompensas**: pontos, badges

#### EventParticipant (`@Model`)
Representa a participação de um usuário:
- **Identificação**: eventId, userId, userName
- **Métricas em tempo real**: distance, pace, duration
- **Status de zona**: isInsideZone, enteredZoneAt
- **Ranking**: currentRank, pointsEarned
- **Progresso**: goalCompleted, badges

### Serviços

#### RunEventService
Gerencia geolocalização e detecção:
- **CLLocationManager** para GPS
- **Geofencing** com círculos para cada evento
- **Detecção de entrada/saída** da zona
- **Notificações locais** para alertas
- **Cálculo de distância** até o centro do evento

Principais métodos:
```swift
func findNearbyEvents(allEvents: [RunEvent])
func joinEvent(_ event: RunEvent)
func checkIfInsideZone()
func updateParticipantLocation(...)
```

### ViewModels

#### RunEventViewModel
Gerencia estado e lógica de negócio:
- **Lista de eventos**: all, nearby, active, upcoming
- **Evento atual**: activeEvent, participants
- **Estado de localização**: isInsideZone, distanceToEvent
- **Ações**: joinEvent, leaveEvent, updateMetrics

## 📱 Interface do Usuário

### 1. EventMapView (Mapa de Eventos)
**Tela principal** para visualizar eventos próximos:

**Features:**
- Mapa interativo com MapKit
- Marcadores personalizados para cada evento
- Círculos mostrando a zona de participação
- Overlay horizontal com cards dos eventos
- Filtros: eventos ativos vs agendados
- Botão para centralizar no usuário

**UI Components:**
- `EventMarker`: Pin personalizado com emoji e status
- `EventCard`: Card horizontal com info resumida
- Animação de "pulse" em eventos ativos

### 2. EventDetailView (Detalhes do Evento)
**Modal** com informações completas:

**Seções:**
- **Hero**: Mapa preview + título + status
- **Info Grid**: Horário, duração, participantes, meta, dificuldade
- **Participantes**: Lista horizontal com avatares e stats
- **Recompensas**: Pontos base + bônus
- **CTA**: Botão "Participar" ou "Entrar agora"

**Validações:**
- Evento lotado (maxParticipants)
- Distância máxima para entrar (1km)
- Permissões de localização

### 3. ActiveEventView (Tracking ao Vivo)
**Fullscreen** durante participação ativa:

**Layout:**
- **Mapa background**: Posição do usuário + zona + outros participantes
- **Top bar**: Nome do evento + tempo restante + indicador de zona
- **Stats cards**: Distância, tempo, pace, ranking
- **Alerta**: Banner vermelho quando fora da zona
- **Controles**: Ranking, centralizar, sair

**Features em tempo real:**
- Atualização de métricas a cada 5s
- Indicador visual: dentro/fora da zona
- Distância até o centro
- Leaderboard com outros participantes
- Haptic feedback em entrada/saída

### 4. LeaderboardView (Ranking)
**Modal** dentro do ActiveEventView:

- Lista ordenada por distância
- Top 3 com destaque (ouro/prata/bronze)
- Stats: distância, pace
- Indicador de quem está na zona

## 🔔 Notificações

### Tipos de Notificação
1. **Evento próximo**: "Evento começando em 15min perto de você!"
2. **Entrada na zona**: "Você entrou na zona! 🎯"
3. **Saída da zona**: "Você saiu da zona ⚠️"
4. **Evento iniciado**: "Sprint Challenge começou!"
5. **Tempo acabando**: "5 minutos restantes"

### Implementação
- `UNUserNotificationCenter` para notificações locais
- Geofencing com `CLCircularRegion`
- Haptic feedback com `UINotificationFeedbackGenerator`

## 🎮 Fluxo de Uso

### 1. Descoberta
```
User abre app → EventMapView
→ Vê eventos próximos no mapa
→ Toca em um evento para detalhes
```

### 2. Participação
```
EventDetailView → Botão "Participar"
→ Validações (distância, permissões, vagas)
→ Cria EventParticipant
→ Abre ActiveEventView
```

### 3. Durante o Evento
```
ActiveEventView tracking GPS
→ Detecta entrada na zona → Notificação + Haptic
→ Atualiza métricas em tempo real
→ Sincroniza com leaderboard
→ Calcula pontos e ranking
```

### 4. Finalização
```
Evento termina ou user sai
→ Calcula pontos finais
→ Atualiza estatísticas
→ Mostra resumo e recompensas
```

## 🔥 Features Especiais

### Detecção Inteligente
- **Geofencing automático** para eventos próximos
- **Monitoramento em background** quando autorizado
- **Otimização de bateria** com distanceFilter

### Gamificação
- **Pontos base** por participação
- **Bônus** por completar meta (+50 pts)
- **Bônus** por tempo na zona (+2 pts/min)
- **Bônus** por ranking (1º: +100, 2º: +75, 3º: +50)
- **Badges** especiais por eventos

### Tipos de Evento
- **Social** 🎉: Corrida casual em grupo
- **Sprint** ⚡️: Desafio de velocidade
- **Endurance** 🔥: Corrida de resistência
- **Challenge** 🏆: Competição ranqueada

### Dificuldades
- **Easy** 🟢: 2-5km, pace livre
- **Medium** 🟠: 5-10km, pace moderado
- **Hard** 🔴: 10km+, pace intenso

## 📊 Dados Mock

### Eventos de Exemplo
1. **Corrida do Amanhecer** 🌅
   - Parque da Boa Vista
   - 6:00 - 7:00
   - 5km, fácil, 150 pontos

2. **Sprint Challenge** ⚡️
   - Orla de Boa Viagem
   - 18:00 - 18:30
   - 3km, difícil, 250 pontos

3. **Maratona Noturna** 🌙
   - Parque Dona Lindu
   - 20:00 - 21:00
   - 10km, difícil, 500 pontos

## 🚀 Próximos Passos

### Integração Firebase
1. **Firestore Collections**:
   - `runEvents/` - Eventos globais
   - `eventParticipants/{eventId}` - Participantes por evento
   - Real-time listeners para leaderboard ao vivo

2. **Firebase Functions**:
   - Auto-criação de eventos recorrentes
   - Cálculo de rankings no backend
   - Push notifications

3. **Firebase Storage**:
   - Imagens de eventos
   - Screenshots de conquistas

### Features Futuras
- [ ] Criar eventos customizados
- [ ] Eventos privados (somente grupo)
- [ ] Chat durante evento
- [ ] Replay de evento (mapa animado)
- [ ] Conquistas e badges persistentes
- [ ] Histórico de eventos participados
- [ ] Estatísticas agregadas
- [ ] Eventos patrocinados
- [ ] Integração com Apple Health
- [ ] Compartilhar no social

## 🎨 Design System

### Cores
- **Evento ativo**: Cyan (`#00FFFF`)
- **Agendado**: Cinza (`.systemGray`)
- **Zona (dentro)**: Verde/Cyan
- **Zona (fora)**: Vermelho
- **Recompensas**: Lima (`#C8FF00`)

### Ícones
- Mapa: `map.fill`
- Evento: emoji por tipo
- Zona: `checkmark` / `xmark`
- Ranking: `trophy.fill`
- Tempo: `clock.fill`

### Animações
- Pulse em marcadores ativos
- Fade in/out em cards
- Haptic em mudanças de zona
- Progress bar para tempo restante

## 📝 Permissões Necessárias

### Info.plist
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para mostrar eventos próximos</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Permitir localização em background para receber alertas de eventos</string>

<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
```

## 🧪 Testing

### Mock Data
- 3 eventos pré-configurados
- 5 participantes mock por evento
- Localização padrão: Recife (-8.0522, -34.8821)

### Como Testar
1. Build no simulador
2. Debug → Location → Custom Location
3. Inserir coordenadas próximas aos eventos mock
4. Navegar entre abas para ver eventos
5. Participar de um evento para testar tracking

---

**Status**: ✅ Implementação completa
**Data**: 2026-01-14
**Versão**: 1.0.0
