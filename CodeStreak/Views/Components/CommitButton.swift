
import SwiftUI

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
