//
//  AdminSignUpView.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import SwiftUI

struct AdminSignUpView: View {
    @State var salonName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var address: String = ""
    @State var openingTime: Date = Date()
    @State var closingTime: Date = Date()
    @ObservedObject var viewModel: MainViewModel
        
    
    @FocusState var focusedField: Field?
    @Environment(\.presentationMode) var presentationMode
    
    enum Field: Hashable {
        case salonName, email, phoneNumber, address, password
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
                
                    Text("Sign Up")
                        .font(.custom("Poppins-Regular", size: 24).bold())
                        .foregroundColor(.init("textColor"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.trailing, 22)
                    
                     
                }
                .padding([.top, .bottom], 10)
                
                VStack(alignment: .leading) {
                    Text("Salon Name")
                        .font(.headline)
                    TextField("Enter your Salon Name", text: $salonName)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .focused($focusedField, equals: .salonName)
                }
                
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.headline)
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .focused($focusedField, equals: .email)
                }
                
                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.headline)
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .focused($focusedField, equals: .phoneNumber)
                }
                
                VStack(alignment: .leading) {
                    Text("Address")
                        .font(.headline)
                    TextField("Enter your Adress", text: $address)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .focused($focusedField, equals: .password)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Operating Hours")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Opening Time")
                                .font(.subheadline)
                            DatePicker(
                                "Select Opening Time",
                                selection: $openingTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Closing Time")
                                .font(.subheadline)
                            DatePicker(
                                "Select Closing Time",
                                selection: $closingTime,
                                displayedComponents: [.hourAndMinute]
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    viewModel.registerSalon(
                        salonName: salonName,
                        email: email,
                        password: password,
                        address: address,
                        openingTime: openingTime,
                        closingTime: closingTime)
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("buttonColor"))
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 16)
        }
        .clipped()
        .onTapGesture {
            focusedField = nil
        }
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
        .fullScreenCover(isPresented: $viewModel.isRegistered) {
            AdminLoginView(viewModel: viewModel)
        }
    }
}


