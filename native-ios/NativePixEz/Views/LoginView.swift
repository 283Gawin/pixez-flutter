import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var isSigningIn = false
    @State private var isThirdPartySigningIn = false
    @State private var errorMessage: String?
    @State private var webAuthSession: ASWebAuthenticationSession?
    @State private var presentationProvider = WebAuthenticationPresenter()

    var body: some View {
        NavigationStack {
            Form {
                Section("第三方登录") {
                    Button {
                        startThirdPartyLogin(createAccount: false)
                    } label: {
                        if isThirdPartySigningIn {
                            HStack {
                                ProgressView()
                                Text("等待网页登录完成")
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Label("使用第三方账号登录", systemImage: "person.crop.circle.badge.checkmark")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isThirdPartySigningIn || isSigningIn)

                    Button {
                        startThirdPartyLogin(createAccount: true)
                    } label: {
                        Label("注册新账号", systemImage: "person.badge.plus")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(isThirdPartySigningIn || isSigningIn)
                }

                Section("Pixiv 密码登录") {
                    TextField("用户名或邮箱", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("密码", text: $password)

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
                    .disabled(isSigningIn || username.isEmpty || password.isEmpty || isThirdPartySigningIn)
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
                        "第三方登录会通过 PKCE 打开 Pixiv 官方网页；完成后自动用授权码换取 Token，刷新令牌保存在 iOS 钥匙串。",
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
                    .disabled(isSigningIn || isThirdPartySigningIn)
                }
            }
        }
        .interactiveDismissDisabled(isThirdPartySigningIn || isSigningIn)
    }

    @MainActor
    private func startThirdPartyLogin(createAccount: Bool) {
        guard !isThirdPartySigningIn, !isSigningIn else { return }

        do {
            let flow = try PixivLoginFlow()
            let authorizationURL = PixivAPIClient.webAuthorizationURL(
                createAccount: createAccount,
                codeChallenge: flow.codeChallenge
            )

            let session = ASWebAuthenticationSession(
                url: authorizationURL,
                callbackURLScheme: "pixiv"
            ) { callbackURL, error in
                Task { @MainActor in
                    await handleThirdPartyResult(
                        callbackURL: callbackURL,
                        error: error,
                        codeVerifier: flow.codeVerifier
                    )
                }
            }

            session.presentationContextProvider = presentationProvider
            session.prefersEphemeralWebBrowserSession = false
            webAuthSession = session

            isThirdPartySigningIn = true
            errorMessage = nil

            guard session.start() else {
                throw PixivAPIError.badResponse
            }
        } catch {
            isThirdPartySigningIn = false
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func handleThirdPartyResult(
        callbackURL: URL?,
        error: Error?,
        codeVerifier: String
    ) async {
        defer {
            isThirdPartySigningIn = false
        }

        if let error {
            if (error as? ASWebAuthenticationSessionError)?.code != .canceledLogin {
                errorMessage = error.localizedDescription
            }
            return
        }

        guard let code = PixivLoginFlow.authorizationCode(from: callbackURL) else {
            errorMessage = "没有从 Pixiv 网页登录收到授权码。"
            return
        }

        do {
            try await appState.completeThirdPartyLogin(code: code, codeVerifier: codeVerifier)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
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
