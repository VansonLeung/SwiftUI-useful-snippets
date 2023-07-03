//
//  VanCalendarViewNative.swift
//  hkstp oneapp testing
//
//  Created by van on 15/8/2022.
//

import Foundation
import SwiftUI

struct VanCalendarViewNative: View {
    private let calendar: Calendar

    @State private var selectedDate = Self.now
    private static var now = Date() // Cache now

    init(calendar: Calendar) {
        self.calendar = calendar
    }

    var body: some View {
        VStack {
            
            let dateRange: ClosedRange<Date> = {
                let calendar = Calendar.current
                let startComponents = DateComponents(year: 2022, month: 8, day: 15)
                let endComponents = DateComponents(year: 2022, month: 12, day: 31, hour: 23, minute: 59, second: 59)
                return calendar.date(from:startComponents)! ... calendar.date(from:endComponents)!
            }()
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: dateRange,
                displayedComponents: .date)
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()
            .tint(.green)
            .foregroundColor(.brown)
            .accentColor(.pink)
            .onChange(of: selectedDate) { newValue in

//                let startDate = initialDate.startOfMonth(using: calendar)
//                let endDate = selectedDate.startOfMonth(using: calendar)
//                let offsetMonths = endDate.months(from: startDate)
//                currentIndex = offsetMonths
                
            }
        }
        .padding()
        .animation(.none, value: selectedDate)
    }
    
    
}


// MARK: - Previews

struct VanCalendarViewNative_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                VanCalendarViewNative(calendar: Calendar(identifier: .gregorian))
                Spacer()
            }
        }
    }
}

