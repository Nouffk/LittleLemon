//
//  Home.swift
//  LittleLemon
//
//  Created by Nouf Faisal  on 14/11/1445 AH.
//

import SwiftUI

// Define a struct named Home that conforms to the View protocol.
struct Home: View {
    @Environment(\.managedObjectContext) private var viewContext  // Access the CoreData managed object context.
    @State private var isLoggedIn = false  // State variable to track login status within the Home view.

    // The body property that provides the UI of the view.
    var body: some View {
        NavigationStack {
            VStack {
                headerView()  // Call the header function to create a header view at the top of the screen.
                Menu()  // Embed the Menu view defined elsewhere.
            }
        }
        .navigationBarBackButtonHidden()  // Hide the navigation bar back button.
    }
    
    // Define a function to create the header view using a custom ViewBuilder to conditionally include elements.
    @ViewBuilder
    private func headerView() -> some View {
        VStack {
            ZStack {
                Image("Logo")  // Display the logo image.
                HStack {
                    Spacer()  // Push content to the right.
                    if isLoggedIn {  // Conditionally display the user profile link if logged in.
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
        .onAppear() {  // Check the login status when the view appears and update the state.
            isLoggedIn = UserDefaults.standard.bool(forKey: kIsLoggedIn)
        }

    }
}

// Provides a preview of the Home view.
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
