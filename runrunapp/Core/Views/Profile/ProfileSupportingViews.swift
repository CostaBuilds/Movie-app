import SwiftUI

// MARK: - Run History View (Simplificada)

struct RunHistoryView: View {
    let runs: [Run]
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(runs, id: \.id) { run in
                        CleanRunCard(run: run) {
                            // Navegar para detalhe
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("Histórico de Corridas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Settings View (Simplificada)

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingsRow(icon: "person.fill", title: "Editar Perfil", iconColor: .blue)
                    SettingsRow(icon: "bell.fill", title: "Notificações", iconColor: .orange)
                    SettingsRow(icon: "lock.fill", title: "Privacidade", iconColor: .purple)
                }

                Section {
                    SettingsRow(icon: "info.circle.fill", title: "Sobre", iconColor: .gray)
                    SettingsRow(icon: "questionmark.circle.fill", title: "Ajuda", iconColor: .green)
                }

                Section {
                    Button(role: .destructive) {
                        // Ação de sair
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sair")
                        }
                    }
                }
            }
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 16))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }
}
