//
//  AdminLoginView.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import SwiftUI

struct AdminLoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @ObservedObject var viewModel: MainViewModel
    
    @FocusState private var focusedField: Field?
    @Environment(\.presentationMode) var presentationMode
    
    enum Field: Hashable {
        case email
        case password
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack(spacing: 20) {
               
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.init("textColor"))
                            .font(.title2)
                            
                    }
                
                    Text("Log In")
                        .font(.custom("Poppins-Regular", size: 24).bold())
                        .foregroundColor(.init("textColor"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.trailing, 22)
                    
                     
                }
                .padding([.top, .bottom], 10)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .foregroundColor(.init("textColor"))
                        .fontWeight(.medium)
                    
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .foregroundColor(.init("textColor"))
                        .fontWeight(.medium)

                    HStack {
                        if isPasswordVisible {
                            TextField("Enter your password", text: $password)
                        } else {
                            SecureField("Enter your password", text: $password)
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .focused($focusedField, equals: .password)
                }

                VStack (spacing: 20) {
                    Button(action: {
                        viewModel.loginSalon(email: email, password: password)
                    }) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.init("buttonColor")))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        
                    }) {
                        Text("Sign up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.init("textColor"))
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 20)

                Spacer()
            }
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
        }
        .clipped()
        .navigationBarHidden(true)
        .onTapGesture {
            focusedField = nil
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

