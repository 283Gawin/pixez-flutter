import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var isSigningIn = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Pixiv 账户") {
                    TextField("用户名或邮箱", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("密码", text: $password)
                }

                Section {
                    Button {
                        signIn()
                    } label: {
                        if isSigningIn {
                            HStack {
                                ProgressView()
                                Text("登录中")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("登录")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isSigningIn || username.isEmpty || password.isEmpty)
                }

                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.callout)
                    }
                }

                Section {
                    Label(
                        "凭据只发送到 Pixiv 官方登录接口；刷新令牌保存在 iOS 钥匙串。",
                        systemImage: "lock.shield"
                    )
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("登录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .disabled(isSigningIn)
                }
            }
        }
    }

    @MainActor
    private func signIn() {
        guard !isSigningIn else { return }
        isSigningIn = true
        errorMessage = nil

        Task { @MainActor in
            defer {
                isSigningIn = false
            }

            do {
                try await appState.login(username: username, password: password)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
