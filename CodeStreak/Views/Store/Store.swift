
import SwiftUI

struct StoreView: View {
    @Environment(HomeViewModel.self) var viewModel
    @State private var livesToBuy: Int = 1
    
    private let costPerLife = 50
    var body: some View {
        VStack {
            Text("CodeStreak Store")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            HStack {
                Text("Your Credits:")
                    .font(.title2)
                Text("\(viewModel.currentUserStats?.credits ?? 0)")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.yellow)
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
            }
            .padding(.bottom, 40)
            VStack(spacing: 20) {
                Text("Buy Life Insurance")
                    .font(.headline)
                Text("Restore your streak protection by purchasing extra lives")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Stepper("Buy \(livesToBuy) Life\(livesToBuy > 1 ? "s" : "")", value: $livesToBuy, in: 1...5)
                    .padding(.horizontal)
                Text("Total Cost: \(livesToBuy * costPerLife) Credits")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                Button(action: {
                    buyLives()
                }) {
                    Text("Purchase (\(livesToBuy * costPerLife) C)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canAfford ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!canAfford)
                
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(20)
            .shadow(radius: 5)
            Spacer()
        }
        .padding()
        .navigationTitle("Store")
    }
    
    private var canAfford: Bool {
        let currentCredits = viewModel.currentUserStats?.credits ?? 0
        return currentCredits >= (livesToBuy * costPerLife)
    }
    
    private func buyLives() {
        viewModel.purchaseLives(amount: livesToBuy)
        livesToBuy = 1
    }
}
