//
//  test.swift
//  Nerv_mk1
//
//  Created by James Hallett on 26/01/2024.
//

import SwiftUI

struct test: View {
    @State private var selectedWard = ""
    
    @EnvironmentObject var viewModel: AuthViewModel // If you're using this, ensure it's provided as an environment object to your view.
    @StateObject private var viewModel_request = RequestAuthModel()
    @StateObject var authViewModel = AuthViewModel() // This seems to be the object fetching and storing wards.
    
    var body: some View {
        VStack{
            HStack {
                // User can select wards from database array updates in realtime
                Picker(selection: $selectedWard, label: Text("Home Page")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)) {
                        ForEach(authViewModel.wards, id: \.self) { ward in
                            Text(ward).tag(ward)
                        }
                }
            }
            
            Carousel(items: 5) { item in
                RoundedRectangle(cornerRadius: 15)
                    .fill(.gray)
                    .opacity(0.5)
                    .shadow(radius: 10.0)
                    .padding()
                    .overlay(Text(String(item)).font(.title).foregroundColor(.white))
                    .carouselItem()
            }
            .padding(.top)
        }
        .onAppear{
            authViewModel.fetchWards()
        }
    }
}

#Preview {
    test()
}
