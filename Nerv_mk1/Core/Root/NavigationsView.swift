


//
//  NavigationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
////  NavigationView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 07/11/2023.
//

import SwiftUI
// Getting timestamp for date-of-birth formatting
import Firebase

struct NavigationsView: View {
    @State private var showMenu: Bool = false
    @State private var selectedQuote: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    private let quotes = [
        "You have power over your mind - not outside events. Realize this, and you will find strength.",
        "The happiness of your life depends upon the quality of your thoughts.",
        "Waste no more time arguing about what a good man should be. Be one.",
        "If you are distressed by anything external, the pain is not due to the thing itself, but to your estimate of it; and this you have the power to revoke at any moment.",
        "The best revenge is to be unlike him who performed the injury.",
        "Very little is needed to make a happy life; it is all within yourself, in your way of thinking.",
        "Accept the things to which fate binds you, and love the people with whom fate brings you together, but do so with all your heart."
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main body for active tasks
                VStack {
                    // Top of page
                    HStack {
                        Text("Nerv")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    
                    Divider()
                        .padding(.top, 30)

                    
                    if viewModel.patientRefs.isEmpty {
                        Text("No Active Cases")
                    } else {
                        // Convert the count to String to concatenate
                        Text("\(viewModel.patientRefs.count) - Active Cases")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    Divider()
                    
                    // Middle of page displaying inspirational quotes
                    Group{
                        Text(selectedQuote)
                            .padding()
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                            .onAppear {
                                selectedQuote = quotes.randomElement() ?? ""
                            }
                    }
                    
                    
                    Spacer()
                    Spacer()
                    
                    
                    // Bottom of page
                    Divider()
                        .padding(.horizontal, 50)
                    
                    HStack {
                        
                    }
                    .padding()
                }
                
                GeometryReader { geometry in
                    HStack {
                        SideMenuView()
                            .offset(x: showMenu ? 0 : -geometry.size.width * 0.7)
                            .animation(.easeInOut(duration: 0.3), value: showMenu)
                    }
                }
                
                .background(Color.black.opacity(showMenu ? 0.7 : 0))
                .animation(.easeInOut(duration: 0.3), value: showMenu)
                
                // Top navigation bar with button (positioned in the top-left corner)
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            Button(action: {
                                // When the button is pressed, toggle the showMenu state
                                self.showMenu.toggle()
                            }) {
                                // Change icon based on the showMenu state
                                if showMenu {
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                        .offset(x: 10)
                                } else {
                                    Image(systemName: "text.justify")
                                        .font(.title)
                                        .foregroundColor(.gray)
                                        .offset(x: 10)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding()
                    }
                }
            }
            .onAppear(){
                Task{
                    await viewModel.fetchPatientRefs()
                }
            }
        }
    }
}

extension DateFormatter {
    static let mediumStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

struct ImageView: View {
    @StateObject private var loader = ImageLoader()
    let urlString: String
    @Binding var selectedImageUrl: URL?
    @Binding var showImageOverlay: Bool
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .blur(radius: 7)
                    .onTapGesture {
                        self.selectedImageUrl = URL(string: urlString)
                        self.showImageOverlay = true
                    }
            } else {
                ProgressView()
                    .onAppear {
                        loader.loadImage(fromURL: urlString)
                    }
            }
        }
    }
}
struct ImageOverlayView: View {
    let imageUrl: URL
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .padding()

            AsyncImage(url: imageUrl) { image in
                image.resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.6))
    }
}

#Preview {
    NavigationsView()
}
