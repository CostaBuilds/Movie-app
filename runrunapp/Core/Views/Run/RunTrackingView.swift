import SwiftUI
import MapKit
import SwiftData

struct RunTrackingView: View {
    @StateObject private var viewModel = RunTrackingViewModel()
    @Environment(\.modelContext) private var modelContext
    
    // Mock user ID (depois vem do Firebase Auth)
    private let userId = "mock-user-id"
    
    var body: some View {
        ZStack {
            // Mapa de fundo
            MapView(route: viewModel.route)
                .ignoresSafeArea()
            
            VStack {
                // Header com stats
                statsHeader
                
                Spacer()
                
                // Splits (se tiver)
                if !viewModel.splits.isEmpty {
                    splitsSection
                }
                
                Spacer()
                
                // Controles
                controlButtons
            }
            .padding()
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.requestPermission()
        }
        .sheet(isPresented: $viewModel.showingPostRunView) {
            if let run = viewModel.currentRun {
                PostRunView(run: run)
            }
        }
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        VStack(spacing: 12) {
            // Distância (principal)
            HStack {
                Text(viewModel.distanceText)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("km")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .offset(y: 10)
            }
            
            // Tempo e Pace
            HStack(spacing: 40) {
                statItem(label: "Tempo", value: viewModel.durationText)
                statItem(label: "Pace", value: viewModel.paceText)
            }
            
            // Pace atual (menor)
            if viewModel.isRunning && !viewModel.isPaused {
                Text("Pace atual: \(viewModel.currentPaceText) /km")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Splits Section
    private var splitsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Splits")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.splits) { split in
                        SplitCard(split: split)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        VStack(spacing: 16) {
            if !viewModel.isRunning {
                // Botão de iniciar
                Button(action: {
                    viewModel.startRun()
                }) {
                    HStack {
                        Image(systemName: "figure.run")
                        Text("Iniciar Corrida")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
            } else {
                // Botões durante corrida
                HStack(spacing: 16) {
                    // Pause/Resume
                    Button(action: {
                        if viewModel.isPaused {
                            viewModel.resumeRun()
                        } else {
                            viewModel.pauseRun()
                        }
                    }) {
                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .frame(width: 70, height: 70)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    
                    // Stop
                    Button(action: {
                        viewModel.stopRun(userId: userId)
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .frame(width: 70, height: 70)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
}

// MARK: - Split Card Component
struct SplitCard: View {
    let split: Split
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Km \(split.km)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(split.timeFormatted)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(split.paceFormatted)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .frame(width: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cyan.opacity(0.8))
        )
    }
}

// MARK: - Map View
struct MapView: View {
    let route: [CLLocation]
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -8.0476, longitude: -34.8770), // Recife
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onChange(of: route) { oldValue, newValue in
                if let last = newValue.last {
                    region.center = last.coordinate
                }
            }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Run.self, RunEvent.self, EventParticipant.self, configurations: config)

    return RunTrackingView()
        .modelContainer(container)
}
