
import SwiftUI

struct HabitCardView: View {
    let habit: Habit
    let openChallengeAction: (Habit) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(habit.name)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                DifficultyBadge(difficulty: habit.difficulty)
            }
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Current Streak: \(habit.currentStreak) days")
                    .font(.headline)
            }
            Text("Last Commit: \(formattedDate(habit.lastCommitDate))")
                .font(.caption)
                .foregroundColor(.secondary)
            Button(action: {
                openChallengeAction(habit)
            }) {
                HStack {
                    Text("Commit Today")
                    Image(systemName: isCommittedToday ? "checkmark.circle.fill" : "arrow.up.circle.fill")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isCommittedToday ? Color.gray.opacity(0.5) : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isCommittedToday)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private var isCommittedToday: Bool {
        guard let lastDate = habit.lastCommitDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DifficultyBadge: View {
    let difficulty: Int
    var difficultyName: String {
        return Difficulty(rawValue: difficulty)?.description.capitalized ?? "Unknown"
    }
    var backgroundColor: Color {
        switch Difficulty(rawValue: difficulty) {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert, .master: return .red
        default: return .gray
        }
    }
    var body: some View {
        Text(difficultyName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
