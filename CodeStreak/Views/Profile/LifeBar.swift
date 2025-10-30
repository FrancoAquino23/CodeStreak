
import SwiftUI

struct LifeStatusBarView: View {
    let livesRemaining: Int
    private let maxLives = 3

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maxLives, id: \.self) { index in
                Image(systemName: index < livesRemaining ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.title3)
            }
            Text("\(livesRemaining) Lives")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.red)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.red, lineWidth: 2)
        )
    }
}
