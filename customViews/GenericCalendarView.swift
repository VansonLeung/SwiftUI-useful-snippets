import SwiftUI


struct GenericCalendarView<Day: View, Header: View, Title: View, Trailing: View>: View {
    @Environment(\.calendar) private var calendar
    private let dateInterval: DateInterval
    private let content: (Date) -> Day
    private let header: (Date) -> Header
    private let title: (Date) -> Title
    private let trailing: (Date) -> Trailing
    private let daysInWeek = 7

    init(
        dateInterval: DateInterval,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title,
        @ViewBuilder trailing: @escaping (Date) -> Trailing
    ) {
        self.dateInterval = dateInterval
        self.content = content
        self.header = header
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        let dates = makeDates()

        return ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                ForEach(dates, id: \.month) { (month, days) in
                    Section(header: title(month)) {
                        ForEach(makeHeaderDays(for: month), id: \.self, content: header)
                        ForEach(days, id: \.self) { date in
                            if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                                content(date)
                            } else {
                                trailing(date)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension GenericCalendarView {
    func makeDates() -> [(month: Date, days: [Date])] {
        calendar
            .generateDates(
                for: dateInterval,
                matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
            )
            .map { ($0, days(for: $0)) }
    }

    func makeHeaderDays(for month: Date) -> [Date] {
        guard let week = calendar.dateInterval(of: .weekOfMonth, for: month) else { return [] }

        return calendar
            .generateDates(for: week, matching: DateComponents(hour: 0, minute: 0, second: 0))
            .prefix(daysInWeek) // Ensure number of days matches grid
            .array
    }

    func days(for month: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        return calendar.generateDates(
            for: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
}

extension GenericCalendarView: Equatable {
    static func == (lhs: GenericCalendarView<Day, Header, Title, Trailing>, rhs: GenericCalendarView<Day, Header, Title, Trailing>) -> Bool {
        lhs.dateInterval == rhs.dateInterval
    }
}

// MARK: - Helpers

extension DateFormatter {
    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }

    static var day: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }

    static var weekDay: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter
    }
}

extension Calendar {
    /// Returns the dates which match a given set of components between the specified dates.
    /// - Parameters:
    ///   - dateInterval: The `DateInterval` between which to compute the search.
    ///   - components: The `DateComponents` to use as input to the search algorithm.
    /// - Returns: The dates between the date interval that match the specified date component.
    func generateDates(
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
}

extension ArraySlice {
    /// Returns the array of the slice
    var array: [Element] { Array(self) }
}
