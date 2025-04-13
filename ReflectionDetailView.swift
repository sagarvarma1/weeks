import SwiftUI
import SwiftData

struct ReflectionDetailView: View {
    let reflection: Reflection
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Black background
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Date and type header
                    HStack {
                        Text(reflection.date, style: .date)
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(reflection.type == .meaningful ? "Spent Well" : "Wasted")
                            .font(.headline)
                            .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                            .background(reflection.type == .meaningful ? Color.green : Color.red)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    
                    // Full explanation text
                    ScrollView {
                        Text(reflection.explanation)
                            .font(.body)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .accentColor(.red)
    }
}

#Preview {
    ReflectionDetailView(reflection: Reflection(date: Date(), type: .meaningful, explanation: "Test explanation"))
        .modelContainer(for: Reflection.self, inMemory: true)
} 