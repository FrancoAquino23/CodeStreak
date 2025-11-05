
import SwiftUI

struct CommitStatusBanner: View {
    let result: CommitResult
    
    var body: some View {
        VStack(spacing: 4) {
            Text(result.success ? "COMMIT SUCCESSFUL!" : "ANSWER INCORRECT")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(result.message)
                .font(.caption)
                .foregroundColor(.white)
            
            if result.success {
                HStack {
                    Image(systemName: "bolt.fill")
                    Text("+\(result.xpGained) XP")
                    Image(systemName: "dollarsign.circle.fill")
                    Text("+\(result.creditsGained) Credits")
                }
                .font(.caption)
                .foregroundColor(.white)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(result.success ? Color.green.opacity(0.95) : Color.red.opacity(0.95))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct PrimaryButton: View {
    let title: String
    let iconName: String
    let action: () -> Void
    var isEnabled: Bool = true
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Image(systemName: iconName)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(isEnabled ? 1.0 : 0.95)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private var backgroundColor: Color {
        isEnabled ? Color.blue : Color.gray
    }
}
