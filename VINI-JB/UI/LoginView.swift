import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginManager: LoginManager
    @State private var licenseKey = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "puzzlepiece.extension")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text("VINI-JB")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Jailbreak Patch Manager")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    TextField("License Key", text: $licenseKey)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button {
                        Task {
                            await loginManager.login(licenseKey: licenseKey)
                        }
                    } label: {
                        if loginManager.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Login")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(licenseKey.isEmpty || loginManager.isLoading)
                }
                .padding(.horizontal, 32)
                
                if let error = loginManager.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
            }
            .navigationTitle("Login")
            .navigationBarHidden(true)
        }
    }
}
