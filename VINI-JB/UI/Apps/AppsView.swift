import SwiftUI

struct AppsView: View {
    @State private var containers: [AppContainer] = []
    @State private var isLoading = false
    @State private var error: String?
    @State private var searchText = ""
    
    private let containerManager = ContainerManager.shared
    
    var filteredContainers: [AppContainer] {
        if searchText.isEmpty {
            return containers
        }
        return containers.filter { $0.bundleID.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading apps...")
                } else if filteredContainers.isEmpty {
                    EmptyStateView(
                        title: "No Apps Found",
                        systemImage: "app.badge",
                        description: "No accessible applications found"
                    )
                } else {
                    List(filteredContainers) { container in
                        NavigationLink(destination: ContainerDetailView(container: container)) {
                            VStack(alignment: .leading) {
                                Text(container.displayName)
                                    .font(.headline)
                                Text(container.bundleID)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .refreshable {
                        await loadContainers()
                    }
                }
            }
            .navigationTitle("Apps")
            .searchable(text: $searchText, prompt: "Search apps")
            .task {
                await loadContainers()
            }
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("OK") { error = nil }
            } message: {
                Text(error ?? "")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func loadContainers() async {
        isLoading = true
        do {
            containers = try containerManager.discoverContainers()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

struct ContainerDetailView: View {
    let container: AppContainer
    
    @State private var items: [FileItem] = []
    @State private var isLoading = false
    
    private let browser = DirectoryBrowser.shared
    private let containerManager = ContainerManager.shared
    
    var body: some View {
        List {
            Section(header: Text("Directories")) {
                ForEach(containerManager.getContainerDirectories(container)) { item in
                    NavigationLink(destination: FileBrowserView(url: item.url, title: item.name)) {
                        Label(item.name, systemImage: "folder")
                    }
                }
            }
            
            Section(header: Text("Contents")) {
                if isLoading {
                    ProgressView()
                } else {
                    ForEach(items) { item in
                        NavigationLink(destination: FileBrowserView(url: item.url, title: item.name)) {
                            HStack {
                                Image(systemName: item.isDirectory ? "folder" : "doc")
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
        }
        .navigationTitle(container.displayName)
        .task {
            await loadContents()
        }
    }
    
    private func loadContents() async {
        isLoading = true
        do {
            items = try browser.browseContainer(container)
        } catch {
            print("Error loading contents: \(error)")
        }
        isLoading = false
    }
    
    private func formatSize(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
