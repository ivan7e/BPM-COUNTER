import SwiftUI

struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Enter your email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.blue)
                    .font(.caption)
            }

            Button("Send Reset Email") {
                resetPassword()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }

    func resetPassword() {
        if email.isEmpty {
            message = "Please enter your email"
        } else {
            message = "Password reset is disabled until Firebase is added back."
        }
    }
}

#Preview {
    ForgotPasswordView()
}
