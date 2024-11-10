import SwiftUI

struct ProfileDisplayView: View {
    // MARK: - Properties
    let name: String
    let email: String
    let phoneNumber: String
    let school: String
    
    // MARK: - Initialization
    init(
        name: String = "John Doe",
        email: String = "john.doe@example.com",
        phoneNumber: String = "(123) 456-7890",
        school: String = "Example University"
    ) {
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.school = school
    }
    
    // MARK: - View Components
    private var headerImage: some View {
        Image("462568967_564422969469283_3279968822663316083_n")
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 150)
            .padding(.top, 40)
    }
    
    private var personalInfoSection: some View {
        Section(header: Text("Personal Information")
            .foregroundColor(AppColors.title)
            .bold()
        ) {
            VStack(alignment: .leading, spacing: 16) {
                InfoRow(label: "Name", value: name)
                InfoRow(label: "Email", value: email)
                InfoRow(label: "Phone Number", value: phoneNumber)
                InfoRow(label: "School", value: school)
            }
        }
    }
    
    private var uploadsSection: some View {
        Section(header: Text("Uploads")
            .foregroundColor(AppColors.title)
            .bold()
        ) {
            VStack(spacing: 16) {
                InfoRow(label: "Resume", value: "Uploaded", valueColor: .green)
                InfoRow(label: "Certificate", value: "Uploaded", valueColor: .green)
            }
        }
    }
    
    private var editButton: some View {
        NavigationLink(destination: ProfileView()) {
            Text("Edit Profile")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.title, AppColors.title.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 20)
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                headerImage
                
                Form {
                    personalInfoSection
                    uploadsSection
                }
                .scrollContentBackground(.hidden)
                .padding()
                
                editButton
            }.background(AppColors.background)

        }
    }
}

// MARK: - Supporting Views
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .gray
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(AppColors.title)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
        }
    }
}

// MARK: - Preview
struct ProfileDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileDisplayView()
    }
}
