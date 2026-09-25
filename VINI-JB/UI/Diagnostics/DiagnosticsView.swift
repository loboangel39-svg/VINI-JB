import SwiftUI

struct DiagnosticsView: View {
    @State private var diagnostics: [String: String] = [:]
    @State private var isLoading = false
    
    private let jbAccess = JailbreakAccess.shared
    
    var body: some View {
        List {
            Section("System Diagnostics") {
                if isLoading {
                    ProgressView()
                } else {
                    ForEach(diagnostics.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key)
                                .font(.subheadline)
                            Spacer()
                            Text(value)
                                .font(.subheadline)
                                .foregroundColor(value == "OK" ? .green : (value == "Not Available" || value == "Restricted" ? .red : .secondary))
                        }
                    }
                }
            }
            
            Section {
                Button("Refresh") {
                    loadDiagnostics()
                }
            }
        }
        .navigationTitle("Diagnostics")
        .task {
            loadDiagnostics()
        }
    }
    
    private func loadDiagnostics() {
        isLoading = true
        diagnostics = jbAccess.getDiagnosticInfo()
        isLoading = false
    }
}
