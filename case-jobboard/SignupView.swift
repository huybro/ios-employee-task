import SwiftUI

struct SignUpView: View {
    // MARK: - Properties
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignedUp: Bool = false
    @State private var errorMessage: String? = nil
    
    // MARK: - Constants
    enum Constants {
        static let imageSize: CGSize = CGSize(width: 300, height: 150)
        static let cornerRadius: CGFloat = 10
        static let horizontalPadding: CGFloat = 20
        static let verticalSpacing: CGFloat = 20
        static let fieldOpacity: Double = 0.1
    }
    
    // MARK: - View Components
    private var headerImage: some View {
        Image("462568967_564422969469283_3279968822663316083_n")
            .resizable()
            .scaledToFit()
            .frame(width: Constants.imageSize.width, height: Constants.imageSize.height)
            .padding(.top, 40)
    }
    
    private var fullNameField: some View {
        TextField("Enter your full name", text: $fullName)
            .textInputStyle()
    }
    
    private var emailField: some View {
        TextField("Enter your email", text: $email)
            .textInputStyle()
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .textContentType(.emailAddress)
    }
    
    private var passwordField: some View {
        SecureField("Enter your password", text: $password)
            .textInputStyle()
            .textContentType(.password)
    }
    
    private var confirmPasswordField: some View {
        SecureField("Confirm your password", text: $confirmPassword)
            .textInputStyle()
            .textContentType(.password)
    }
    
    private var signUpButton: some View {
        Button(action: handleSignUp) {
            Text("Sign Up")
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.title, AppColors.title.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(Constants.cornerRadius)
                .shadow(radius: 5)
                .padding(.horizontal)
        }
    }
    
    private var errorMessageText: some View {
        Group {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        NavigationView {
            VStack {
                headerImage
                
                VStack(spacing: Constants.verticalSpacing) {
                    fullNameField
                    emailField
                    passwordField
                    confirmPasswordField
                    signUpButton
                    errorMessageText
                }
                .padding(.top, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Methods
    private func handleSignUp() {
        // Check if passwords match and handle sign-up logic
        if password == confirmPassword {
            self.isSignedUp = true
            self.errorMessage = nil
        } else {
            self.errorMessage = "Passwords do not match."
        }
    }
}

// MARK: - Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
