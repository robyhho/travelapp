import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @State private var email: String = ""
    @State private var status: Status = .idle
    @State private var rawNonce: String = ""

    enum Status: Equatable {
        case idle
        case sendingMagicLink
        case magicLinkSent
        case error(String)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                Text("Travel")
                    .font(.largeTitle.weight(.semibold))
                Text("Plan trips together. Even from China.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 16) {
                appleButton
                    .frame(height: 48)

                Text("or")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                magicLinkForm
            }
            .frame(maxWidth: 360)

            statusView

            Spacer()
        }
        .padding()
    }

    private var appleButton: some View {
        SignInWithAppleButton(.signIn) { request in
            let nonce = Nonce.random()
            rawNonce = nonce
            request.requestedScopes = [.email, .fullName]
            request.nonce = Nonce.sha256(nonce)
        } onCompletion: { result in
            handleAppleResult(result)
        }
        .signInWithAppleButtonStyle(.black)
    }

    private var magicLinkForm: some View {
        VStack(spacing: 8) {
            TextField("you@example.com", text: $email)
                #if os(iOS)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                #endif
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .padding(12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))

            Button {
                Task { await sendMagicLink() }
            } label: {
                HStack {
                    if status == .sendingMagicLink { ProgressView() }
                    Text("Email me a sign-in link")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.trimmingCharacters(in: .whitespaces).isEmpty || status == .sendingMagicLink)
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch status {
        case .idle, .sendingMagicLink:
            EmptyView()
        case .magicLinkSent:
            Label("Check your email for a sign-in link.", systemImage: "envelope.fill")
                .font(.callout)
                .foregroundStyle(.green)
        case .error(let message):
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.callout)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }

    private func sendMagicLink() async {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        status = .sendingMagicLink
        do {
            try await AuthRepo.shared.sendMagicLink(to: trimmed)
            status = .magicLinkSent
        } catch {
            status = .error(error.localizedDescription)
        }
    }

    private func handleAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            status = .error(error.localizedDescription)
        case .success(let auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                status = .error("Apple sign-in returned no identity token.")
                return
            }
            let nonce = rawNonce
            Task {
                do {
                    _ = try await AuthRepo.shared.signInWithApple(idToken: idToken, nonce: nonce)
                } catch {
                    status = .error(error.localizedDescription)
                }
            }
        }
    }
}
