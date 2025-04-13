import SwiftUI
import SwiftData

struct ReflectionInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedType: ReflectionType = .meaningful
    @State private var explanation: String = ""
    
    var body: some View {
        NavigationView { // Use NavigationView for title and buttons
            VStack(spacing: 20) {
                Text("How was your day?")
                    .font(.largeTitle)
                    .padding(.top)
                
                Picker("Day Type", selection: $selectedType) {
                    ForEach(ReflectionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                TextEditor(text: $explanation)
                    .frame(height: 150)
                    .border(Color.gray.opacity(0.5), width: 1)
                    .cornerRadius(5)
                    .padding(.horizontal)
                
                Button("Save Reflection") {
                    saveReflection()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
                
                Spacer()
            }
            .navigationTitle("Daily Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveReflection() {
        let newReflection = Reflection(type: selectedType, explanation: explanation)
        modelContext.insert(newReflection)
        // Saving happens automatically with SwiftData usually,
        // but you can explicitly save if needed:
        // try? modelContext.save()
    }
}

#Preview {
    ReflectionInputView()
        // Need to provide a model container for preview
        .modelContainer(for: Reflection.self, inMemory: true)
} 