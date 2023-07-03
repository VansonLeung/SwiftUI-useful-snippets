//
//  GenericCalendarViewV2.swift
//  hkstp oneapp testing
//
//  Created by van on 12/8/2022.
//

import Foundation
import SwiftUI

struct VanCalendarView: View {
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let weekDayLongFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @State private var selectedDate = Self.now
    private static var now = Date() // Cache now

    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter.shortWeekdayFormatter
        self.weekDayLongFormatter = DateFormatter(dateFormat: "EEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
    }

    var body: some View {
        VStack {
            Text("Selected date: \(fullFormatter.string(from: selectedDate))")
                .bold()
                .foregroundColor(.red)
            CalendarViewInterior(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    Button(action: { selectedDate = date }) {
                        Text("00")
                            .padding(8)
                            .foregroundColor(.clear)
                            .background(
                                calendar.isDate(date, inSameDayAs: selectedDate) ? Color.red
                                    : calendar.isDateInToday(date) ? .green
                                    : .blue
                            )
                            .cornerRadius(8)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(dayFormatter.string(from: date))
                                    .modifier(TP1AppTextViewModifier(viewElementStyles: .shared, typography: .en_body_body2_reg, fontColor: .body))
                                    .foregroundColor(.white)
                                    .transition(.fade(duration: 0.2))
                            )
                            .transition(.fade(duration: 0.2))
                    }
                    .transition(.fade(duration: 0.2))
                    .id(date)
                },
                trailing: { date in
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(.clear)
                        .transition(.fade(duration: 0.2))
                        .id(date)
                },
                header: { date in
                    Text(weekDayFormatter.string(from: date))
                        .modifier(TP1AppTextViewModifier(viewElementStyles: .shared, typography: .en_caption_caption_reg, fontColor: .body))
                        .id(weekDayLongFormatter.string(from: date))
                },
                title: { date in
                    HStack {
                        Text(monthFormatter.string(from: date))
                            .font(.headline)
                            .padding()
                        Spacer()
                        Button {
                            guard let newDate = calendar.date(
                                byAdding: .month,
                                value: -1,
                                to: selectedDate
                            ) else {
                                return
                            }

                            selectedDate = newDate

                        } label: {
                            Label(
                                title: { Text("Previous") },
                                icon: { Image(systemName: "chevron.left") }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                            .frame(maxHeight: .infinity)
                        }
                        Button {
                            guard let newDate = calendar.date(
                                byAdding: .month,
                                value: 1,
                                to: selectedDate
                            ) else {
                                return
                            }

                            selectedDate = newDate

                        } label: {
                            Label(
                                title: { Text("Next") },
                                icon: { Image(systemName: "chevron.right") }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .padding(.bottom, 6)
                }
            )
            .equatable()
        }
        .padding()
        .animation(.none, value: selectedDate)
    }
    
    
    
    
    // MARK: - Component

    public struct CalendarViewInterior<Day: View, Header: View, Title: View, Trailing: View>: View {
        // Injected dependencies
        private var calendar: Calendar
        @Binding private var date: Date
        private let content: (Date) -> Day
        private let trailing: (Date) -> Trailing
        private let header: (Date) -> Header
        private let title: (Date) -> Title

        // Constants
        private let daysInWeek = 7

        public init(
            calendar: Calendar,
            date: Binding<Date>,
            @ViewBuilder content: @escaping (Date) -> Day,
            @ViewBuilder trailing: @escaping (Date) -> Trailing,
            @ViewBuilder header: @escaping (Date) -> Header,
            @ViewBuilder title: @escaping (Date) -> Title
        ) {
            self.calendar = calendar
            self._date = date
            self.content = content
            self.trailing = trailing
            self.header = header
            self.title = title
        }

        public var body: some View {
            let month = date.startOfMonth(using: calendar)
            let days = makeDays()

            return VStack(spacing: 0) {
                LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                    Section(header: title(month)) {
                        ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                    }
                    .debugFrameSize()
                }
                LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                    Section(header: title(month)) {
                        ForEach(days, id: \.self) { date in
                            if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                                content(date)
                            } else {
                                trailing(date)
                            }
                        }
                    }
                    .debugFrameSize()
                }
            }
        }
    }

}


// MARK: - Conformances

extension VanCalendarView.CalendarViewInterior: Equatable {
    static func == (lhs: VanCalendarView.CalendarViewInterior<Day, Header, Title, Trailing>, rhs: VanCalendarView.CalendarViewInterior<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

extension VanCalendarView.CalendarViewInterior {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
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
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
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

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack {
                VanCalendarView(calendar: Calendar(identifier: .gregorian))
                Spacer()
            }
            VanCalendarView(calendar: Calendar(identifier: .islamicUmmAlQura))
            VanCalendarView(calendar: Calendar(identifier: .hebrew))
            VanCalendarView(calendar: Calendar(identifier: .indian))
        }
    }
}
