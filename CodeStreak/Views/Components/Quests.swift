
import SwiftUI

struct QuestsView: View {
    @Environment(QuestsViewModel.self) private var viewModel

    @State private var showingResult = false
    @State private var currentQuestResult: CommitResult?

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.dailyQuests) { quest in
                    QuestCardView(quest: quest, viewModel: viewModel)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
            .listStyle(.plain)
            .navigationTitle("Daily Quests")
            .onChange(of: viewModel.commitResult) { _, result in
                if let result = result {
                    self.currentQuestResult = result
                    showingResult = true
                }
            }
            .alert(isPresented: $showingResult) {
                Alert(
                    title: Text(currentQuestResult?.success ?? false ? "Success!" : "Mission Failed"),
                    message: Text(currentQuestResult?.message ?? "[ERROR] - Unknown"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.commitResult = nil
                        self.currentQuestResult = nil
                    }
                )
            }
        }
    }
}

struct QuestCardView: View {
    let quest: DailyQuest
    @Bindable var viewModel: QuestsViewModel
    
    @State private var localAnswer: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(quest.question)
                .font(.headline)
            HStack {
                Label("\(quest.rewardXP) XP", systemImage: "star.fill")
                    .foregroundColor(.green)
                Label("\(quest.rewardCredits) $", systemImage: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
            }
            .font(.subheadline)
            Divider()
            if quest.isCompleted {
                HStack {
                    Text("Completed for today")
                        .font(.body)
                        .foregroundColor(.green)
                    Spacer()
                }
            } else if quest.hasFailed {
                 HStack {
                     Text("Mission failed try again tomorrow")
                         .font(.body)
                         .foregroundColor(.red)
                     Spacer()
                 }
            } else {
                TextField("Your Answer", text: $localAnswer)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
                Button {
                    Task {
                        viewModel.userAnswer = localAnswer
                        await viewModel.submitAnswer(for: quest)
                    }
                } label: {
                    Text(viewModel.isLoading ? "Submitting..." : "Submit Answer")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(localAnswer.isEmpty || viewModel.isLoading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}
