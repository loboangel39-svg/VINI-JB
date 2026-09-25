import SwiftUI

struct FileBrowserView: View {
    let url: URL
    let title: String
    
    @State private var items: [FileItem] = []
    @State private var isLoading = false
    @State private var error: String?
    
    private let browser = DirectoryBrowser.shared
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
            } else if items.isEmpty {
                EmptyStateView(
                    title: "Empty Folder",
                    systemImage: "folder",
                    description: "This folder is empty"
                )
            } else {
                ForEach(items) { item in
                    if item.isDirectory {
                        NavigationLink(destination: FileBrowserView(url: item.url, title: item.name)) {
                            Label(item.name, systemImage: "folder.fill")
                                .foregroundColor(.blue)
                        }
                    } else {
                        HStack {
                            Image(systemName: "doc")
                                .foregroundColor(.secondary)
                            Text(item.name)
                            Spacer()
                            if let size = item.size {
                                Text(formatSize(size))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .task {
            await loadContents()
        }
        .refreshable {
            await loadContents()
        }
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "")
        }
    }
    
    private func loadContents() async {
        isLoading = true
        do {
            items = try browser.browseDirectory(at: url)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    private func formatSize(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
