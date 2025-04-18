//
//  LifeInWeeksView.swift
//  weeks
//
//  Created by Sagar Varma on 4/12/25.
//

import SwiftUI
import UIKit

// Dedicated performance-optimized data store
final class WeeksDataStore {
    // Singleton instance for global access
    static let shared = WeeksDataStore()
    
    // Keys for UserDefaults
    private let ageKey = "weeks_cached_age"
    private let weeksLivedKey = "weeks_cached_weeksLived"
    private let weeksRemainingKey = "weeks_cached_weeksRemaining"
    private let percentageKey = "weeks_cached_percentage"
    private let lastUpdateKey = "weeks_cached_lastUpdate"
    
    // Constants
    let totalWeeks = 80 * 52
    let weeksPerRow = 52
    
    // Lightweight cached values
    private(set) var age: Int = 0
    private(set) var weeksLived: Int = 0
    private(set) var weeksRemaining: Int = 0
    private(set) var percentage: String = "0.0"
    
    // Internal formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // Initialize with values from UserDefaults
    private init() {
        loadFromCache()
    }
    
    // Load cached values from UserDefaults
    private func loadFromCache() {
        let defaults = UserDefaults.standard
        age = defaults.integer(forKey: ageKey)
        weeksLived = defaults.integer(forKey: weeksLivedKey)
        weeksRemaining = defaults.integer(forKey: weeksRemainingKey)
        percentage = defaults.string(forKey: percentageKey) ?? "0.0"
    }
    
    // Save values to UserDefaults
    private func saveToCache() {
        let defaults = UserDefaults.standard
        defaults.set(age, forKey: ageKey)
        defaults.set(weeksLived, forKey: weeksLivedKey)
        defaults.set(weeksRemaining, forKey: weeksRemainingKey)
        defaults.set(percentage, forKey: percentageKey)
        defaults.set(Date(), forKey: lastUpdateKey)
    }
    
    // Fast check if we need to update (based on weeks passed since last calculation)
    func needsUpdate(for birthdayString: String) -> Bool {
        let defaults = UserDefaults.standard
        
        // If no last update, we definitely need to update
        guard let lastUpdate = defaults.object(forKey: lastUpdateKey) as? Date else {
            return true
        }
        
        // If birthday hasn't been set, we need to update if values aren't 0
        if birthdayString.isEmpty {
            return age != 0 || weeksLived != 0 || weeksRemaining != totalWeeks || percentage != "0.0"
        }
        
        // Calculate weeks since last update
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastUpdate, to: Date())
        let daysPassed = components.day ?? 0
        let weeksPassed = daysPassed / 7
        
        // Update if at least a week has passed
        return weeksPassed > 0
    }
    
    // Calculate values - only called when needed
    func updateValues(for birthdayString: String) {
        // Reset to defaults if birthday is empty
        if birthdayString.isEmpty {
            age = 0
            weeksLived = 0
            weeksRemaining = totalWeeks
            percentage = "0.0"
            saveToCache()
            return
        }
        
        // Do calculation
        let birthdayDate = dateFormatter.date(from: birthdayString) ?? Date()
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate age - ensure we're using the correct date components
        let ageComponents = calendar.dateComponents([.year, .month, .day], from: birthdayDate, to: now)
        let years = ageComponents.year ?? 0
        
        // Check if birthday has occurred this year
        let birthdayThisYear = calendar.date(from: DateComponents(
            year: calendar.component(.year, from: now),
            month: calendar.component(.month, from: birthdayDate),
            day: calendar.component(.day, from: birthdayDate)
        ))
        
        // If birthday hasn't occurred yet this year, subtract 1 from age
        if let birthdayThisYear = birthdayThisYear, birthdayThisYear > now {
            age = years - 1
        } else {
            age = years
        }
        
        // Calculate weeks lived
        let daysComponents = calendar.dateComponents([.day], from: birthdayDate, to: now)
        let daysLived = daysComponents.day ?? 0
        weeksLived = daysLived / 7
        
        // Calculate remaining weeks and percentage
        weeksRemaining = max(totalWeeks - weeksLived, 0)
        let percentValue = Double(weeksLived) / Double(totalWeeks) * 100
        percentage = String(format: "%.1f", percentValue)
        
        // Save to cache
        saveToCache()
    }
}

// Pre-rendered image for ultra-fast display
struct WeeksGridImage: View {
    let weeksLived: Int
    let totalWeeks: Int
    let weeksPerRow: Int
    
    // Cache the rendered image
    @State private var renderedImage: UIImage?
    
    var body: some View {
        Group {
            if let image = renderedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Show placeholder while rendering
                Color.black
                    .onAppear(perform: renderImage)
            }
        }
    }
    
    private func renderImage() {
        // Create a background task to render
        DispatchQueue.global(qos: .userInitiated).async {
            let width: CGFloat = 390 // Standard width
            let dotSpacing: CGFloat = 1.5
            let dotSize: CGFloat = (width - (dotSpacing * CGFloat(weeksPerRow))) / CGFloat(weeksPerRow)
            
            let rows = (totalWeeks + weeksPerRow - 1) / weeksPerRow
            let height = CGFloat(rows) * (dotSize + dotSpacing)
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: format)
            let image = renderer.image { context in
                let ctx = context.cgContext
                
                // Draw background
                ctx.setFillColor(UIColor.black.cgColor)
                ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
                
                // Draw dots
                for week in 0..<totalWeeks {
                    let row = week / weeksPerRow
                    let col = week % weeksPerRow
                    
                    let x = CGFloat(col) * (dotSize + dotSpacing)
                    let y = CGFloat(row) * (dotSize + dotSpacing)
                    
                    // Set color based on week
                    if week < weeksLived {
                        ctx.setFillColor(UIColor.red.cgColor)
                    } else {
                        ctx.setFillColor(UIColor.red.withAlphaComponent(0.2).cgColor)
                    }
                    
                    // Draw circle
                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                    ctx.fillEllipse(in: rect)
                }
            }
            
            // Update the state on main thread
            DispatchQueue.main.async {
                self.renderedImage = image
            }
        }
    }
}

struct LifeInWeeksView: View {
    @AppStorage("userBirthday") private var birthdayString: String = ""
    @Binding var showBirthdayInput: Bool
    
    // Functions passed from App structure for notifications
    var requestNotificationPermission: () -> Void
    var scheduleWeeklyNotification: (String) -> Void
    var scheduleDailyReflectionNotification: () -> Void
    
    // Access data store
    private let dataStore = WeeksDataStore.shared
    
    // State to trigger refresh
    @State private var refreshTrigger = false
    
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
                    
                    // Use pre-rendered grid image
                    WeeksGridImage(
                        weeksLived: dataStore.weeksLived,
                        totalWeeks: dataStore.totalWeeks,
                        weeksPerRow: dataStore.weeksPerRow
                    )
                    .id(refreshTrigger) // Force refresh when data changes
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
            // Check if we need to update calculations
            if dataStore.needsUpdate(for: birthdayString) {
                dataStore.updateValues(for: birthdayString)
                refreshTrigger.toggle() // Trigger grid refresh
            }
            
            // Request notification permission after view appears
            requestNotificationPermission()
        }
        .onChange(of: birthdayString) { _, newValue in
            // Update calculations when birthday changes
            dataStore.updateValues(for: newValue)
            refreshTrigger.toggle() // Trigger grid refresh
            
            // Schedule notification if needed
            if !newValue.isEmpty {
                scheduleWeeklyNotification(newValue)
            }
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Your age: \(dataStore.age)")
                    Text("Weeks lived: \(dataStore.weeksLived.formatted())")
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Weeks remaining: \(dataStore.weeksRemaining.formatted())")
                    Text("Percentage of life: \(dataStore.percentage)%")
                }
            }
            .foregroundColor(.white)
            .font(.callout)
        }
    }
}

#Preview {
    NavigationStack {
        LifeInWeeksView(showBirthdayInput: .constant(false),
                        requestNotificationPermission: { print("Preview") },
                        scheduleWeeklyNotification: { _ in print("Preview") },
                        scheduleDailyReflectionNotification: { print("Preview") })
            .modelContainer(for: Reflection.self, inMemory: true)
    }
} 