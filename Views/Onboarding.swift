//
//  Onboarding.swift
//  LittleLemon
//
//  Created by Nouf Faisal  on 14/11/1445 AH.
//

import SwiftUI

// Define a struct named Onboarding that conforms to the View protocol.
struct Onboarding: View {
    @StateObject private var viewModel = ViewModel() // ViewModel manages the logic for the Onboarding view.
    
    // State variables to store user input.
    @State var firstName = ""
    @State var lastName = ""
    @State var email = ""
    @State var phoneNumber = ""

    // State variables for UI adjustments when the keyboard appears.
    @State var isKeyboardVisible = false
    @State var contentOffset: CGSize = .zero

    // State to manage user login status.
    @State var isLoggedIn = false

    // The body property that provides the UI of the view.
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // Header contains the logo and potentially the user profile image if logged in.
                    VStack {
                        ZStack {
                            
                            Image("Logo") // Logo of the application.
                            HStack {
                                Spacer()
                                if isLoggedIn {
                                    NavigationLink(destination: UserProfile()) {
                                        Image("profile-image-placeholder")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 50)
                                            .clipShape(Circle())
                                            .padding(.trailing)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 60)
                        .padding(.bottom)
                    }
                    .onAppear() {
                        // Check if user is logged in when the view appears.
                        isLoggedIn = UserDefaults.standard.bool(forKey: kIsLoggedIn)
                    }

                    // Hero section of the onboarding displaying promotional content.
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Little Lemon") // Name of the business.
                                    .foregroundColor(Color.primaryColor2)
                                    .font(.displayFont())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("Chicago") // Location.
                                    .foregroundColor(.white)
                                    .font(.subTitleFont())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer(minLength: 5)
                                Text("""
                                     We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.
                                     """) // Description.
                                .foregroundColor(.white)
                                .font(.leadText())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Image("hero-image") // Promotional image.
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: 120, maxHeight: 140)
                                .clipShape(Rectangle())
                                .cornerRadius(16)
                        }
                    }
                    .padding()
                    .background(Color.primaryColor1)
                    .frame(maxWidth: .infinity, maxHeight: 240)
                    
                    // Text fields for user input with registration button.
                    VStack {
                        NavigationLink(destination: Home(), isActive: $isLoggedIn) { }
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                        TextField("E-mail", text: $email)
                            .keyboardType(.emailAddress)
                    }
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .padding()
                    
                    // Display an error message if present.
                    if viewModel.isErrorMessageVisible {
                        withAnimation() {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                        }
                    }
                    
                    // Register button that validates user input and updates the user's registration status.
                    Button("Register") {
                        if viewModel.validateUserInput(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber) {
                            UserDefaults.standard.set(firstName, forKey: kFirstName)
                            UserDefaults.standard.set(lastName, forKey: kLastName)
                            UserDefaults.standard.set(email, forKey: kEmail)
                            UserDefaults.standard.set(true, forKey: kIsLoggedIn)
                            UserDefaults.standard.set(true, forKey: kOrderStatuses)
                            UserDefaults.standard.set(true, forKey: kPasswordChanges)
                            UserDefaults.standard.set(true, forKey: kSpecialOffers)
                            UserDefaults.standard.set(true, forKey: kNewsletter)
                            firstName = ""
                            lastName = ""
                            email = ""
                            isLoggedIn = true
                        }
                    }
                 .buttonStyle(BroadYellowButtonStyle()) // Apply a predefined button style.
                    
                    Spacer()
                }
                .offset(y: contentOffset.height) // Adjusts the content offset based on keyboard visibility.
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    withAnimation {
                        let keyboardRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                        let keyboardHeight = keyboardRect.height
                        self.isKeyboardVisible = true
                        self.contentOffset = CGSize(width: 0, height: -keyboardHeight / 2 + 50)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
                    withAnimation {
                        self.isKeyboardVisible = false
                        self.contentOffset = .zero
                    }
                }
            }
            .onAppear() {
                // Re-check the login status when the view appears.
                isLoggedIn = UserDefaults.standard.bool(forKey: kIsLoggedIn)
            }
        }
        .navigationBarBackButtonHidden() // Hide the default back button in the navigation bar.
    }
}

// Provides a preview of the Onboarding view.
struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding()
    }
}
