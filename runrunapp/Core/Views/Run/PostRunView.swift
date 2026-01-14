import SwiftUI
import MapKit

struct PostRunView: View {
    let run: Run
    @Environment(\.dismiss) private var dismiss
    
    @State private var caption = ""
    @State private var selectedGroupIds: Set<String> = []
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Mapa da rota
                    runMapPreview
                    
                    // Stats cards
                    statsGrid
                    
                    // Splits
                    if let splitsData = run.splitsData,
                       let splits = try? JSONDecoder().decode([Split].self, from: splitsData) {
                        splitsSection(splits: splits)
                    }
                    
                    // Caption
                    captionSection
                    
                    // Foto (opcional)
                    photoSection
                    
                    // Selecionar grupos
                    // TODO: Implementar depois
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Corrida Concluída")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Compartilhar") {
                        shareRun()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Map Preview
    private var runMapPreview: some View {
        VStack {
            if let routeData = run.routeData,
               let coordinates = try? JSONDecoder().decode([Coordinate].self, from: routeData),
               !coordinates.isEmpty {
                
                let locations = coordinates.map { $0.toCLLocation() }
                let center = locations[locations.count / 2].coordinate
                let mapRegion = MKCoordinateRegion(
                    center: center,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                
                Map(coordinateRegion: .constant(mapRegion), showsUserLocation: false)
                    .frame(height: 200)
                    .cornerRadius(16)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .cornerRadius(16)
                    .overlay(
                        Text("Sem dados de rota")
                            .foregroundColor(.secondary)
                    )
            }
        }
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                icon: "figure.run",
                label: "Distância",
                value: String(format: "%.2f", run.distanceInKm),
                unit: "km",
                color: .blue
            )
            
            StatCard(
                icon: "clock",
                label: "Tempo",
                value: run.durationFormatted,
                unit: "",
                color: .orange
            )
            
            StatCard(
                icon: "speedometer",
                label: "Pace Médio",
                value: run.paceFormatted,
                unit: "/km",
                color: .cyan
            )
            
            if let calories = run.calories {
                StatCard(
                    icon: "flame",
                    label: "Calorias",
                    value: "\(calories)",
                    unit: "kcal",
                    color: .red
                )
            }
        }
    }
    
    // MARK: - Splits Section
    private func splitsSection(splits: [Split]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Splits")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(splits) { split in
                    HStack {
                        Text("Km \(split.km)")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(split.timeFormatted)
                            .foregroundColor(.secondary)
                        
                        Text(split.paceFormatted)
                            .foregroundColor(.cyan)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Caption Section
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Como foi a corrida?")
                .font(.headline)
            
            TextField("Adicione uma descrição...", text: $caption, axis: .vertical)
                .textFieldStyle(.plain)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .lineLimit(3...6)
        }
    }
    
    // MARK: - Photo Section
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Foto")
                .font(.headline)
            
            Button(action: {
                showingImagePicker = true
            }) {
                HStack {
                    Image(systemName: "camera")
                    Text("Adicionar foto")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Actions
    private func shareRun() {
        // TODO: Implementar compartilhamento
        print("Compartilhar corrida: \(run.id)")
        dismiss()
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    PostRunView(run: Run(
        userId: "test",
        date: Date(),
        distance: 5420,
        duration: 1800,
        averagePace: 5.5
    ))
}
