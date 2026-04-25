import SwiftUI
import SwiftData

struct BPMHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var currentBPM: Double = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                Text("DJ BPM Counter")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("\(Int(currentBPM)) BPM")
                    .font(.system(size: 60, weight: .bold))

                Button("Start Listening") {
                    currentBPM = 120
                }
                .buttonStyle(.borderedProminent)

                Button("Save BPM") {
                    let newItem = Item(songName: "Test Song", bpm: currentBPM)
                    modelContext.insert(newItem)
                }
                .buttonStyle(.bordered)

                List {
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text(item.songName)
                                .font(.headline)

                            Text("\(Int(item.bpm)) BPM")
                                .font(.subheadline)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }

                Button("Log Out") {
                    isLoggedIn = false
                }
                .foregroundStyle(.red)
            }
            .padding()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

#Preview {
    BPMHomeView()
        .modelContainer(for: Item.self, inMemory: true)
}
