//
//  VanCalendarPagerView.swift
//  hkstp oneapp testing
//
//  Created by van on 12/8/2022.
//

import Foundation
import SwiftUI

struct VanCalendarPagerView: View {
    private let calendar: Calendar
    private let yearMonthFormatter: DateFormatter
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let weekDayLongFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now
    @State private var initialDate = Self.now
    private static var now = Date() // Cache now
    
    @State private var pageCount: Int = 5
    @State private var currentIndex: Int = 0
    @State private var currentIndexPercent: CGFloat = 0
    
    
    @State private var isMonthPicker: Bool = false
//    @State private var monthIndex: Int = -1
//    @State private var yearIndex: Int = -1

    init(calendar: Calendar) {
        self.calendar = calendar
        self.yearMonthFormatter = DateFormatter(dateFormat: "MMMM yyyy", calendar: calendar)
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter.shortWeekdayFormatter
        self.weekDayLongFormatter = DateFormatter(dateFormat: "EEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
    }
    
    
    var monthSymbols: [String] {
        return calendar.monthSymbols
    }
    
    
    var yearSymbols: [String] {
        return (calendar.dateComponents([.month], from: Self.now).month! + pageCount >= 12 ? [
            calendar.dateComponents([.year], from: Self.now).year!,
            calendar.dateComponents([.year], from: Self.now).year! + 1,
        ] : [
            calendar.dateComponents([.year], from: Self.now).year!,
        ]).map { it in
            "\(it)"
        }
    }
    
    

    var body: some View {
        VStack(spacing: 0) {
            Text("Selected date: \(fullFormatter.string(from: selectedDate))")
                .bold()
                .foregroundColor(.red)
            
            TitleView
                .padding(.trailing, 8)

            
            if isMonthPicker {
//
//                GeometryReader{ geometry in
//                    HStack(spacing: 0) {
//                        Picker(selection: self.$monthIndex.onChange(self.monthChanged), label: Text("")) {
//                            ForEach(0..<self.monthSymbols.count) { index in
//                                Text(self.monthSymbols[index])
//                            }
//                        }.frame(maxWidth: geometry.size.width / 3 * 2).clipped()
//                        Picker(selection: self.$yearIndex.onChange(self.yearChanged), label: Text("")) {
//                            ForEach(0..<self.yearSymbols.count) { index in
//                                Text(String(self.yearSymbols[index]))
//                            }
//                        }.frame(maxWidth: geometry.size.width / 3 * 1).clipped()
//                    }
//                }
                
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
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .onChange(of: selectedDate) { newValue in

                    let startDate = initialDate.startOfMonth(using: calendar)
                    let endDate = selectedDate.startOfMonth(using: calendar)
                    let offsetMonths = endDate.months(from: startDate)
                    currentIndex = offsetMonths
                    
                }
                
            } else {

                TP1PageSpacer(h: 16)
                
                GenericPagerView(
                    pageCount: pageCount,
                    currentIndex: $currentIndex,
                    currentIndexPercent: $currentIndexPercent,
                    autoScrollSeconds: 0,
                    width: UIScreen.main.bounds.width,
                    isDisableGesture: false,
                    isUseLowPriorityGesture: false) {
                        
                        ForEach(0 ..< pageCount, id: \.self) { index in
                            if abs(currentIndex - index) > 1 {
                                ZStack{}
                                    .frame(
                                        width: UIScreen.main.bounds.width
                                    )
                            } else {
                                CalendarViewBlock(
                                    calendar: calendar,
                                    selectedDate: $selectedDate,
                                    initialDate: $initialDate,
                                    dateMonthIncrement: index,
                                    monthFormatter: monthFormatter,
                                    dayFormatter: dayFormatter,
                                    weekDayFormatter: weekDayFormatter,
                                    weekDayLongFormatter: weekDayLongFormatter,
                                    fullFormatter: fullFormatter
                                )
                                .frame(
                                    width: UIScreen.main.bounds.width
                                )
                            }
                        }

                    }
                    .padding(.horizontal, 20)
                    .animation(.none, value: selectedDate)

                
            }

        }
    }
    
    
    
    
    var TitleView: some View {
        
        HStack(spacing: 0) {
            
            
            Button {
                
                withAnimation {
                    isMonthPicker.toggle()
                }
                
            } label: {
                HStack(spacing: 4) {
                    Text(yearMonthFormatter.string(
                        from: calendar.date(
                            byAdding: .month,
                            value: currentIndex,
                            to: initialDate)
                        ?? Self.now)
                    )
                    .modifier(TP1AppTextViewModifier(
                        viewElementStyles: .shared,
                        typography: .en_lead_lead2_med,
                        fontColor: isMonthPicker ? .primary : .body))
                    
                    Icon(icon: isMonthPicker ? "ic_mg_general_chevron_down_primary" : "ic_mg_general_chevron_right", iconSize: 16)
                }
                .padding(.leading, 20)
                .padding(.trailing, 16)
                .frame(maxHeight: .infinity)
                .debugFrameSize()
                .contentShape(Rectangle())
            }

            
            Spacer()
            Button {
                
                if currentIndex - 1 >= 0 {
                    currentIndex -= 1
                }

            } label: {
                RoundedIcon(
                    bgColor: .clear,
                    size: 48,
                    icon: "ic_mg_general_chevron_left",
                    iconSize: 24)
                .contentShape(Rectangle())
                .debugFrameSize()
            }
            Button {
                
                if currentIndex + 1 < pageCount {
                    currentIndex += 1
                }

            } label: {
                RoundedIcon(
                    bgColor: .clear,
                    size: 48,
                    icon: "ic_mg_general_chevron_right",
                    iconSize: 24)
                .contentShape(Rectangle())
                .debugFrameSize()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .debugFrameSize()
    }
    
    
    
    struct CalendarViewBlock: View {
        
        var calendar: Calendar
        @Binding var selectedDate : Date
        @Binding var initialDate : Date
        var dateMonthIncrement : Int
        
        var monthFormatter: DateFormatter
        var dayFormatter: DateFormatter
        var weekDayFormatter: DateFormatter
        var weekDayLongFormatter: DateFormatter
        var fullFormatter: DateFormatter

        var body: some View {
            
            CalendarViewInterior(
                calendar: calendar,
                date: $selectedDate,
                initialDate: $initialDate,
                dateMonthIncrement: dateMonthIncrement,
                content: { date in
                    Button(action: { selectedDate = date }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(
                                    calendar.isDate(date, inSameDayAs: selectedDate) ? TP1ViewElementStyles.shared.activeColorTheme.color_primary
                                    : calendar.isDateInToday(date) ? .clear
                                    : .clear
                                )
                            
                            Text(dayFormatter.string(from: date))
                                .modifier(TP1AppTextViewModifier(viewElementStyles: .shared,
                                                                 typography:
                                                                    calendar.isDate(date, inSameDayAs: selectedDate) ? .en_body_body2_semibold
                                                                    : calendar.isDateInToday(date) ? .en_body_body2_reg
                                                                    : .en_body_body2_reg,
                                                                 fontColor:
                                                                    calendar.isDate(date, inSameDayAs: selectedDate) ? .negative
                                                                    : calendar.isDateInToday(date) ? .body
                                                                    : .body
                                                                ))
                                .accessibilityHidden(true)
                                .transition(.fade(duration: 0.2))
                        }
                            .padding(.all, 6)
                            .contentShape(Rectangle())
                    }
                    .frame(
                        width: (UIScreen.main.bounds.width - 40) / 7,
                        height: (UIScreen.main.bounds.width - 40) / 7
                    )
                    .transition(.fade(duration: 0.2))
                    .id(date)
                    .debugFrameSize()
                },
                trailing: { date in
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(.clear)
                        .transition(.fade(duration: 0.2))
                        .id(date)
                },
                header: { date in
                    VStack(spacing: 8) {
                        Text(weekDayFormatter.string(from: date))
                            .modifier(TP1AppTextViewModifier(viewElementStyles: .shared, typography: .en_caption_caption_reg, fontColor: .body))
                            .id(weekDayLongFormatter.string(from: date))
                        TP1PageDivider(h: 1)
                            .padding(.bottom, 16)
                    }
                },
                title: { date in
                    EmptyView()
                }
            )
            .equatable()
        }
    }
    
    
    
    
    // MARK: - Component

    public struct CalendarViewInterior<Day: View, Header: View, Title: View, Trailing: View>: View {
        // Injected dependencies
        private var calendar: Calendar
        @Binding private var date: Date
        @Binding private var initialDate : Date
        private var dateMonthIncrement: Int = 0
        private let content: (Date) -> Day
        private let trailing: (Date) -> Trailing
        private let header: (Date) -> Header
        private let title: (Date) -> Title

        // Constants
        private let daysInWeek = 7

        public init(
            calendar: Calendar,
            date: Binding<Date>,
            initialDate: Binding<Date>,
            dateMonthIncrement: Int = 0,
            @ViewBuilder content: @escaping (Date) -> Day,
            @ViewBuilder trailing: @escaping (Date) -> Trailing,
            @ViewBuilder header: @escaping (Date) -> Header,
            @ViewBuilder title: @escaping (Date) -> Title
        ) {
            self.calendar = calendar
            self._date = date
            self._initialDate = initialDate
            self.dateMonthIncrement = dateMonthIncrement
            self.content = content
            self.trailing = trailing
            self.header = header
            self.title = title
        }

        public var body: some View {
            let month = initialDate.startOfMonth(using: calendar, addMonth: dateMonthIncrement)
            let days = makeDays()

            return VStack(spacing: 0) {
                LazyVGrid(
                    columns: Array(
                        repeating:
                            GridItem(.adaptive(
                                minimum: 32,
                                maximum: .infinity
                            ), spacing: 0, alignment: .top),
                        count: daysInWeek
                    ),
                    spacing: 0
                ) {
                    Section() {
                        ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                        ForEach(days, id: \.self) { date in
                            if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                                content(date)
                            } else {
                                trailing(date)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .debugFrameSize()
            }
        }
    }

}


// MARK: - Conformances

extension VanCalendarPagerView.CalendarViewInterior: Equatable {
    static func == (lhs: VanCalendarPagerView.CalendarViewInterior<Day, Header, Title, Trailing>, rhs: VanCalendarPagerView.CalendarViewInterior<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

extension VanCalendarPagerView.CalendarViewInterior {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: initialDate.dateOfMonth(using: calendar, addMonth: dateMonthIncrement)),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}

// MARK: - Helpers

private extension Calendar {
    func generateCalendarDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }

            guard date < dateInterval.end else {
                stop = true
                return
            }

            dates.append(date)
        }

        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateCalendarDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar, addMonth: Int = 0) -> Date {
        calendar.date(
            byAdding: .month,
            value: addMonth,
            to:
                calendar.date(
                    from: calendar.dateComponents([.year, .month], from: self)
                ) ?? self
        ) ?? self
    }
    
    func dateOfMonth(using calendar: Calendar, addMonth: Int = 0) -> Date {
        calendar.date(
            byAdding: .month,
            value: addMonth,
            to:
                calendar.date(
                    from: calendar.dateComponents([.year, .month, .day], from: self)
                ) ?? self
        ) ?? self
    }
    
    

/// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

// MARK: - Previews

struct CalendarPagerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                VanCalendarPagerView(calendar: Calendar(identifier: .gregorian))
                Spacer()
            }
        }
    }
}
