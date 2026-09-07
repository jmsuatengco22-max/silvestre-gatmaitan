import SwiftUI

// MARK: - Log Walk View (Manual Logging Sheet)

struct LogWalkView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: WalkStore

    @State private var distanceText: String = ""
    @State private var durationMinutes: Int = 30
    @State private var walkDate: Date = Date()
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var selectedEmoji: String = "🌿"
    @State private var showSavedConfirmation = false

    private let moodEmojis = ["🌿", "☀️", "🌅", "🌲", "🌊", "🌙", "🌸", "☕️"]
    private let presetDistances: [Double] = [1.0, 1.5, 2.0, 3.0, 4.0]
    private let presetDurations: [Int] = [15, 20, 30, 45, 60]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    
                    // MARK: - Distance Section
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text("DISTANCE")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.inkSecondary)
                            .kerning(1.2)

                        HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.xs) {
                            TextField("0.00", text: $distanceText)
                                .font(AppTheme.statHeroFont)
                                .foregroundStyle(AppTheme.primary)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: 180)

                            Text("miles")
                                .font(AppTheme.titleFont)
                                .foregroundStyle(AppTheme.inkSecondary)

                            Spacer()
                        }
                        .padding(.vertical, AppTheme.Spacing.xs)

                        // Quick presets
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.xs) {
                                ForEach(presetDistances, id: \.self) { preset in
                                    Button {
                                        distanceText = String(format: "%.1f", preset)
                                    } label: {
                                        Text("\(preset, specifier: "%.1f") mi")
                                            .font(AppTheme.calloutFont)
                                            .foregroundStyle(isSelectedDistance(preset) ? AppTheme.surface : AppTheme.ink)
                                            .padding(.horizontal, AppTheme.Spacing.md)
                                            .padding(.vertical, AppTheme.Spacing.xs)
                                            .background(
                                                isSelectedDistance(preset) ? AppTheme.primary : AppTheme.primarySubtle.opacity(0.6)
                                            )
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(PrimaryPressableStyle())
                                }
                            }
                        }
                    }
                    .calmCard()

                    // MARK: - Duration Section
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        HStack {
                            Text("DURATION")
                                .font(AppTheme.captionFont)
                                .foregroundStyle(AppTheme.inkSecondary)
                                .kerning(1.2)
                            
                            Spacer()
                            
                            Text(formatDuration(durationMinutes))
                                .font(AppTheme.headlineFont)
                                .foregroundStyle(AppTheme.primary)
                        }

                        Stepper(value: $durationMinutes, in: 1...300, step: 5) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                Image(systemName: "clock")
                                    .foregroundStyle(AppTheme.primary)
                                Text("\(durationMinutes) minutes")
                                    .font(AppTheme.bodyFont)
                                    .foregroundStyle(AppTheme.ink)
                            }
                        }

                        // Quick duration presets
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.xs) {
                                ForEach(presetDurations, id: \.self) { preset in
                                    Button {
                                        durationMinutes = preset
                                    } label: {
                                        Text("\(preset) min")
                                            .font(AppTheme.calloutFont)
                                            .foregroundStyle(durationMinutes == preset ? AppTheme.surface : AppTheme.ink)
                                            .padding(.horizontal, AppTheme.Spacing.md)
                                            .padding(.vertical, AppTheme.Spacing.xs)
                                            .background(
                                                durationMinutes == preset ? AppTheme.primary : AppTheme.primarySubtle.opacity(0.6)
                                            )
                                            .clipShape(Capsule())
                                    }
                                    .buttonStyle(PrimaryPressableStyle())
                                }
                            }
                        }
                    }
                    .calmCard()

                    // MARK: - Date & Details
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                        Text("DETAILS")
                            .font(AppTheme.captionFont)
                            .foregroundStyle(AppTheme.inkSecondary)
                            .kerning(1.2)

                        DatePicker(selection: $walkDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute]) {
                            Label("Date & Time", systemImage: "calendar")
                                .font(AppTheme.bodyFont)
                                .foregroundStyle(AppTheme.ink)
                        }

                        Divider().overlay(AppTheme.primarySubtle)

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Title (optional)")
                                .font(AppTheme.subheadlineFont)
                                .foregroundStyle(AppTheme.inkSecondary)
                            
                            TextField("e.g. Sunny neighborhood loop", text: $title)
                                .font(AppTheme.bodyFont)
                                .padding(AppTheme.Spacing.sm)
                                .background(AppTheme.background)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
                        }

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Notes or reflection")
                                .font(AppTheme.subheadlineFont)
                                .foregroundStyle(AppTheme.inkSecondary)

                            TextField("How did the walk feel? What did you notice?", text: $note, axis: .vertical)
                                .lineLimit(3...5)
                                .font(AppTheme.bodyFont)
                                .padding(AppTheme.Spacing.sm)
                                .background(AppTheme.background)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
                        }

                        // Mood / Vibe Tag
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Walk vibe")
                                .font(AppTheme.subheadlineFont)
                                .foregroundStyle(AppTheme.inkSecondary)

                            HStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(moodEmojis, id: \.self) { emoji in
                                    Button {
                                        selectedEmoji = emoji
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 24))
                                            .frame(width: 42, height: 42)
                                            .background(
                                                selectedEmoji == emoji ? AppTheme.accentLight : AppTheme.background
                                            )
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedEmoji == emoji ? AppTheme.accent : Color.clear, lineWidth: 2)
                                            )
                                    }
                                    .buttonStyle(PrimaryPressableStyle())
                                }
                            }
                        }
                    }
                    .calmCard()

                    // Save CTA
                    Button(action: saveWalk) {
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.headline)
                            Text("Save Walk")
                                .font(AppTheme.headlineFont)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .foregroundStyle(AppTheme.surface)
                        .background(isFormValid ? AppTheme.primary : AppTheme.inkTertiary)
                        .clipShape(Capsule())
                        .shadow(color: isFormValid ? AppTheme.primary.opacity(0.3) : Color.clear, radius: 10, y: 4)
                    }
                    .disabled(!isFormValid)
                    .buttonStyle(PrimaryPressableStyle())
                    .padding(.top, AppTheme.Spacing.sm)
                    .padding(.bottom, AppTheme.Spacing.xl)
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, AppTheme.Spacing.md)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Log Walk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.inkSecondary)
                }
            }
        }
    }

    private var parsedDistance: Double {
        Double(distanceText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var isFormValid: Bool {
        parsedDistance > 0 && durationMinutes > 0
    }

    private func isSelectedDistance(_ preset: Double) -> Bool {
        guard let current = Double(distanceText.replacingOccurrences(of: ",", with: ".")) else { return false }
        return abs(current - preset) < 0.05
    }

    private func formatDuration(_ mins: Int) -> String {
        if mins < 60 {
            return "\(mins) mins"
        }
        let hrs = mins / 60
        let rem = mins % 60
        return rem > 0 ? "\(hrs)h \(rem)m" : "\(hrs) hr"
    }

    private func saveWalk() {
        guard isFormValid else { return }
        let newWalk = Walk(
            date: walkDate,
            distanceMiles: parsedDistance,
            durationMinutes: durationMinutes,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            moodEmoji: selectedEmoji
        )
        store.addWalk(newWalk)
        dismiss()
    }
}
