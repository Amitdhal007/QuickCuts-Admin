//
//  ContentView.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        if viewModel.isLoggedIn {
            TabBarView(viewModel: viewModel)
        } else {
            InitialView(viewModel: viewModel)
        }
    }
}
