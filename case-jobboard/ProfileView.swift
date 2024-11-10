import SwiftUI
import Combine

// MARK: - Models
struct Profile: Codable {
    var name: String
    var email: String
    var phoneNumber: String
    var school: String
    var resumeURL: URL?
    var certificateURL: URL?
    
    var resumeUploaded: Bool { resumeURL != nil }
    var certificateUploaded: Bool { certificateURL != nil }
}

enum UploadType: String {
    case resume = "Resume"
    case certificate = "Certificate"
}

enum ValidationError: LocalizedError {
    case invalidEmail
    case invalidPhone
    case requiredFieldMissing(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPhone:
            return "Please enter a valid phone number"
        case .requiredFieldMissing(let field):
            return "\(field) is required"
        }
    }
}

// MARK: - View Model
class ProfileViewModel: ObservableObject {
    @Published var profile = Profile(name: "", email: "", phoneNumber: "", school: "")
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    @Published var uploadStatus: [UploadType: UploadStatus] = [
        .resume: .notStarted,
        .certificate: .notStarted
    ]
    
    private var cancellables = Set<AnyCancellable>()
    private let validator = ProfileValidator()
    
    enum UploadStatus {
        case notStarted
        case uploading
        case completed
        case failed
    }
    
    init() {
        setupValidation()
    }
    
    private func setupValidation() {
        // Debounce email validation to avoid excessive validation
        $profile
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.validateProfile(profile)
            }
            .store(in: &cancellables)
    }
    
    func validateProfile(_ profile: Profile) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if profile.name.isEmpty {
            errors.append(.requiredFieldMissing("Name"))
        }
        
        if !validator.isValidEmail(profile.email) {
            errors.append(.invalidEmail)
        }
        
        if !profile.phoneNumber.isEmpty && !validator.isValidPhone(profile.phoneNumber) {
            errors.append(.invalidPhone)
        }
        
        if profile.school.isEmpty {
            errors.append(.requiredFieldMissing("School"))
        }
        
        return errors
    }
    
    func handleFileUpload(_ url: URL, type: UploadType) {
        uploadStatus[type] = .uploading
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            // Simulate 90% success rate
            if Double.random(in: 0...1) < 0.9 {
                switch type {
                case .resume:
                    self.profile.resumeURL = url
                case .certificate:
                    self.profile.certificateURL = url
                }
                self.uploadStatus[type] = .completed
            } else {
                self.uploadStatus[type] = .failed
                self.alertItem = AlertItem(
                    title: "Upload Failed",
                    message: "Failed to upload \(type.rawValue). Please try again."
                )
            }
        }
    }
    
    func saveProfile() {
        let errors = validateProfile(profile)
        
        guard errors.isEmpty else {
            alertItem = AlertItem(
                title: "Validation Error",
                message: errors.map { $0.localizedDescription }.joined(separator: "\n")
            )
            return
        }
        
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            
            // Simulate success
            if Double.random(in: 0...1) < 0.9 {
                self.alertItem = AlertItem(
                    title: "Success",
                    message: "Profile saved successfully!"
                )
            } else {
                self.alertItem = AlertItem(
                    title: "Error",
                    message: "Failed to save profile. Please try again."
                )
            }
        }
    }
}

// MARK: - Utilities
struct ProfileValidator {
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// MARK: - Views
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showDocumentPicker = false
    @State private var currentUploadType: UploadType?
    
    // MARK: - Constants
    enum Constants {
        static let sectionHeaderColor: Color = .blue
        static let cornerRadius: CGFloat = 10
        static let horizontalPadding: CGFloat = 20
        static let verticalSpacing: CGFloat = 16
        static let fieldOpacity: Double = 0.1
    }
    
    private var headerImage: some View {
        Image("462568967_564422969469283_3279968822663316083_n")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 100)
            .padding(.top, 20)
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                headerImage
                Form {
                    personalInformationSection
                    uploadsSection
                }                
                .scrollContentBackground(.hidden)
                saveButtonSection
                
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .background(AppColors.background)
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    if let type = currentUploadType {
                        viewModel.handleFileUpload(url, type: type)
                    }
                }
            }
        }
    }
    
    private var personalInformationSection: some View {
        Section(header: SectionHeader(title: "Personal Information")) {
            VStack(alignment: .leading, spacing: Constants.verticalSpacing) {
                InputField(
                    title: "Name*",
                    text: $viewModel.profile.name,
                    keyboardType: .default
                )
                
                InputField(
                    title: "Email*",
                    text: $viewModel.profile.email,
                    keyboardType: .emailAddress
                )
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                
                InputField(
                    title: "Phone",
                    text: $viewModel.profile.phoneNumber,
                    keyboardType: .phonePad
                )
                .textContentType(.telephoneNumber)
                
                InputField(
                    title: "School*",
                    text: $viewModel.profile.school,
                    keyboardType: .default
                )
            }
        }
    }
    
    private var uploadsSection: some View {
        Section(header: SectionHeader(title: "Uploads")) {
            VStack(spacing: Constants.verticalSpacing) {
                ForEach([UploadType.resume, .certificate], id: \.self) { type in
                    UploadButton(
                        title: "Upload \(type.rawValue)",
                        status: viewModel.uploadStatus[type] ?? .notStarted
                    ) {
                        currentUploadType = type
                        showDocumentPicker = true
                    }
                }
            }
        }
    }
    
    private var saveButtonSection: some View {
        Section {
            Button(action: viewModel.saveProfile) {
                Text("Save Profile")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Constants.sectionHeaderColor, Constants.sectionHeaderColor.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(AppColors.background)
                    .cornerRadius(Constants.cornerRadius)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Supporting Views
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .foregroundColor(ProfileView.Constants.sectionHeaderColor)
            .font(.headline)
    }
}

struct InputField: View {
    let title: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(text)
    }
}

struct UploadButton: View {
    let title: String
    let status: ProfileViewModel.UploadStatus
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(ProfileView.Constants.sectionHeaderColor)
                Spacer()
                statusView
            }
        }
        .padding()
        .background(ProfileView.Constants.sectionHeaderColor.opacity(0.1))
        .cornerRadius(ProfileView.Constants.cornerRadius)
        .disabled(status == .uploading)
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch status {
        case .notStarted:
            Image(systemName: "arrow.up.circle")
                .foregroundColor(ProfileView.Constants.sectionHeaderColor)
        case .uploading:
            ProgressView()
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .failed:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
        }
    }
}

struct LoadingOverlay: View {
    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .overlay(
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            )
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    let completion: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text])
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let completion: (URL) -> Void
        
        init(completion: @escaping (URL) -> Void) {
            self.completion = completion
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            completion(url)
        }
    }
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
