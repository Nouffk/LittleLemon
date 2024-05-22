//
//  UserProfile.swift
//  LittleLemon
//
//  Created by Nouf Faisal  on 14/11/1445 AH.
//
import SwiftUI

// Define a struct named UserProfile that conforms to the View protocol.
struct UserProfile: View {
    @StateObject private var viewModel = ViewModel() // ViewModel to manage the logic for the UserProfile view.

    @Environment(\.presentationMode) var presentation // Access the presentation mode environment to manage view dismissal.

    // State variables for toggling various notification settings.
    @State private var orderStatuses = true
    @State private var passwordChanges = true
    @State private var specialOffers = true
    @State private var newsletter = true

    // State variables for storing user information.
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""

    // State to manage the log-out process.
    @State private var isLoggedOut = false
    // State to manage the visibility of the image picker.
    @State private var showingImagePicker = false
    // State to store the selected image from the picker.
    @State private var inputImage: UIImage?
    // State to store and display the profile image.
    @State private var profileImage: Image = Image("profile-image-placeholder") // Default image placeholder.

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            NavigationLink(destination: Onboarding(), isActive: $isLoggedOut) { }
            VStack(spacing: 5) {
                avatarSection // Section for displaying and changing the avatar.
                personalInfoSection // Section for entering and editing personal information.
            }
            emailNotificationsSection // Section for managing email notifications.
            logoutButton // Button for logging out.
            changeButtons // Buttons for discarding and saving changes.
            errorMessage // Displays error messages from the ViewModel.
        }
        .onAppear {
            loadInitialData() // Load initial data from the ViewModel when the view appears.
        }
        .navigationTitle("Personal information")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage) // Image picker interface.
        }
    }

    // MARK: UI Components and Sections

    private var avatarSection: some View {
        VStack {
            Text("Avatar")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.primaryColor1)
                .font(.custom("Karla-Bold", size: 13))
                
            HStack(spacing: 0) {
                profileImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 75)
                    .clipShape(Circle())
                    .padding(.trailing)
                Button("Change") {
                    showingImagePicker = true // Trigger the image picker.
                }
                .buttonStyle(HighlightButtonStyle())
                Button("Remove") {
                    profileImage = Image("default-image") // Reset the profile image to default.
                }
                .buttonStyle(ReversedHighlightButtonStyle())
                Spacer()
            }
        }
    }

    private var personalInfoSection: some View {
        VStack(spacing: 5) {
            inputField("First name", text: $firstName)
            inputField("Last name", text: $lastName)
            inputField("E-mail", text: $email, keyboardType: .emailAddress)
            inputField("Phone number", text: $phoneNumber)
        }
        .textFieldStyle(.roundedBorder)
        .disableAutocorrection(true)
        .padding()
    }

    private func inputField(_ title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(Color.primaryColor1)
                .font(.custom("Karla-Bold", size: 13))
            TextField(title, text: text)
                .keyboardType(keyboardType)
        }
    }

    private var emailNotificationsSection: some View {
        VStack(alignment: .leading) {
            Text("Email notifications")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.vertical)
            Toggle("Order statuses", isOn: $orderStatuses)
            Toggle("Password changes", isOn: $passwordChanges)
            Toggle("Special offers", isOn: $specialOffers)
            Toggle("Newsletter", isOn: $newsletter)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }

    private var logoutButton: some View {
        Button("Log out") {
            UserDefaults.standard.set(false, forKey: kIsLoggedIn)
            resetUserDefaults()
            isLoggedOut = true
        }
        .buttonStyle(BroadYellowButtonStyle())
        .padding(.bottom)
    }

    private var changeButtons: some View {
        HStack {
            Button("Discard Changes", action: discardChanges)
                .buttonStyle(ReversedHighlightButtonStyle())
            Button("Save changes", action: saveChanges)
                .buttonStyle(HighlightButtonStyle())
        }
    }

    private var errorMessage: some View {
        Group {
            if viewModel.isErrorMessageVisible {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
        }
    }

    // MARK: Functions

    private func loadInitialData() {
        // Load user data and preferences from the ViewModel.
        firstName = viewModel.firstName
        lastName = viewModel.lastName
        email = viewModel.email
        phoneNumber = viewModel.phoneNumber
        orderStatuses = viewModel.orderStatuses
        passwordChanges = viewModel.passwordChanges
        specialOffers = viewModel.specialOffers
        newsletter = viewModel.newsletter
    }

    private func discardChanges() {
        // Discard changes and reload data from the ViewModel.
        loadInitialData()
        presentation.wrappedValue.dismiss() // Dismiss the view.
    }

    private func saveChanges() {
        // Save the changes and update the user data.
        if viewModel.validateUserInput(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber) {
            updateUserDefaults()
            presentation.wrappedValue.dismiss() // Dismiss the view if validation is successful.
        }
    }

    private func resetUserDefaults() {
        // Reset user defaults during logout.
        UserDefaults.standard.set("", forKey: kFirstName)
        UserDefaults.standard.set("", forKey: kLastName)
        UserDefaults.standard.set("", forKey: kEmail)
        UserDefaults.standard.set("", forKey: kPhoneNumber)
        UserDefaults.standard.set(false, forKey: kOrderStatuses)
        UserDefaults.standard.set(false, forKey: kPasswordChanges)
        UserDefaults.standard.set(false, forKey: kSpecialOffers)
        UserDefaults.standard.set(false, forKey: kNewsletter)
    }

    private func updateUserDefaults() {
        // Update user defaults with new data.
        UserDefaults.standard.set(firstName, forKey: kFirstName)
        UserDefaults.standard.set(lastName, forKey: kLastName)
        UserDefaults.standard.set(email, forKey: kEmail)
        UserDefaults.standard.set(phoneNumber, forKey: kPhoneNumber)
        UserDefaults.standard.set(orderStatuses, forKey: kOrderStatuses)
        UserDefaults.standard.set(passwordChanges, forKey: kPasswordChanges)
        UserDefaults.standard.set(specialOffers, forKey: kSpecialOffers)
        UserDefaults.standard.set(newsletter, forKey: kNewsletter)
    }

    private func loadImage() {
        // Load the selected image into the profile image view.
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct UserProfile_Previews: PreviewProvider {
    static var previews: some View {
        UserProfile()
    }
}
