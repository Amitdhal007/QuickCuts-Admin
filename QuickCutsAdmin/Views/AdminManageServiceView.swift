//
//  AdminManageServiceView.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import SwiftUI

struct AdminManageServicesView: View {
    @State var isAddServicePresented: Bool = false
    @StateObject var viewModel: MainViewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Manage Service")
                        .font(.custom("Poppins-Regular", size: 24).bold())
                        .foregroundColor(.init("textColor"))
                        .padding(.top, 10)
                    
                    ForEach(viewModel.services!, id: \.id) { service in
                        ManageServiceComponent(service: service)
                    }
                }
                .padding(.horizontal, 16)
                .onAppear {
                    viewModel.fetchSalonServices()
                }
            }
            .clipped()
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.isServiceAdded ? "Success" : "Error"),
                    message: Text(viewModel.isServiceAdded
                                  ? "Service added successfully!"
                                  : (viewModel.errorMessage ?? "An unknown error occurred.")),
                    dismissButton: .default(Text("OK"))
                )
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isAddServicePresented = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28))
                            .frame(width: 56, height: 56)
                            .foregroundColor(.white)
                            .background(Color("buttonColor"))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.horizontal, 16)
                    .sheet(isPresented: $isAddServicePresented) {
                        AddNewServiceView(
                            isAddServicePresented: $isAddServicePresented,
                            viewModel: viewModel
                        )
                    }
                }
            }
        }
    }
}
