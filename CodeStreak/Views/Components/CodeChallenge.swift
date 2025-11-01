
import SwiftUI

struct CodeChallengeView: View {
    let habit: Habit

    @Environment(HomeViewModel.self) var viewModel
    @Environment(\.dismiss) var dismiss
    @State private var userAnswer: String = ""
    @State private var showHint: Bool = false
    @State private var statusMessage: String? = nil
    
    var isAnswerValid: Bool {
        !userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ChallengeHeader(habit: habit)
                    if let challenge = viewModel.currentChallenge {
                        ProblemDescription(challenge: challenge)
                        UserAnswerArea(userAnswer: $userAnswer)
                        HintButton(challenge: challenge, showHint: $showHint)
                    } else {
                        ProgressView("Generating Challenge...")
                            .frame(maxWidth: .infinity)
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Code Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    SubmitButton(isAnswerValid: isAnswerValid) {
                        submitChallenge()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let message = statusMessage {
                    ChallengeStatusBanner(message: message)
                }
            }
            .onAppear {
                Task {
                    await viewModel.generateChallenge(for: habit)
                }
            }
            .onChange(of: viewModel.commitSuccess) { oldValue, newValue in
                if newValue == true {
                    dismiss()
                }
            }
        }
    }
    
    private func submitChallenge() {
        guard let challenge = viewModel.currentChallenge else { return }
        Task {
            let result = await viewModel.submitAnswer(
                userAnswer: userAnswer,
                habitID: habit.id
            )
            if result.success {
            } else {
                statusMessage = result.message
            }
        }
    }
}

struct ChallengeHeader: View {
    let habit: Habit
    var body: some View {
        VStack(alignment: .leading) {
            Text(habit.technology)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.blue)
                .cornerRadius(8)
            Text(habit.name)
                .font(.title)
                .fontWeight(.heavy)
        }
    }
}

struct ProblemDescription: View {
    let challenge: Challenge
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(challenge.title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(challenge.problemDescription)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.top, 10)
    }
}

struct UserAnswerArea: View {
    @Binding var userAnswer: String
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your Answer:")
                .font(.headline)
            TextEditor(text: $userAnswer)
                .frame(height: 100)
                .border(Color.gray)
                .cornerRadius(5)
                .padding(.top, 5)
        }
    }
}

struct HintButton: View {
    let challenge: Challenge
    @Binding var showHint: Bool
    var body: some View {
        VStack(alignment: .leading) {
            Button("Show Hint (Warning: No penalty for now)") {
                showHint.toggle()
            }
            .foregroundColor(.orange)
            if showHint, let hint = challenge.hint {
                Text("Hint: \(hint)")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.top, 5)
            }
        }
    }
}

struct SubmitButton: View {
    let isAnswerValid: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text("Submit Answer")
        }
        .disabled(!isAnswerValid)
    }
}

struct ChallengeStatusBanner: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.footnote)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.red.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 20)
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: message)
    }
}
