import SwiftUI
import SwiftData

struct ReflectionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor<Reflection>(\Reflection.date, order: .reverse)]) private var reflections: [Reflection]
    
    @State private var showingNewReflection = false
    @State private var selectedReflection: Reflection?
    
    var body: some View {
        ZStack {
            // Black background to match app theme
            Color.black.edgesIgnoringSafeArea(.all)
            
            if reflections.isEmpty {
                ContentUnavailableView("No Reflections Yet", 
                                     systemImage: "pencil.and.list.clipboard", 
                                     description: Text("Your daily reflections will appear here."))
                .foregroundColor(.white)
            } else {
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(reflections) { reflection in
                            Button(action: {
                                selectedReflection = reflection
                            }) {
                                HStack {
                                    // Left side: Date only
                                    Text(reflection.date, style: .date)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    // Right side: Reflection type badge
                                    Text(reflection.type == .meaningful ? "Spent Well" : "Wasted")
                                        .font(.subheadline)
                                        .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                                        .background(reflection.type == .meaningful ? Color.green : Color.red)
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.black)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Past Reflections")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            // Add back button styling
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.red)
                }
                .opacity(0) // This is invisible but maintains space for the SwiftUI back button
            }
            
            // Add plus button on the right
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingNewReflection = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.red)
                }
            }
            
            // Edit button
            ToolbarItem(placement: .navigationBarTrailing) {
                if !reflections.isEmpty {
                    Button(action: {
                        // We'll implement custom edit mode since we're not using List
                        // For now, this is just a placeholder
                    }) {
                        Text("Edit")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .sheet(isPresented: $showingNewReflection) {
            ReflectionInputView()
        }
        .sheet(item: $selectedReflection) { reflection in
            ReflectionDetailView(reflection: reflection)
        }
        // Apply this to get red back button
        .accentColor(.red)
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