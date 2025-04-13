import SwiftUI
import SwiftData

struct ReflectionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor<Reflection>(\Reflection.date, order: .reverse)]) private var reflections: [Reflection]
    
    var body: some View {
        List {
            if reflections.isEmpty {
                ContentUnavailableView("No Reflections Yet", systemImage: "pencil.and.list.clipboard", description: Text("Your daily reflections will appear here."))
            } else {
                ForEach(reflections) { reflection in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(reflection.date, style: .date)
                                .font(.headline)
                            Spacer()
                            Text(reflection.type.rawValue)
                                .font(.subheadline)
                                .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                                .background(reflection.type == .meaningful ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                .cornerRadius(4)
                        }
                        if !reflection.explanation.isEmpty {
                            Text(reflection.explanation)
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.top, 2)
                        }
                    }
                }
                .onDelete(perform: deleteReflections)
            }
        }
        .navigationTitle("Past Reflections")
        .toolbar {
            if !reflections.isEmpty {
                EditButton()
            }
        }
    }
    
    private func deleteReflections(offsets: IndexSet) {
        withAnimation {
            offsets.map { reflections[$0] }.forEach(modelContext.delete)
        }
    }
}

#Preview {
    // Wrap in NavigationStack for preview title
    NavigationStack {
        ReflectionListView()
            .modelContainer(for: Reflection.self, inMemory: true)
            // Add sample data for preview
            .onAppear {
                let container = try! ModelContainer(for: Reflection.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
                let context = container.mainContext
                context.insert(Reflection(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, type: .meaningful, explanation: "Finished the project report."))
                context.insert(Reflection(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, type: .wasted, explanation: "Spent too much time scrolling."))
                context.insert(Reflection(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, type: .meaningful, explanation: "Had a great dinner with family."))
            }
    }
} 