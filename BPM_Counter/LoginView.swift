import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("DJ BPM Counter")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button("Login") {
                    login()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Login with Face ID / Touch ID") {
                    biometricLogin()
                }

                Button("Forgot Password?") {
                    showForgotPassword = true
                }

                Button("Create New Account") {
                    showSignUp = true
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .navigationDestination(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }

    func login() {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            return
        }

        isLoggedIn = true
    }

    func biometricLogin() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Login to your BPM Counter"
            ) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        isLoggedIn = true
                    } else {
                        errorMessage = "Face ID / Touch ID failed"
                    }
                }
            }
        } else {
            errorMessage = "Face ID / Touch ID is not available"
        }
    }
}

#Preview {
    LoginView()
}
