//
//  AdminProfileView.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 22/11/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct AdminProfileView: View {
    
    @ObservedObject var viewModel: MainViewModel
    @State private var isImagePickerPresented: Bool = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color("textColor"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding([.trailing, .top])
                
                VStack(spacing: 10) {
                    if let image = viewModel.profileImageURL, let url = URL(string: image) {
                        WebImage(url: url) { image in
                            image.image
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fill)
                        }
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .frame(width: 120, height: 120)
                        .onTapGesture {
                            isImagePickerPresented = true
                        }
                    } else {
                        
                        if let image = AppDataManager.shared.getSalon()?.mainPicture, let url = URL(string: image) {
                            WebImage(url: url) { image in
                                image.image
                                    .clipShape(Circle())
                                    .aspectRatio(contentMode: .fill)
                            }
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .frame(width: 120, height: 120)
                            .onTapGesture {
                                isImagePickerPresented = true
                            }
                        }
                        else {
                            Image("rabbit")
                                .resizable()
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .onTapGesture {
                                    isImagePickerPresented = true
                                }
                        }
                    }


                    VStack (spacing: 0) {
                        Text(viewModel.salonDetails?.name ?? "John Doe")
                            .font(.custom("Poppins-Regular", size: 24).bold())
                            .foregroundColor(Color("textColor"))
                        
                        Text(viewModel.salonDetails?.email ?? "john.doe@gmail.com")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(Color("textColor"))
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Account Settings")
                    .font(.custom("Poppins-Regular", size: 24).bold())
                    .foregroundColor(Color("textColor"))
                    .padding(.horizontal)
                    .padding(.bottom)
                
                VStack(spacing: 0) {
                    NavigationLink(destination: Text("My Bookings")) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(Color("textColor"))
                            Text("My Bookings")
                                .font(.custom("Poppins-Regular", size: 18))
                                .foregroundColor(Color("textColor"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    Divider()
                    
                    NavigationLink(destination: Text("Salon Images")) {
                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(Color("textColor"))
                            Text("Salon Images")
                                .font(.custom("Poppins-Regular", size: 18))
                                .foregroundColor(Color("textColor"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    Divider()
                    
                    NavigationLink(destination: Text("Edit Profile")) {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(Color("textColor"))
                            Text("Edit Profile")
                                .font(.custom("Poppins-Regular", size: 18))
                                .foregroundColor(Color("textColor"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    Divider()
                    
                    NavigationLink(destination: Text("Settings")) {
                        HStack {
                            Image(systemName: "gearshape")
                                .foregroundColor(Color("textColor"))
                            Text("Settings")
                                .font(.custom("Poppins-Regular", size: 18))
                                .foregroundColor(Color("textColor"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.logOutSalon()
                }) {
                    Text("LogOut")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("buttonColor"))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.top, 30)
                }
            }
            .padding(.top, 30)
            
            Spacer()
        }
        .clipped()
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, isPresented: $isImagePickerPresented)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                uploadImage(image: image)
            }
        }
        .onAppear {
            viewModel.getProfile()
        }
    }
    
    private func uploadImage(image: UIImage) {
        viewModel.updateMainPicture(serviceImage: image)
    }
    
    
}


