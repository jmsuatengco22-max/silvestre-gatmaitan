import Foundation

// MARK: - Walk Model

struct Walk: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var distanceMiles: Double // Stored in miles
    var durationMinutes: Int // Minutes
    var title: String
    var note: String
    var moodEmoji: String
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        distanceMiles: Double,
        durationMinutes: Int,
        title: String = "",
        note: String = "",
        moodEmoji: String = "🌿"
    ) {
        self.id = id
        self.date = date
        self.distanceMiles = distanceMiles
        self.durationMinutes = max(1, durationMinutes)
        self.title = title.isEmpty ? Walk.defaultTitle(for: date) : title
        self.note = note
        self.moodEmoji = moodEmoji
    }

    var paceMinutesPerMile: Double {
        guard distanceMiles > 0 else { return 0 }
        return Double(durationMinutes) / distanceMiles
    }
    
    var formattedPace: String {
        guard distanceMiles > 0 else { return "--" }
        let totalPaceSec = Int(paceMinutesPerMile * 60)
        let mins = totalPaceSec / 60
        let secs = totalPaceSec % 60
        return String(format: "%d'%02d\" /mi", mins, secs)
    }

    var formattedDuration: String {
        if durationMinutes < 60 {
            return "\(durationMinutes) min"
        } else {
            let hours = durationMinutes / 60
            let mins = durationMinutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours) hr"
        }
    }

    var formattedDistance: String {
        return String(format: "%.2f mi", distanceMiles)
    }

    static func defaultTitle(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return "Morning Stroll"
        case 12..<17:
            return "Afternoon Walk"
        case 17..<21:
            return "Evening Walk"
        default:
            return "Quiet Walk"
        }
    }
}
