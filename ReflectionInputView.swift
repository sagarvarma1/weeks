import SwiftUI
import SwiftData

struct ReflectionInputView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedType: ReflectionType = .meaningful
    @State private var explanation: String = ""
    
    var body: some View {
        NavigationView { // Use NavigationView for title and buttons
            ZStack {
                // Black background to match app theme
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    Text("Did you get anything done today?")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    // Custom segmented control with Yes/No labels
                    HStack(spacing: 8) {
                        Button(action: { selectedType = .meaningful }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedType == .meaningful ? Color.green : Color.green.opacity(0.3))
                                    .frame(height: 40)
                                
                                Text("Yes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fontWeight(selectedType == .meaningful ? .bold : .regular)
                            }
                        }
                        
                        Button(action: { selectedType = .wasted }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedType == .wasted ? Color.red : Color.red.opacity(0.3))
                                    .frame(height: 40)
                                
                                Text("No")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .fontWeight(selectedType == .wasted ? .bold : .regular)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Beige text editor that fills most of the screen
                    TextEditor(text: $explanation)
                        .background(Color(red: 0.95, green: 0.9, blue: 0.8)) // Beige color
                        .foregroundColor(.black) // Ensure text is black for visibility on beige
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom, 80) // Add padding to account for button
                        .colorScheme(.light) // Force light mode for this component to avoid dark mode issues
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                
                // Place button at bottom
                VStack {
                    Spacer()
                    Button("Save Reflection") {
                        saveReflection()
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Daily Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReflection()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .accentColor(.red) // Makes the navigation bar elements red
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