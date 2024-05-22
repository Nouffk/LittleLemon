//
//  ViewModel.swift
//  LittleLemon
//
//  Created by Nouf Faisal  on 14/11/1445 AH.
//

import Foundation
import Combine

// Constants for UserDefaults keys to store and retrieve user settings.
public let kFirstName = "first_name_preference"
public let kLastName = "last_name_preference"
public let kEmail = "email_preference"
public let kPhoneNumber = "phone_number_preference"
public let kPasswordChanges = "password_updates_preference"
public let kIsLoggedIn = "logged_in_status"
public let kNewsletter = "newsletter_subscription_preference"
public let kOrderStatuses = "order_statuses_preference"
public let kSpecialOffers = "special_offers_preference"

// ViewModel class that conforms to ObservableObject for SwiftUI state management.
class ViewModel: ObservableObject {
    
    // Published properties that will update the view automatically when their values change.
    @Published var searchText = ""
    @Published var errorMessage = ""
    @Published var isErrorMessageVisible = false
    @Published var firstName: String = UserDefaults.standard.string(forKey: kFirstName) ?? ""
    @Published var lastName: String = UserDefaults.standard.string(forKey: kLastName) ?? ""
    @Published var email: String = UserDefaults.standard.string(forKey: kEmail) ?? ""
    @Published var phoneNumber: String = UserDefaults.standard.string(forKey: kPhoneNumber) ?? ""
    @Published var passwordChanges: Bool = UserDefaults.standard.bool(forKey: kPasswordChanges)
    @Published var orderStatuses: Bool = UserDefaults.standard.bool(forKey: kOrderStatuses)
    @Published var specialOffers: Bool = UserDefaults.standard.bool(forKey: kSpecialOffers)
    @Published var newsletter: Bool = UserDefaults.standard.bool(forKey: kNewsletter)
    
    // Method to validate user input. Returns true if all validations pass.
    func validateUserInput(firstName: String, lastName: String, email: String, phoneNumber: String) -> Bool {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
            setErrorMessage("Please complete all required fields.") // Set error message if any field is empty.
            return false
        }
        
        guard validateEmail(email), validatePhoneNumber(phoneNumber) else {
            return false // Return false if email or phone number validation fails.
        }
        
        resetError() // Reset error messages if all inputs are valid.
        return true
    }
    
    // Helper method to validate an email address.
    private func validateEmail(_ email: String) -> Bool {
        let parts = email.split(separator: "@")
        guard parts.count == 2, parts[1].contains(".") else {
            setErrorMessage("Please enter a valid email address") // Set error if email is invalid.
            return false
        }
        return true
    }
    
    // Helper method to validate a phone number.
    private func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        guard phoneNumber.isEmpty || (phoneNumber.first == "+" && phoneNumber.dropFirst().allSatisfy({ $0.isNumber })) else {
            setErrorMessage("Please enter a valid phone number format.") // Set error if phone number is invalid.
            return false
        }
        return true
    }
    
    // Method to set the error message and make the error message visible.
    private func setErrorMessage(_ message: String) {
        errorMessage = message
        isErrorMessageVisible = true
    }
    
    // Method to reset the error message and hide the error visibility.
    private func resetError() {
        errorMessage = ""
        isErrorMessageVisible = false
    }
}
