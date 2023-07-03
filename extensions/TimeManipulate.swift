//
//  Time.swift
//  SciencePark
//
//  Created by Alan Ma on 10/2/2020.
//  Copyright © 2020 Innopage. All rights reserved.
//

import Foundation

enum TimeStyle: Int {
    case short
    case long
}

struct Time: Equatable {
    var hour, minute: Int
    var timeStyle: TimeStyle = .short
}

extension Time {
    static var max: Time {
        return Time(hour: Int.max, minute: Int.max)
    }
    
    static var now: Time {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: Date())
        return Time(hour: dateComponents.hour ?? Int.max, minute: dateComponents.minute ?? Int.max)
    }
    
    func toMinutes() -> Int {
        return self.hour * 60 + self.minute
    }
    
    func longHourSymbol() -> String {
        if hour < 0  {
            return ""
        }
        
        if hour == 1 {
            if minute % 60 >= 30 {
                return "hours".i18n()
            }
            return "hour".i18n()
        }
        
        return "hours".i18n()
    }
    
    func longMinuteSymbol() -> String {
        if minute < 0  {
            return ""
        }
        
        if minute == 1 {
            return "minute".i18n()
        }
        
        return "minutes".i18n()
    }
    
    func shortHourSymbol() -> String {
        if hour < 0  {
            return ""
        }
        
        if hour <= 1 {
            return "hr".i18n()
        }
        
        return "hrs".i18n()
    }
    
    func shortMinuteSymbol() -> String {
        if minute < 0  {
            return ""
        }
        
        if minute <= 1 {
            return "min".i18n()
        }
        
        return "mins".i18n()
    }
    
    func hourString() -> String {
        if self == Time.max {
            return ""
        }
        
        return String(hour) + " \(currentHourSymbol()) "
    }
    
    func minuteString() -> String {
        if self == Time.max {
            return ""
        }
        
        return String(minute) + " \(currentMinuteSymbol()) "
    }
    
    func currentHourSymbol() -> String {
        if timeStyle == .short {
            return shortHourSymbol()
        }
        else {
            return longHourSymbol()
        }
    }
    
    func currentMinuteSymbol() -> String {
        if timeStyle == .short {
            return shortMinuteSymbol()
        }
        else {
            return longMinuteSymbol()
        }
    }
    
    func toString() -> String {
        var result = ""
        
//        if timeStyle == .short {
//            hourSymbol = shortHourSymbol()
//            minuteSymbol = shortMinuteSymbol()
//        }
//        else {
//             hourSymbol = longHourSymbol()
//             minuteSymbol = longMinuteSymbol()
//        }
        
        if self == Time.max {
            return result
        }
        
        if hour == 0 && minute == 0 {
            return "0 " + "min".i18n()
        }
        
        if hour > 0 {
//            result = String(hour) + " \(currentHourSymbol()) "
            result = hourString()
            
            if minute == 0 {
                return result
            }
        }
        
        if minute >= 0 {
//            result += String(minute) + " \(currentMinuteSymbol()) "
            result += minuteString()
        }
        return result
    }
}
