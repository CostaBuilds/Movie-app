import SwiftUI

struct GroupListView: View {
    @StateObject private var viewModel = GroupViewModel()
    @State private var showingPublicGroups = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header com stats
                    statsHeader

                    // Meus Grupos
                    myGroupsSection

                    // Descobrir grupos
                    discoverSection
                }
                .padding()
            }
            .navigationTitle("Grupos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        viewModel.showingCreateGroup = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateGroup) {
                CreateGroupView()
                    .environmentObject(viewModel)
            }
            .sheet(isPresented: $showingPublicGroups) {
                PublicGroupsView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: 20) {
            StatBubble(
                icon: "person.3.fill",
                value: "\(viewModel.myGroups.count)",
                label: "Grupos"
            )

            StatBubble(
                icon: "figure.run",
                value: "0", // TODO: total de corridas
                label: "Corridas"
            )

            StatBubble(
                icon: "trophy.fill",
                value: "-",
                label: "Posição"
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Meus Grupos
    private var myGroupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meus Grupos")
                .font(.title2)
                .fontWeight(.bold)

            if viewModel.myGroups.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.myGroups) { group in
                    NavigationLink(destination: GroupDetailView(group: group)) {
                        GroupCard(group: group)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Você ainda não faz parte de nenhum grupo")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Crie um grupo ou encontre grupos públicos para participar")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                viewModel.showingCreateGroup = true
            }) {
                Text("Criar Meu Primeiro Grupo")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan)
                    .cornerRadius(12)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Descobrir Grupos
    private var discoverSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Descobrir")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: {
                    showingPublicGroups = true
                }) {
                    Text("Ver todos")
                        .font(.subheadline)
                        .foregroundColor(.cyan)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.publicGroups.prefix(3)) { group in
                        PublicGroupCard(group: group) {
                            viewModel.joinGroup(group)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Stat Bubble Component
struct StatBubble: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cyan)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Group Card Component
struct GroupCard: View {
    let group: Group

    var body: some View {
        HStack(spacing: 16) {
            // Foto do grupo (placeholder por enquanto)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "figure.run")
                        .font(.title2)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(group.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    Label("\(group.memberCount)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(group.city), \(group.state)", systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Public Group Card Component
struct PublicGroupCard: View {
    let group: Group
    let onJoin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Foto
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "figure.run")
                        .font(.title)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(group.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                Label("\(group.memberCount) membros", systemImage: "person.2")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onJoin) {
                Text("Entrar")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.cyan)
                    .cornerRadius(8)
            }
        }
        .frame(width: 180)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Public Groups Full View
struct PublicGroupsView: View {
    @ObservedObject var viewModel: GroupViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(viewModel.publicGroups) { group in
                GroupCard(group: group)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button(action: {
                            viewModel.joinGroup(group)
                            dismiss()
                        }) {
                            Label("Entrar", systemImage: "plus.circle.fill")
                        }
                        .tint(.cyan)
                    }
            }
            .listStyle(.plain)
            .navigationTitle("Grupos Públicos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    GroupListView()
}
