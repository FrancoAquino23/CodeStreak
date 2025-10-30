
import SwiftUI

struct XPBarView: View {
    let currentXP: Int
    let xpForNextLevel: Int
    let currentLevel: Int
    private var progress: Double {
        guard xpForNextLevel > 0 else { return 0.0 }
        return Double(currentXP) / Double(xpForNextLevel)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Level \(currentLevel)")
                    .font(.headline)
                Spacer()
                Text("\(currentXP) / \(xpForNextLevel) XP")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 12)
                    Capsule()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 12)
                        .animation(.linear, value: progress)
                }
            }
            .frame(height: 12)
        }
    }
}
