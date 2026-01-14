import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: GroupViewModel

    // Form fields
    @State private var groupName = ""
    @State private var description = ""
    @State private var city = ""
    @State private var state = ""
    @State private var isPublic = true
    @State private var showingImagePicker = false

    // Validation
    @State private var showingError = false
    @State private var errorMessage = ""

    // Mock user ID (depois vem do Firebase Auth)
    private let userId = "mock-user-id"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Group Photo
                    groupPhotoSection

                    // Form Fields
                    formSection

                    // Privacy Toggle
                    privacySection

                    // Info Card
                    infoCard

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Criar Grupo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Criar") {
                        createGroup()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isFormValid)
                }
            }
            .alert("Erro", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Group Photo Section
    private var groupPhotoSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingImagePicker = true
            }) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color(.systemBackground), lineWidth: 4)
                    )
            }

            Text("Adicionar Foto")
                .font(.subheadline)
                .foregroundColor(.cyan)
        }
        .padding(.vertical)
    }

    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 16) {
            // Group Name
            FormField(
                icon: "person.3.fill",
                placeholder: "Nome do Grupo",
                text: $groupName
            )

            // Description
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "text.alignleft")
                        .font(.body)
                        .foregroundColor(.cyan)
                        .frame(width: 24)

                    Text("Descrição")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                TextField("Descreva o objetivo do grupo, dias de treino, etc.", text: $description, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .lineLimit(3...6)
            }

            // Location
            HStack(spacing: 12) {
                FormField(
                    icon: "building.2",
                    placeholder: "Cidade",
                    text: $city
                )

                FormField(
                    icon: "map",
                    placeholder: "UF",
                    text: $state
                )
                .frame(width: 80)
            }
        }
    }

    // MARK: - Privacy Section
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacidade")
                .font(.headline)

            Toggle(isOn: $isPublic) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: isPublic ? "globe" : "lock.fill")
                            .foregroundColor(isPublic ? .cyan : .orange)

                        Text(isPublic ? "Grupo Público" : "Grupo Privado")
                            .fontWeight(.medium)
                    }

                    Text(isPublic ? "Qualquer pessoa pode encontrar e entrar" : "Apenas membros convidados podem entrar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }

    // MARK: - Info Card
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)

                Text("Dicas para criar um grupo")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 8) {
                InfoItem(text: "Escolha um nome claro e fácil de encontrar")
                InfoItem(text: "Descreva o ritmo e objetivos do grupo")
                InfoItem(text: "Informe dias e horários de treino")
                InfoItem(text: "Adicione a localização dos treinos")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }

    // MARK: - Form Validation
    private var isFormValid: Bool {
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        state.count == 2
    }

    // MARK: - Actions
    private func createGroup() {
        // Validation
        guard isFormValid else {
            errorMessage = "Por favor, preencha todos os campos"
            showingError = true
            return
        }

        // Validate state
        let stateUpper = state.uppercased()
        guard stateUpper.count == 2 else {
            errorMessage = "Estado deve ter 2 letras (ex: PE, SP)"
            showingError = true
            return
        }

        // Create group
        let newGroup = Group(
            name: groupName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            state: stateUpper,
            createdBy: userId,
            isPublic: isPublic
        )

        viewModel.createGroup(newGroup)
        dismiss()
    }
}

// MARK: - Form Field Component
struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.cyan)
                .frame(width: 24)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Info Item Component
struct InfoItem: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.blue)

            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CreateGroupView()
        .environmentObject(GroupViewModel())
}
