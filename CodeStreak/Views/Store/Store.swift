
import SwiftUI

struct StoreView: View {
    @State var storeViewModel: StoreViewModel
    
    init(storeViewModel: StoreViewModel) {
        self._storeViewModel = State(initialValue: storeViewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                HStack {
                    Text("Your credits:")
                        .font(.title2)
                    Text("\(storeViewModel.currentUser?.credits ?? 100)")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.yellow)
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                }
                .padding(.vertical)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Available items")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    ForEach(storeViewModel.availableItems) { item in
                        StoreItemRow(item: item, viewModel: storeViewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
        .navigationTitle("CodeStreak Store")
    }
}

struct StoreItemRow: View {
    let item: StoreItem
    
    @ObservedObject var viewModel: StoreViewModel
    
    private var canAfford: Bool {
        let currentCredits = viewModel.currentUser?.credits ?? 100
        return currentCredits >= item.cost
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.iconName)
                    .foregroundColor(.orange)
                    .font(.title)
                    .frame(width: 40)
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Button(action: {
                    Task {
                        _ = await viewModel.purchaseItem(item: item)
                    }
                }) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("\(item.cost)")
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(canAfford ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(!canAfford)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}
