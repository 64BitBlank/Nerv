//
//  ProfileView.swift
//  Nerv_mk1
//
//  Created by James Hallett on 01/11/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        
        // User has to be present in order for anything to be rendered onscreen
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section("General") {
                    HStack {
                        SettingsRowView(imageName: "gear",
                                        title: "Version",
                                        tintColor: Color(.systemGray))
                        Spacer()
                        
                        Text("Alpha 1.0.0")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                }
                Section("Account") {
                    Button{
                        viewModel.signOut()
                    }label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill",
                                        title: "Sign Out",
                                        tintColor: .red)
                    }
                }
                Section("Wards"){
                    NavigationLink(destination: WardSelectionView()) {
                        HStack {
                            Text("Ward Options")
                            Spacer()
                            Image(systemName: "arrow.right.circle")
                        }
                    }
                }
                Section("Logs"){
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.userActivityLogs.reversed(), id: \.self) { log in
                                Text(log)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(15)
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                        .frame(maxHeight: 250)
                }
            }
            .onAppear(){
                Task{
                    await viewModel.fetchUserActivityLogs()
                }
            }
        } else{
            Text("Some how you got into this app without an account registered... Wizard!")
        }
    }
}

#Preview {
    ProfileView()
}
