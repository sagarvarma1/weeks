//
//  LifeInWeeksView.swift
//  weeks
//
//  Created by Sagar Varma on 4/12/25.
//

import SwiftUI

struct LifeInWeeksView: View {
    @AppStorage("userBirthday") private var birthdayString: String = ""
    @Binding var showBirthdayInput: Bool
    
    // Functions passed from App structure for notifications
    var requestNotificationPermission: () -> Void
    var scheduleWeeklyNotification: (String) -> Void
    var scheduleDailyReflectionNotification: () -> Void
    
    // Assuming average life expectancy of 80 years
    private let totalLifeExpectancyInWeeks = 80 * 52
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Life in Weeks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    statsSection
                    
                    Button(action: {
                        showBirthdayInput = true
                    }) {
                        Text("Update Birthday")
                            .foregroundColor(.red)
                            .font(.headline)
                    }
                    .padding(.top, 2)
                    
                    Text("Each dot represents one week of your life")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .padding(.top, 4)
                    
                    weeksGrid
                        .padding(.top, 2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ReflectionListView()
                } label: {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            // Request permission and schedule initial notifications when the view appears
            requestNotificationPermission()
        }
        .onChange(of: birthdayString) { oldBirthdayString, newBirthdayString in
            // Reschedule weekly notification if birthday changes
            if !newBirthdayString.isEmpty {
                scheduleWeeklyNotification(newBirthdayString)
                // No need to reschedule daily here, it's not dependent on birthday
            }
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Your age: \(age)")
                    Text("Weeks lived: \(weeksLived.formatted())")
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Weeks remaining: \(weeksRemaining.formatted())")
                    Text("Percentage of life: \(percentageOfLife)%")
                }
            }
            .foregroundColor(.white)
            .font(.callout)
        }
    }
    
    private var weeksGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(5), spacing: 0.5), count: 52), spacing: 1.5) {
            ForEach(0..<totalLifeExpectancyInWeeks, id: \.self) { index in
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundColor(index < weeksLived ? .red : Color.red.opacity(0.2))
            }
        }
        .padding(.horizontal, 2)
    }
    
    // MARK: - Computed Properties
    
    private var birthday: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: birthdayString) ?? Date()
    }
    
    private var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year ?? 0
    }
    
    private var weeksLived: Int {
        // For the example in the image (age 49, weeks lived 2,607)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: birthday, to: Date())
        guard let days = components.day else { return 0 }
        return days / 7
    }
    
    private var weeksRemaining: Int {
        // For the example in the image (weeks lived 2,607, weeks remaining 513)
        return max(totalLifeExpectancyInWeeks - weeksLived, 0)
    }
    
    private var percentageOfLife: String {
        // For the example in the image (83.6%)
        let percentage = Double(weeksLived) / Double(totalLifeExpectancyInWeeks) * 100
        return String(format: "%.1f", percentage)
    }
}

#Preview {
    // Need NavigationStack for toolbar preview
    NavigationStack {
        LifeInWeeksView(showBirthdayInput: .constant(false),
                        requestNotificationPermission: { print("Preview: Requesting notification permission") },
                        scheduleWeeklyNotification: { birthday in print("Preview: Scheduling weekly notification for birthday: \(birthday)") },
                        scheduleDailyReflectionNotification: { print("Preview: Scheduling daily notification") })
            .modelContainer(for: Reflection.self, inMemory: true) // Also needed for ReflectionListView link
    }
} 