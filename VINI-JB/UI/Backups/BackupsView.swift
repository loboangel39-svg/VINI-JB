import SwiftUI

struct BackupsView: View {
    @State private var backups: [BackupInfo] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let backupManager = PatchBackupManager.shared
    private let restoreManager = PatchRestoreManager.shared
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading backups...")
                } else if backups.isEmpty {
                    EmptyStateView(
                        title: "No Backups",
                        systemImage: "arrow.clockwise",
                        description: "No backups available"
                    )
                } else {
                    List {
                        ForEach(backups) { backup in
                            BackupRow(backup: backup) {
                                restoreBackup(backup)
                            }
                        }
                    }
                    .refreshable {
                        await loadBackups()
                    }
                }
            }
            .navigationTitle("Backups")
            .task {
                await loadBackups()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func loadBackups() async {
        isLoading = true
        do {
            backups = try backupManager.listBackups()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func restoreBackup(_ backup: BackupInfo) {
        do {
            _ = try restoreManager.restore(patchID: backup.metadata.patchID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct BackupRow: View {
    let backup: BackupInfo
    let onRestore: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.clockwise.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(backup.metadata.fileName)
                    .font(.headline)
                
                Text("Patch ID: \(backup.metadata.patchID.prefix(8))...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(backup.metadata.backupDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onRestore) {
                Text("Restore")
            }
            .buttonStyle(.bordered)
            .tint(.green)
        }
        .padding(.vertical, 4)
    }
}
