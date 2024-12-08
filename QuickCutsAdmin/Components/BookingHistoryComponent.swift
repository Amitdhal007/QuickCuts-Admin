//
//  BookingHistoryComponent.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import SwiftUI

struct BookingHistoryComponent: View {
    var bookingStatus: String
    
    var body: some View {
        HStack (spacing: 20) {
            Image("food_14")
                .resizable()
                .frame(width: 100, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            VStack (alignment: .leading, spacing: 15) {
                VStack {
                    Text("Salon Luxe")
                        .font(.custom("Poppins-Semibold", size: 18))
                        .foregroundStyle(Color("textColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("5 Sep, 10:30 AM")
                        .font(.custom("Poppins-Light", size: 14))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    if bookingStatus == "Upcoming" {
                        Text("Upcoming")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundStyle(Color("buttonColor"))
                        
                        Spacer()
                        
                        Button(action: {}, label: {
                            Text("Cancel")
                                .font(.custom("Poppins-Regular", size: 16))
                                .padding([.top, .bottom], 6)
                                .padding([.leading, .trailing], 10)
                                .background(Color("buttonColor"))
                                .foregroundStyle(.white)
                                .cornerRadius(8)
                        })
                    } else if bookingStatus == "Completed" {
                        Text("Completed")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundStyle(Color("buttonColor"))
                        
                        Spacer()
                        
                        Button(action: {}, label: {
                            Text("Review")
                                .font(.custom("Poppins-Regular", size: 16))
                                .padding([.top, .bottom], 6)
                                .padding([.leading, .trailing], 10)
                                .background(Color("buttonColor"))
                                .foregroundStyle(.white)
                                .cornerRadius(8)
                        })
                    }
                    else {
                        Text("Cancelled")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundStyle(Color("buttonColor"))
                           
                        Spacer()
                        
                        Button(action: {}, label: {
                            Text("Reason")
                                .font(.custom("Poppins-Regular", size: 16))
                                .padding([.top, .bottom], 6)
                                .padding([.leading, .trailing], 10)
                                .background(Color("buttonColor"))
                                .foregroundStyle(.white)
                                .cornerRadius(8)
                        })
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6).opacity(0.6))
        .cornerRadius(10)
    }
}

#Preview {
    BookingHistoryComponent(bookingStatus: "Upcoming")
}
