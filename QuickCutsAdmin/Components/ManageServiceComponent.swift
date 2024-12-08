//
//  ManageServiceComponent.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ManageServiceComponent: View {
    var service: Service
    
    var body: some View {
        HStack (spacing: 20) {
            
            if let imageUrl = service.serviceImage, let url = URL(string: imageUrl) {
                WebImage(url: url) { image in
                    image.image
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .aspectRatio(contentMode: .fill)
                }
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .frame(width: 100, height: 110)
            } else {
                Image("Haircut")
                    .resizable()
                    .frame(width: 100, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
                
            VStack (alignment: .leading, spacing: 15) {
                VStack {
                    Text(service.name ?? "Hair Cut")
                        .font(.custom("Poppins-Semibold", size: 18))
                        .foregroundStyle(Color("textColor"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(service.price ?? 0)")
                        .font(.custom("Poppins-Light", size: 14))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack (spacing: 14) {
                    Button(action: {}, label: {
                        Text("Update")
                            .font(.custom("Poppins-Regular", size: 16))
                            .padding([.top, .bottom], 6)
                            .padding(.horizontal)
                            .background(Color("buttonColor"))
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    })
                    
                    Button(action: {}, label: {
                        Text("Remove")
                            .font(.custom("Poppins-Regular", size: 16))
                            .padding([.top, .bottom], 6)
                            .padding(.horizontal)
                            .background(Color("buttonColor"))
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    })
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6).opacity(0.6))
        .cornerRadius(10)
    }
}

