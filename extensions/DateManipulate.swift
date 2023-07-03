//
//  Date.swift
//  SciencePark
//
//  Created by Alan Ma on 6/2/2020.
//  Copyright © 2020 Innopage. All rights reserved.
//

import Foundation

extension Date {
    // for sp bus time comparison
    // server returned sp bus time date is always in 1/1/2000
    // set the Date()'s to 1/1/2000 for comparison
    func currentTime() -> Date {
        let calendar = Calendar.current
        var dateComponents: DateComponents? = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        dateComponents?.year = 2000
        dateComponents?.month = 1
        dateComponents?.day = 1
        return calendar.date(from: dateComponents!)!
    }

    func subtractMinutes(minute: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: -minute, to: self)!
    }
    
    func isExpired() -> Bool {
        return self < Date()
    }
    
    func toChatDisplayTime() -> String? {
        if Calendar.current.isDateInToday(self) {
            return DateFormatter.shortTimeFormatter.string(for: self)
        }
        else {
            return DateFormatter.shortDateFormatter.string(for: self)
        }
    }

    static func - (left: Date, right: Date) -> Time {
        let elapsedTime = left.timeIntervalSince(right)
        let hour = floor(elapsedTime / 60 / 60)
        let minute = floor((elapsedTime - (hour * 60 * 60)) / 60)
        
//        return Time(hour: Int(hour), minute: Int(minute) + 1)
        return Time(hour: Int(hour), minute: Int(minute) + 1)
    }
}

private extension Calendar {
    func toUTC() -> Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }
}
