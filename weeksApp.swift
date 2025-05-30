//
//  weeksApp.swift
//  weeks
//
//  Created by Sagar Varma on 4/12/25.
//

import SwiftUI
import UserNotifications
import SwiftData

@main
struct weeksApp: App {
    @AppStorage("userBirthday") private var birthdayString: String = ""
    @State private var showBirthdayInput: Bool = false
    @State private var navigateToReflectionInput: Bool = false
    
    // Constants
    private let totalLifeExpectancyInWeeks = 80 * 52
    private let weeklyNotificationIdentifier = "weeklyLifeUpdateNotification"
    private let dailyReflectionNotificationIdentifier = "dailyReflectionNotification"

    // SwiftData Model Container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Reflection.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Notification Delegate
    @StateObject private var notificationDelegate = NotificationDelegate()

    // Set delegate early
    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // Always show LifeInWeeks as main view, and use sheets for inputs
                Group {
                    if birthdayString.isEmpty {
                        // First-time launch placeholder that triggers the sheet
                        Color.black
                            .edgesIgnoringSafeArea(.all)
                            .onAppear {
                                // Show birthday input sheet immediately if no birthday set
                                showBirthdayInput = true
                            }
                    } else {
                        // Main app view once birthday is set
                        LifeInWeeksView(showBirthdayInput: $showBirthdayInput,
                                        requestNotificationPermission: requestNotificationPermission,
                                        scheduleWeeklyNotification: scheduleWeeklyNotification,
                                        scheduleDailyReflectionNotification: scheduleDailyReflectionNotification)
                            .navigationBarBackButtonHidden(true)
                    }
                }
                .onReceive(notificationDelegate.$shouldNavigateToReflectionInput) { shouldNavigate in
                    // Check if we need to navigate and the view isn't already presented
                    if shouldNavigate && !navigateToReflectionInput {
                        // Introduce a small delay to allow UI to settle
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navigateToReflectionInput = true
                            // Reset the trigger *after* setting the state
                            notificationDelegate.resetNavigationTrigger()
                        }
                    }
                }
                // Sheet for birthday input - presented modally
                .fullScreenCover(isPresented: $showBirthdayInput, content: {
                    BirthdayInputView(showBirthdayInput: $showBirthdayInput)
                })
                // Sheet for reflection input
                .sheet(isPresented: $navigateToReflectionInput) {
                    ReflectionInputView()
                }
            }
            .modelContainer(sharedModelContainer)
        }
    }
    
    // MARK: - Notification Logic
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
                // Schedule notifications if permission granted
                if !birthdayString.isEmpty {
                    scheduleWeeklyNotification(birthdayString: birthdayString)
                }
                scheduleDailyReflectionNotification()
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleWeeklyNotification(birthdayString: String) {
        guard !birthdayString.isEmpty else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [weeklyNotificationIdentifier]) // Remove old one first
        
        let weeksRemaining = calculateWeeksRemaining(birthdayString: birthdayString)
        let content = UNMutableNotificationContent()
        content.title = "Life in Weeks"
        content.body = "Another Week Over, A New One Just Begun: \(weeksRemaining.formatted()) weeks left."
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyNotificationIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Error scheduling weekly notification: \(error.localizedDescription)") }
            else { print("Weekly notification scheduled successfully.") }
        }
    }
    
    func scheduleDailyReflectionNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReflectionNotificationIdentifier]) // Remove old one first
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Reflection"
        content.body = "What did you get done today? Another Day Wasted or Something Meaningful"
        content.sound = UNNotificationSound.default
        // Add userInfo to identify this notification type if needed later
        content.userInfo = ["notificationType": "dailyReflection"]

        // Configure trigger for 8:00 PM (20:00) daily
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReflectionNotificationIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error { print("Error scheduling daily reflection notification: \(error.localizedDescription)") }
            else { print("Daily reflection notification scheduled successfully for 8 PM.") }
        }
    }
    
    // MARK: - Calculation Helpers (Adapted from LifeInWeeksView)
    
    private func parseBirthday(birthdayString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: birthdayString) ?? Date()
    }
    
    private func calculateWeeksLived(birthday: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: birthday, to: Date())
        guard let days = components.day else { return 0 }
        return days / 7
    }
    
    private func calculateWeeksRemaining(birthdayString: String) -> Int {
        let birthdayDate = parseBirthday(birthdayString: birthdayString)
        let lived = calculateWeeksLived(birthday: birthdayDate)
        return max(totalLifeExpectancyInWeeks - lived, 0)
    }
}
