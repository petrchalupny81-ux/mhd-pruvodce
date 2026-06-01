import Foundation

extension DateFormatter {
    static let apiDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "cs_CZ")
        return f
    }()

    static let apiTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "H:mm"
        f.locale = Locale(identifier: "cs_CZ")
        return f
    }()

    static let displayTime: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "H:mm"
        f.locale = Locale(identifier: "cs_CZ")
        return f
    }()

    static let displayDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        f.locale = Locale(identifier: "cs_CZ")
        return f
    }()
}

extension Date {
    var mhdTimeString: String { DateFormatter.displayTime.string(from: self) }
    var mhdDateString: String { DateFormatter.displayDate.string(from: self) }

    var isToday: Bool { Calendar.current.isDateInToday(self) }

    func minutesUntil() -> Int {
        max(0, Int(timeIntervalSinceNow / 60))
    }
}
