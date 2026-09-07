import SwiftUI
import Combine

// MARK: - WalkStore Persistence and Analytics

final class WalkStore: ObservableObject {
    @Published var walks: [Walk] = [] {
        didSet {
            saveWalks()
        }
    }

    // Weekly distance goal in miles (default 10 miles)
    @Published var weeklyGoalMiles: Double = 10.0 {
        didSet {
            UserDefaults.standard.set(weeklyGoalMiles, forKey: "stride_weekly_goal")
        }
    }

    private let storageKey = "stride_logged_walks_v1"

    init() {
        if let goal = UserDefaults.standard.value(forKey: "stride_weekly_goal") as? Double {
            self.weeklyGoalMiles = goal
        }
        loadWalks()
    }

    // MARK: - CRUD
    func addWalk(_ walk: Walk) {
        walks.insert(walk, at: 0)
    }

    func updateWalk(_ walk: Walk) {
        if let index = walks.firstIndex(where: { $0.id == walk.id }) {
            walks[index] = walk
        }
    }

    func deleteWalk(id: UUID) {
        walks.removeAll { $0.id == id }
    }

    // MARK: - Aggregates & Metrics
    var sortedWalks: [Walk] {
        walks.sorted { $0.date > $1.date }
    }

    var walksThisWeek: [Walk] {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
            return []
        }
        return walks.filter { $0.date >= weekStart }
    }

    var totalDistanceThisWeek: Double {
        walksThisWeek.reduce(0) { $0 + $1.distanceMiles }
    }

    var totalDurationThisWeek: Int {
        walksThisWeek.reduce(0) { $0 + $1.durationMinutes }
    }

    var weeklyProgressRatio: Double {
        guard weeklyGoalMiles > 0 else { return 0 }
        return min(1.0, totalDistanceThisWeek / weeklyGoalMiles)
    }

    var walksToday: [Walk] {
        let calendar = Calendar.current
        return walks.filter { calendar.isDateInToday($0.date) }
    }

    var totalDistanceToday: Double {
        walksToday.reduce(0) { $0 + $1.distanceMiles }
    }

    var totalMinutesToday: Int {
        walksToday.reduce(0) { $0 + $1.durationMinutes }
    }

    var totalAllTimeDistance: Double {
        walks.reduce(0) { $0 + $1.distanceMiles }
    }

    var totalAllTimeMinutes: Int {
        walks.reduce(0) { $0 + $1.durationMinutes }
    }

    var allTimeWalkCount: Int {
        walks.count
    }

    // Active streak calculation (days with at least one walk)
    var currentStreakDays: Int {
        guard !walks.isEmpty else { return 0 }
        let calendar = Calendar.current
        var uniqueDays = Set<Date>()
        
        for walk in walks {
            let startOfDay = calendar.startOfDay(for: walk.date)
            uniqueDays.insert(startOfDay)
        }

        let sortedDays = uniqueDays.sorted(by: >)
        let today = calendar.startOfDay(for: Date())
        guard let mostRecent = sortedDays.first else { return 0 }

        let daysFromToday = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
        if daysFromToday > 1 {
            return 0 // Streak broken
        }

        var streak = 0
        var checkDate = mostRecent
        for day in sortedDays {
            if day == checkDate {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else if day < checkDate {
                break
            }
        }
        return streak
    }

    // MARK: - Persistence & Seed
    private func saveWalks() {
        do {
            let data = try JSONEncoder().encode(walks)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save walks: \(error)")
        }
    }

    private func loadWalks() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([Walk].self, from: data),
           !saved.isEmpty {
            self.walks = saved
        } else {
            // Seed gentle sample walks so the app feels alive immediately
            self.walks = WalkStore.sampleWalks
            saveWalks()
        }
    }

    // MARK: - Sample Data
    static var sampleWalks: [Walk] {
        let calendar = Calendar.current
        let now = Date()

        return [
            Walk(
                date: calendar.date(byAdding: .hour, value: -3, to: now) ?? now,
                distanceMiles: 1.85,
                durationMinutes: 32,
                title: "Morning Park Loop",
                note: "Crisp sunny morning, felt energized.",
                moodEmoji: "☀️"
            ),
            Walk(
                date: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                distanceMiles: 2.40,
                durationMinutes: 44,
                title: "Sunset Neighborhood Stroll",
                note: "Saw neighbors gardening and blooming lilacs.",
                moodEmoji: "🌅"
            ),
            Walk(
                date: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                distanceMiles: 1.50,
                durationMinutes: 28,
                title: "Quick Lunch Break Walk",
                note: "Great way to clear head during busy workday.",
                moodEmoji: "🌿"
            ),
            Walk(
                date: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
                distanceMiles: 3.10,
                durationMinutes: 58,
                title: "Weekend River Trail",
                note: "Long calm walk by the water.",
                moodEmoji: "🌊"
            ),
            Walk(
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                distanceMiles: 1.70,
                durationMinutes: 30,
                title: "Evening Wind Down",
                note: "Peaceful twilight walk.",
                moodEmoji: "🌙"
            ),
            Walk(
                date: calendar.date(byAdding: .day, value: -8, to: now) ?? now,
                distanceMiles: 2.20,
                durationMinutes: 39,
                title: "Botanical Garden Paths",
                note: "Lots of quiet shaded trails.",
                moodEmoji: "🌸"
            ),
            Walk(
                date: calendar.date(byAdding: .day, value: -11, to: now) ?? now,
                distanceMiles: 2.80,
                durationMinutes: 52,
                title: "Woodland Loop",
                note: "Chirping birds and gentle breeze.",
                moodEmoji: "🌲"
            )
        ]
    }
}
