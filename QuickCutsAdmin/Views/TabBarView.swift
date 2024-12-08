//
//  TabBarView.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 22/11/24.
//

import SwiftUI

struct TabBarView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        TabView {
            AdminHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Bookings()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Bookings")
                }
            
            AdminManageServicesView()
                .tabItem {
                    Image(systemName: "square.grid.2x2") 
                    Text("Manage Services")
                }
            
            AdminProfileView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}


