//
//  Menu.swift
//  LittleLemon
//
//  Created by Nouf Faisal  on 14/11/1445 AH.
//


import SwiftUI
import CoreData

// Define a struct named Menu that conforms to the View protocol.
struct Menu: View {
    
    @Environment(\.managedObjectContext) private var viewContext // Access to the CoreData managed object context.
    
    // State variables to manage the visibility of different menu categories.
    @State var startersIsEnabled = true
    @State var mainsIsEnabled = true
    @State var dessertsIsEnabled = true
    @State var drinksIsEnabled = true
    
    // State variable to handle search functionality.
    @State var searchText = ""
    
    // State to check if the data is loaded.
    @State var loaded = false
    
    // State to track if the keyboard is visible.
    @State var isKeyboardVisible = false
    
    // State to manage selected dish details.
    @State private var selectedDish: Dish? = nil
    
    // Custom initialization to modify the appearance of all text fields in this view.
    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    // Conditionally display the HeroView unless the keyboard is visible.
                    if !isKeyboardVisible {
                        withAnimation() {
                           HeroView() // A custom view showing a promotional banner.
                        }
                    }
                    // Search bar to filter the menu.
                    TextField("Search menu", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Color.primaryColor1)
                
                // Display a static text heading for the menu.
                Text("ORDER FOR DELIVERY!")
                    .font(.sectionTitle())
                    .foregroundColor(.highlightColor2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    .padding(.leading)
                
                // Horizontal scroll view for toggling different menu categories.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        Toggle("Starters", isOn: $startersIsEnabled)
                        Toggle("Mains", isOn: $mainsIsEnabled)
                        Toggle("Desserts", isOn: $dessertsIsEnabled)
                        Toggle("Drinks", isOn: $drinksIsEnabled)
                    }
                    .toggleStyle(CustomToggleStyle()) // Apply a custom toggle style.
                    .padding(.horizontal)
                }
                
                // A fetched results list that uses a predicate and sort descriptors to filter and order the dishes.
                FetchedObjects(predicate: buildPredicate(),
                               sortDescriptors: buildSortDescriptors()) {
                    (dishes: [Dish]) in
                    List(dishes) { dish in
                        Button(action: {
                            self.selectedDish = dish // Set the selected dish when a list item is tapped.
                        }) {
                            // Custom list item layout for each dish.
                            HStack {
                                VStack {
                                    Text(dish.title ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.sectionCategories())
                                        .foregroundColor(.black)
                                    Spacer(minLength: 10)
                                    Text(dish.descriptionDish ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.paragraphText())
                                        .foregroundColor(.primaryColor1)
                                        .lineLimit(2)
                                    Spacer(minLength: 5)
                                    Text("$" + (dish.price ?? ""))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.highlightText())
                                        .foregroundColor(.primaryColor1)
                                        .monospaced()
                                }
                                AsyncImage(url: URL(string: dish.image ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(maxWidth: 90, maxHeight: 90)
                                .clipShape(Rectangle())
                            }
                            .padding(.vertical)
                            .frame(maxHeight: 150)
                        }
                        .sheet(item: $selectedDish) { dish in
                            // Detail view for the selected dish, showing in a modal sheet.
                            ScrollView {
                                AsyncImage(url: URL(string: dish.image ?? "")) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(Rectangle())
                                .frame(minHeight: 150)
                                Text(dish.title ?? "")
                                    .font(.subTitleFont())
                                    .foregroundColor(.primaryColor1)
                                Spacer(minLength: 20)
                                Text(dish.descriptionDish ?? "")
                                    .font(.regularText())
                                Spacer(minLength: 10)
                                Text("$" + (dish.price ?? ""))
                                    .font(.highlightText())
                                    .foregroundColor(.primaryColor1)
                                    .monospaced()
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .ignoresSafeArea()
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .onAppear {
            // Fetch menu data from Core Data when the view appears if not already loaded.
            if !loaded {
                MenuList.getMenuData(viewContext: viewContext)
                loaded = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            withAnimation {
                self.isKeyboardVisible = true
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            withAnimation {
                self.isKeyboardVisible = false
            }
        }
    }
    
    // Helper function to build sort descriptors for fetching data.
    func buildSortDescriptors() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare))]
    }
    
    // Helper function to build a predicate for filtering data based on the search text and category toggles.
    func buildPredicate() -> NSCompoundPredicate {
        let search = searchText == "" ? NSPredicate(value: true) : NSPredicate(format: "title CONTAINS[cd] %@", searchText)
        let starters = !startersIsEnabled ? NSPredicate(format: "category != %@", "starters") : NSPredicate(value: true)
        let mains = !mainsIsEnabled ? NSPredicate(format: "category != %@", "mains") : NSPredicate(value: true)
        let desserts = !dessertsIsEnabled ? NSPredicate(format: "category != %@", "desserts") : NSPredicate(value: true)
        let drinks = !drinksIsEnabled ? NSPredicate(format: "category != %@", "drinks") : NSPredicate(value: true)

        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [search, starters, mains, desserts, drinks])
        return compoundPredicate
    }
    
    // Definition of HeroView used in this view for promotional content.
    struct HeroView: View {
        var body: some View {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Little Lemon")
                            .foregroundColor(Color.primaryColor2)
                            .font(.displayFont())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Chicago")
                            .foregroundColor(.white)
                            .font(.subTitleFont())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer(minLength: 5)
                        Text("""
                             We are a family owned Mediterranean restaurant, focused on traditional recipes served with a modern twist.
                             """)
                        .foregroundColor(.white)
                        .font(.leadText())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Image("hero-image")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: 120, maxHeight: 140)
                        .clipShape(Rectangle())
                        .cornerRadius(16)
                }
            }
            .frame(maxHeight: 180)
        }
    }
}

// Provides a preview of the Menu view.
struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
