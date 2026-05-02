import SwiftUI
import PhotosUI

struct SaveBPMView: View {
    let bpm: Int
    var onSave: (BPMEntry) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var note: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Text("\(bpm) BPM")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.green)

                TextField("Add note (track, vibe, crowd...)", text: $note)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.2))
                            .frame(height: 180)

                        if let imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(16)
                        } else {
                            Text("Add Photo")
                                .foregroundColor(.white)
                        }
                    }
                }

                Spacer()

                Button("Save BPM") {
                    let entry = BPMEntry(
                        bpm: bpm,
                        note: note,
                        date: Date(),
                        imageData: imageData
                    )
                    onSave(entry)
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(12)
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Save BPM")
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
}