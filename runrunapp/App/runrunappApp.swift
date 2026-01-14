import SwiftUI
import SwiftData

@main
struct RunAppApp: App {
    // SwiftData container
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Configura o container com todos os modelos
            let config = ModelConfiguration(isStoredInMemoryOnly: false)

            modelContainer = try ModelContainer(
                for: User.self, Run.self,
                configurations: config
            )
        } catch {
            // Em caso de erro de schema (mudança de modelo), tentar deletar o store
            print("⚠️ SwiftData migration error: \(error)")
            print("🔄 Deletando store antigo e recriando...")

            // Tentar deletar arquivos do store antigo
            if let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storePath = storeURL.appendingPathComponent("default.store")
                try? FileManager.default.removeItem(at: storePath)

                // Deletar arquivos auxiliares
                let shmPath = storeURL.appendingPathComponent("default.store-shm")
                let walPath = storeURL.appendingPathComponent("default.store-wal")
                try? FileManager.default.removeItem(at: shmPath)
                try? FileManager.default.removeItem(at: walPath)

                print("🗑️ Arquivos antigos deletados")
            }

            // Tentar criar novamente
            do {
                let config = ModelConfiguration(isStoredInMemoryOnly: false)
                modelContainer = try ModelContainer(
                    for: User.self, Run.self,
                    configurations: config
                )
                print("✅ Container recriado com sucesso!")
            } catch {
                print("❌ Não foi possível recriar. Usando memória temporária.")
                // Fallback para memória
                do {
                    modelContainer = try ModelContainer(
                        for: User.self, Run.self,
                        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                    )
                    print("✅ Container em memória criado")
                } catch {
                    fatalError("Failed to configure SwiftData container: \(error)")
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
