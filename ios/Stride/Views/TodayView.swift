import SwiftUI

// MARK: - Today View (Goal-tracker Daily Dashboard)

struct TodayView: View {
    @ObservedObject var store: WalkStore
    @Binding var showLogSheet: Bool
    @State private var selectedWalk: Walk?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    
                    // MARK: - Welcome / Date Header
                    HStack(alignment: .lastTextBaseline) {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                            Text(Date().formatted(.dateTime.weekday(.wide).month().day()))
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.inkSecondary)
                                .textCase(.uppercase)
                                .kerning(1.2)

                            Text("Daily Stride")
                                .font(AppTheme.displayFont)
                                .foregroundStyle(AppTheme.ink)
                        }
                        
                        Spacer()

                        // Log Walk Quick Action Button
                        Button {
                            showLogSheet = true
                        } label: {
                            HStack(spacing: AppTheme.Spacing.xxs) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Log Walk")
                                    .font(AppTheme.headlineFont)
                            }
                            .foregroundStyle(AppTheme.surface)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.xs)
                            .background(AppTheme.primary)
                            .clipShape(Capsule())
                            .shadow(color: AppTheme.primary.opacity(0.25), radius: 6, y: 2)
                        }
                        .buttonStyle(PrimaryPressableStyle())
                    }
                    .padding(.top, AppTheme.Spacing.xs)

                    // MARK: - Weekly Goal Progress Hero Card
                    weeklyGoalHeroCard

                    // MARK: - Today Stats Summary Row
                    todaySummaryRow

                    // MARK: - Recent Walks Section
                    recentWalksSection
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(item: $selectedWalk) { walk in
                WalkDetailView(store: store, walk: walk)
            }
        }
    }

    // MARK: - Weekly Goal Hero Card
    private var weeklyGoalHeroCard: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text("THIS WEEK'S PROGRESS")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                        .kerning(1.2)

                    HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.xxs) {
                        Text(String(format: "%.1f", store.totalDistanceThisWeek))
                            .font(AppTheme.statHeroFont)
                            .foregroundStyle(AppTheme.primary)

                        Text("/ \(store.weeklyGoalMiles, specifier: "%.1f") mi")
                            .font(AppTheme.titleFont)
                            .foregroundStyle(AppTheme.inkSecondary)
                    }
                }

                Spacer()

                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(AppTheme.primarySubtle, lineWidth: 8)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: CGFloat(store.weeklyProgressRatio))
                        .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 60, height: 60)
                        .animation(.smooth(duration: 0.6), value: store.weeklyProgressRatio)

                    Text("\(Int(store.weeklyProgressRatio * 100))%")
                        .font(AppTheme.captionFont)
                        .fontWeight(.bold)
                        .foregroundStyle(AppTheme.ink)
                }
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.primarySubtle)
                        .frame(height: 10)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primary, AppTheme.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(10, geo.size.width * CGFloat(store.weeklyProgressRatio)), height: 10)
                        .animation(.smooth(duration: 0.6), value: store.weeklyProgressRatio)
                }
            }
            .frame(height: 10)

            HStack {
                Text("\(store.walksThisWeek.count) walks this week")
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)

                Spacer()

                if store.currentStreakDays > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(AppTheme.accent)
                        Text("\(store.currentStreakDays) day streak")
                            .font(AppTheme.subheadlineFont)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppTheme.ink)
                    }
                }
            }
        }
        .calmCard(padding: AppTheme.Spacing.lg)
    }

    // MARK: - Today Summary Row
    private var todaySummaryRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            
            // Distance Today
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundStyle(AppTheme.primary)
                    Text("Today's Distance")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(format: "%.2f", store.totalDistanceToday))
                        .font(AppTheme.numeralFont)
                        .foregroundStyle(AppTheme.ink)
                    Text("mi")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .calmCard()

            // Time Walked Today
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(AppTheme.accent)
                    Text("Time Today")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(store.totalMinutesToday)")
                        .font(AppTheme.numeralFont)
                        .foregroundStyle(AppTheme.ink)
                    Text("min")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .calmCard()
        }
    }

    // MARK: - Recent Walks
    private var recentWalksSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text("Recent Walks")
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.ink)

                Spacer()
            }

            if store.sortedWalks.isEmpty {
                VStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "figure.walk.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(AppTheme.primaryLight)

                    Text("No walks logged yet")
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.ink)

                    Text("Take a casual walk today and tap \"Log Walk\" to record it.")
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.xl)
                .calmCard()
            } else {
                ForEach(store.sortedWalks.prefix(5)) { walk in
                    walkRow(walk)
                }
            }
        }
    }

    private func walkRow(_ walk: Walk) -> some View {
        Button {
            selectedWalk = walk
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Text(walk.moodEmoji)
                    .font(.system(size: 28))
                    .frame(width: 44, height: 44)
                    .background(AppTheme.primarySubtle)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(walk.title)
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.ink)

                    Text(walk.date.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTheme.subheadlineFont)
                        .foregroundStyle(AppTheme.inkSecondary)
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
            .contentShape(Rectangle())
        }
        .buttonStyle(PrimaryPressableStyle())
        .calmCard(padding: AppTheme.Spacing.md)
    }
}
