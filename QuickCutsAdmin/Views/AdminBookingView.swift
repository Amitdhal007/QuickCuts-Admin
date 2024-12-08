//
//  AdminBookingView.swift
//  QuickCutsAdmin
//
//  Created by Amit Kumar Dhal on 20/11/24.
//

import SwiftUI

struct Bookings: View {
    @State var selectedSegment: Int = 0
    let segmentOptions: [String] = ["Upcoming", "Completed", "Cancelled"]
    
    var body: some View {
        NavigationView {
            ScrollView (showsIndicators: false) {
                VStack (spacing: 20) {
                    VStack(spacing: 16) {
                        Text("Booking History")
                            .font(.custom("Poppins-Regular", size: 24).bold())
                            .foregroundColor(.init("textColor"))
                    }
                    .padding(.top, 10)
                    
                    Picker("Options", selection: $selectedSegment) {
                        ForEach(0..<segmentOptions.count, id: \.self) { index in
                            Text(self.segmentOptions[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 10)
                    
                    if selectedSegment == 0 {
                        ForEach (0...4, id: \.self) { _ in
                            BookingHistoryComponent(bookingStatus: "Upcoming")
                        }
                    }
                }
            }
             .clipped()
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    Bookings()
}
