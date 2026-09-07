import SwiftUI

// MARK: - Walk Detail View (View, Edit & Delete)

struct WalkDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: WalkStore
    @State var walk: Walk

    @State private var isEditing = false
    @State private var editDistanceText: String = ""
    @State private var editDuration: Int = 30
    @State private var editDate: Date = Date()
    @State private var editTitle: String = ""
    @State private var editNote: String = ""
    @State private var editEmoji: String = "🌿"
    @State private var showDeleteConfirmation = false

    private let moodEmojis = ["🌿", "☀️", "🌅", "🌲", "🌊", "🌙", "🌸", "☕️"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    
                    if isEditing {
                        editSection
                    } else {
                        viewSection
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.screenMargin)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Walk" : "Walk Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if isEditing {
                        Button("Cancel") {
                            isEditing = false
                        }
                        .foregroundStyle(AppTheme.inkSecondary)
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                        .foregroundStyle(AppTheme.primary)
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if isEditing {
                        Button("Save") {
                            saveEdits()
                        }
                        .font(AppTheme.headlineFont)
                        .foregroundStyle(AppTheme.primary)
                    } else {
                        Button("Edit") {
                            startEditing()
                        }
                        .foregroundStyle(AppTheme.primary)
                    }
                }
            }
            .confirmationDialog("Delete Walk?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete Walk", role: .destructive) {
                    store.deleteWalk(id: walk.id)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This walk record will be removed from your history.")
            }
        }
    }

    // MARK: - View Mode
    private var viewSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            
            // Hero Card
            VStack(spacing: AppTheme.Spacing.md) {
                HStack {
                    Text(walk.moodEmoji)
                        .font(.system(size: 44))
                        .padding(AppTheme.Spacing.sm)
                        .background(AppTheme.primarySubtle)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                        Text(walk.title)
                            .font(AppTheme.titleFont)
                            .foregroundStyle(AppTheme.ink)

                        Text(walk.date.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTheme.subheadlineFont)
                            .foregroundStyle(AppTheme.inkSecondary)
                    }
                    Spacer()
                }

                Divider().overlay(AppTheme.primarySubtle)

                // 3 Metrics Row
                HStack(spacing: AppTheme.Spacing.md) {
                    statPillar(title: "DISTANCE", value: String(format: "%.2f", walk.distanceMiles), unit: "mi")
                    statPillar(title: "DURATION", value: "\(walk.durationMinutes)", unit: "min")
                    statPillar(title: "AVG PACE", value: walk.formattedPace, unit: "")
                }
            }
            .calmCard(padding: AppTheme.Spacing.lg)

            // Reflection / Notes
            if !walk.note.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                    Text("WALK NOTES")
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                        .kerning(1.2)

                    Text(walk.note)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.ink)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .calmCard()
            }

            // Delete Action
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "trash")
                    Text("Delete Walk")
                }
                .font(AppTheme.calloutFont)
                .foregroundStyle(Color.red.opacity(0.85))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
            }
            .buttonStyle(PrimaryPressableStyle())
        }
    }

    private func statPillar(title: String, value: String, unit: String) -> some View {
        VStack(spacing: AppTheme.Spacing.xxs) {
            Text(title)
                .font(AppTheme.captionFont)
                .foregroundStyle(AppTheme.inkSecondary)
                .kerning(1.0)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.primary)

                if !unit.isEmpty {
                    Text(unit)
                        .font(AppTheme.captionFont)
                        .foregroundStyle(AppTheme.inkSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xs)
        .background(AppTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
    }

    // MARK: - Edit Mode
    private var editSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Distance (miles)")
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)
                TextField("Miles", text: $editDistanceText)
                    .font(AppTheme.titleFont)
                    .keyboardType(.decimalPad)
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
            }
            .calmCard()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Duration (minutes)")
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)
                Stepper("\(editDuration) minutes", value: $editDuration, in: 1...300, step: 5)
                    .font(AppTheme.bodyFont)
            }
            .calmCard()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                DatePicker("Date & Time", selection: $editDate, in: ...Date())
                    .font(AppTheme.bodyFont)
            }
            .calmCard()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Title")
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)
                TextField("Title", text: $editTitle)
                    .font(AppTheme.bodyFont)
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
            }
            .calmCard()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Notes")
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)
                TextField("Notes", text: $editNote, axis: .vertical)
                    .lineLimit(3...5)
                    .font(AppTheme.bodyFont)
                    .padding(AppTheme.Spacing.sm)
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous))
            }
            .calmCard()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Walk Vibe")
                    .font(AppTheme.subheadlineFont)
                    .foregroundStyle(AppTheme.inkSecondary)
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(moodEmojis, id: \.self) { emoji in
                        Button {
                            editEmoji = emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 24))
                                .frame(width: 40, height: 40)
                                .background(editEmoji == emoji ? AppTheme.accentLight : AppTheme.background)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(editEmoji == emoji ? AppTheme.accent : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
            }
            .calmCard()
        }
    }

    private func startEditing() {
        editDistanceText = String(format: "%.2f", walk.distanceMiles)
        editDuration = walk.durationMinutes
        editDate = walk.date
        editTitle = walk.title
        editNote = walk.note
        editEmoji = walk.moodEmoji
        isEditing = true
    }

    private func saveEdits() {
        let dist = Double(editDistanceText.replacingOccurrences(of: ",", with: ".")) ?? walk.distanceMiles
        let updated = Walk(
            id: walk.id,
            date: editDate,
            distanceMiles: dist,
            durationMinutes: editDuration,
            title: editTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            note: editNote.trimmingCharacters(in: .whitespacesAndNewlines),
            moodEmoji: editEmoji
        )
        self.walk = updated
        store.updateWalk(updated)
        isEditing = false
    }
}
