import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class GroupViewModel: ObservableObject {
    @Published var myGroups: [Group] = []
    @Published var publicGroups: [Group] = []
    @Published var isLoading = false
    @Published var showingCreateGroup = false
    
    // Mock data por enquanto (depois vem do Firebase)
    init() {
        loadMockGroups()
    }
    
    func loadMockGroups() {
        // Grupos que você participa
        myGroups = [
            Group(
                id: "1",
                name: "Run Recife",
                description: "Corridas semanais em Recife toda quarta 19h",
                city: "Recife",
                state: "PE",
                createdBy: "mock-user-id",
                isPublic: true
            ),
            Group(
                id: "2",
                name: "Boa Viagem Runners",
                description: "Galera que corre na orla",
                city: "Recife",
                state: "PE",
                createdBy: "other-user",
                isPublic: true
            )
        ]
        
        // Atualiza member count
        myGroups[0].memberCount = 45
        myGroups[1].memberCount = 23
        
        // Grupos públicos pra descobrir
        publicGroups = [
            Group(
                id: "3",
                name: "Olinda Runners",
                description: "Corridas históricas por Olinda",
                city: "Olinda",
                state: "PE",
                createdBy: "someone",
                isPublic: true
            ),
            Group(
                id: "4",
                name: "Trail PE",
                description: "Corridas de trilha em Pernambuco",
                city: "Recife",
                state: "PE",
                createdBy: "someone",
                isPublic: true
            )
        ]
        
        publicGroups[0].memberCount = 78
        publicGroups[1].memberCount = 34
    }
    
    func createGroup(_ group: Group) {
        // Por enquanto só adiciona localmente
        var newGroup = group
        newGroup.memberCount = 1
        myGroups.insert(newGroup, at: 0)
        showingCreateGroup = false
        
        print("✅ Grupo criado: \(group.name)")
    }
    
    func joinGroup(_ group: Group) {
        // TODO: Implementar join no Firebase
        myGroups.append(group)
        print("✅ Entrou no grupo: \(group.name)")
    }
    
    func leaveGroup(_ groupId: String) {
        myGroups.removeAll { $0.id == groupId }
        print("👋 Saiu do grupo: \(groupId)")
    }
}
