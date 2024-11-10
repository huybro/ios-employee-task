import SwiftUI

struct LoginView: View {
    // MARK: - Properties
    @Binding var isLoggedIn: Bool
    @State private var email: String = ""
    @State private var password: String = ""
    
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
    
    private var emailField: some View {
        TextField("Email", text: $email)
            .textInputStyle()
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .textContentType(.emailAddress)
    }
    
    private var passwordField: some View {
        SecureField("Password", text: $password)
            .textInputStyle()
            .textContentType(.password)
    }
    
    private var loginButton: some View {
        Button(action: handleLogin) {
            Text("Login")
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
    
    private var signUpLink: some View {
        NavigationLink(destination: SignUpView()) {
            Text("Don't have an account? Sign Up")
                .foregroundColor(AppColors.title)
        }
        .padding(.top)
    }
    
    // MARK: - Main Body
    var body: some View {
        NavigationView {
            VStack {
                headerImage
                
                VStack(spacing: Constants.verticalSpacing) {
                    emailField
                    passwordField
                    loginButton
                    signUpLink
                }
                .padding(.top, 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .onChange(of: isLoggedIn, perform : handleLoginStateChange)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Methods
    private func handleLogin() {
        // Add validation here
        guard !email.isEmpty && !password.isEmpty else {
            // Add error handling
            return
        }
        
        self.isLoggedIn = true
    }
    
    private func handleLoginStateChange(_ newValue: Bool) {
        if newValue {
            print("User logged in")
            // Add additional login success handling
        }
    }
}

// MARK: - View Modifiers
extension View {
    func textInputStyle() -> some View {
        self
            .padding()
            .background(.white)
            .cornerRadius(LoginView.Constants.cornerRadius)
            .padding(.horizontal)
    }
}

// MARK: - Preview
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isLoggedIn: .constant(false))
    }
}
