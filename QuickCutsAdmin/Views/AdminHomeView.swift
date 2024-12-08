//
//  AdminHomeView.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import SwiftUI

struct AdminHomeView: View {
    var body: some View {
        NavigationView {
            ScrollView (showsIndicators: false) {
                VStack (spacing: 20) {
                    VStack(spacing: 16) {
                        Text("Appointments")
                            .font(.custom("Poppins-Regular", size: 24).bold())
                            .foregroundColor(.init("textColor"))
                    }
                    .padding(.top, 10)
                    
                    VStack {
                        Text("Today's")
                            .font(.custom("Poppins-Regular", size: 20).bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.init("textColor"))
                            .padding(.top, 10)
                    }
                    
                    ForEach (0...4, id: \.self) { _ in
                        BookingHistoryComponent(bookingStatus: "Upcoming")
                    }
                }
            }
             .clipped()
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    AdminHomeView()
}
