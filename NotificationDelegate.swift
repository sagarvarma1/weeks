import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    
    @Published var shouldNavigateToReflectionInput: Bool = false

    // Handle notification when app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification, 
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Show alert, badge, and play sound
        completionHandler([.banner, .badge, .sound])
    }

    // Handle user tapping on the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                didReceive response: UNNotificationResponse, 
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Check if it's the daily reflection notification
        if let notificationType = userInfo["notificationType"] as? String,
           notificationType == "dailyReflection" {
            // Set the state variable to trigger navigation
            DispatchQueue.main.async {
                self.shouldNavigateToReflectionInput = true
            }
        }
        
        completionHandler()
    }
    
    // Function to reset the navigation trigger after handling
    func resetNavigationTrigger() {
        shouldNavigateToReflectionInput = false
    }
} 