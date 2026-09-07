import SwiftUI
import Charts

// MARK: - History & Trends View (Charts + Full Archive)

struct HistoryView: View {
    @ObservedObject var store: WalkStore
    @Binding var showLogSheet: Bool

    @State private var timeRange: HistoryTimeRange = .weekly
    @State private var selectedWalk: Walk?
    @State private var searchText: String = ""

    enum HistoryTimeRange: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    
                    // MARK: - Lifetime Statistics Cards
                    lifetimeStatsRow

                    // MARK: - Trend Chart Section
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("WALKING TRENDS")
                                    .font(AppTheme.captionFont)
                                    .foregroundStyle(AppTheme.inkSecondary)
                                    .kerning(1.2)

                                Text(timeRange == .weekly ? "Last 7 Days" : "Last 30 Days")
                                    .font(AppTheme.titleFont)
                                    .foregroundStyle(AppTheme.ink)
                            }

                            Spacer()

                            // Picker for Weekly / Monthly
                            Picker("Time Range", selection: $timeRange) {
                                ForEach(HistoryTimeRange.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: 160)
                        }

                        if timeRange == .weekly {
                            weeklyChartView
                        } else {
                            monthlyChartView
                        }
                    }
                    .calmCard(padding: AppTheme.Spacing.lg)

                    // MARK: - All Past Walks List
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        HStack {
                            Text("All Logged Walks")
                                .font(AppTheme.titleFont)
                                .foregroundStyle(AppTheme.ink)

                            Spacer()

                            Text("\(filteredWalks.count) total")
                                .font(AppTheme.subheadlineFont)
                                .foregroundStyle(AppTheme.inkSecondary)
                        }

                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(AppTheme.inkSecondary)
                            TextField("Search walks by title or note...", text: $searchText)
                                .font(AppTheme.bodyFont)
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(AppTheme.inkTertiary)
                                }
                            }
                        }
                        .padding(AppTheme.Spacing.sm)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                                .stroke(AppTheme.cardBorder, lineWidth: 1)
                        )

                        if filteredWalks.isEmpty {
                            VStack(spacing: AppTheme.Spacing.sm) {
                                Text("No matching walks found")
                                    .font(AppTheme.headlineFont)
                                    .foregroundStyle(AppTheme.inkSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.Spacing.xl)
                            .calmCard()
                        } else {
                            ForEach(filteredWalks) { walk in
                                Button {
                                    selectedWalk = walk
                                } label: {
                                    walkHistoryRow(walk)
                                }
                                .buttonStyle(PrimaryPressableStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("History & Trends")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedWalk) { walk in
                WalkDetailView(store: store, walk: walk)
            }
        }
    }

    // MARK: - Lifetime Stats Row
    private var lifetimeStatsRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            statMetricBox(title: "TOTAL DISTANCE", value: String(format: "%.1f", store.totalAllTimeDistance), unit: "mi", icon: "figure.walk", color: AppTheme.primary)
            statMetricBox(title: "TOTAL TIME", value: formatTotalHours(store.totalAllTimeMinutes), unit: "", icon: "clock.fill", color: AppTheme.accent)
            statMetricBox(title: "TOTAL WALKS", value: "\(store.allTimeWalkCount)", unit: "", icon: "checkmark.seal.fill", color: AppTheme.primaryLight)
        }
    }

    private func statMetricBox(title: String, value: String, unit: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)

            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.inkSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.ink)
                if !unit.isEmpty {
                    Text(unit)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .calmCard(padding: AppTheme.Spacing.sm)
    }

    // MARK: - Weekly Chart (Last 7 Days)
    private var weeklyChartView: some View {
        let data = computeWeeklyData()
        return VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Chart(data) { item in
                BarMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Miles", item.miles)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.primaryLight, AppTheme.primary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(6)
            }
            .chartYScale(domain: 0...max(4.0, (data.map(\.miles).max() ?? 3.0) + 0.5))
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(AppTheme.primarySubtle)
                    AxisValueLabel {
                        if let d = value.as(Double.self) {
                            Text("\(d, specifier: "%.1f")")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.inkSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.ink)
                }
            }
            .frame(height: 180)

            HStack {
                Text("Daily average: \(data.map(\.miles).reduce(0, +) / 7.0, specifier: "%.2f") mi")
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)
                Spacer()
            }
        }
    }

    // MARK: - Monthly Chart (Last 30 Days)
    private var monthlyChartView: some View {
        let data = computeMonthlyData()
        return VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Chart(data) { item in
                AreaMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Miles", item.miles)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.primary.opacity(0.35), AppTheme.primary.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Miles", item.miles)
                )
                .foregroundStyle(AppTheme.primary)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Miles", item.miles)
                )
                .foregroundStyle(AppTheme.accent)
                .symbolSize(item.miles > 0 ? 30 : 0)
            }
            .chartYScale(domain: 0...max(4.0, (data.map(\.miles).max() ?? 3.0) + 0.5))
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(AppTheme.primarySubtle)
                    AxisValueLabel {
                        if let d = value.as(Double.self) {
                            Text("\(d, specifier: "%.1f")")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.inkSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 6)) { _ in
                    AxisValueLabel(format: .dateTime.month().day())
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                }
            }
            .frame(height: 180)

            HStack {
                Text("Total logged in 30 days: \(data.map(\.miles).reduce(0, +), specifier: "%.1f") mi")
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)
                Spacer()
            }
        }
    }

    private func walkHistoryRow(_ walk: Walk) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Text(walk.moodEmoji)
                .font(.system(size: 26))
                .frame(width: 42, height: 42)
                .background(AppTheme.primarySubtle)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(walk.title)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)

                Text(walk.date.formatted(date: .abbreviated, time: .shortened))
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)

                if !walk.note.isEmpty {
                    Text(walk.note)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                        .lineLimit(1)
                        .padding(.top, 1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(walk.formattedDistance)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.primary)

                Text(walk.formattedDuration)
                    .font(AppTheme.captionFont)
                    .foregroundStyle(AppTheme.inkSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.inkTertiary)
        }
        .calmCard(padding: AppTheme.Spacing.md)
    }

    private var filteredWalks: [Walk] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return store.sortedWalks
        }
        return store.sortedWalks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.note.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func formatTotalHours(_ mins: Int) -> String {
        let hrs = Double(mins) / 60.0
        return String(format: "%.1fh", hrs)
    }

    // MARK: - Chart Data Models
    struct DailyChartPoint: Identifiable {
        let id = UUID()
        let dayLabel: String
        let date: Date
        let miles: Double
    }

    private func computeWeeklyData() -> [DailyChartPoint] {
        let calendar = Calendar.current
        var points: [DailyChartPoint] = []
        let today = calendar.startOfDay(for: Date())

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        for offset in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                let dayWalks = store.walks.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let total = dayWalks.reduce(0) { $0 + $1.distanceMiles }
                let label = dayFormatter.string(from: date)
                points.append(DailyChartPoint(dayLabel: label, date: date, miles: total))
            }
        }
        return points
    }

    private func computeMonthlyData() -> [DailyChartPoint] {
        let calendar = Calendar.current
        var points: [DailyChartPoint] = []
        let today = calendar.startOfDay(for: Date())

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"

        for offset in (0..<30).reversed() {
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                let dayWalks = store.walks.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let total = dayWalks.reduce(0) { $0 + $1.distanceMiles }
                let label = dayFormatter.string(from: date)
                points.append(DailyChartPoint(dayLabel: label, date: date, miles: total))
            }
        }
        return points
    }
}
