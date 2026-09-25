import SwiftUI

struct PatchesView: View {
    @EnvironmentObject var patchManager: PatchManager
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            Group {
                if patchManager.isLoading {
                    ProgressView("Loading patches...")
                } else if patchManager.patches.isEmpty {
                    EmptyStateView(
                        title: "No Patches",
                        systemImage: "puzzlepiece",
                        description: "No patches available for your license"
                    )
                } else {
                    List(patchManager.patches) { patch in
                        PatchRow(patch: patch)
                    }
                    .refreshable {
                        await patchManager.syncPatches()
                    }
                }
            }
            .navigationTitle("Patches")
            .task {
                if patchManager.patches.isEmpty {
                    await patchManager.syncPatches()
                }
            }
            .alert("Error", isPresented: .constant(patchManager.error != nil)) {
                Button("OK") { patchManager.error = nil }
            } message: {
                Text(patchManager.error ?? "")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct PatchRow: View {
    let patch: RemotePatchInfo
    
    @EnvironmentObject var patchManager: PatchManager
    @State private var isDownloading = false
    
    var isDownloaded: Bool {
        patchManager.isDownloaded(patch)
    }
    
    var hasUpdate: Bool {
        patchManager.hasUpdate(patch)
    }
    
    var body: some View {
        HStack {
            Image(systemName: isDownloaded ? (hasUpdate ? "arrow.down.circle.fill" : "checkmark.circle.fill") : "arrow.down.circle")
                .foregroundColor(isDownloaded ? (hasUpdate ? .orange : .green) : .blue)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(patch.name)
                    .font(.headline)
                
                Text(patch.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("v\(patch.version)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(patch.type.uppercased())
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(patch.type == "premium" ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            if isDownloading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .contextMenu {
            if isDownloaded {
                Button(role: .destructive) {
                    try? patchManager.deleteLocalPatch(patch)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
