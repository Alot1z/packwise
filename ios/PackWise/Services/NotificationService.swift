import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    @Published var authorized = false

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            authorized = granted
        } catch { authorized = false }
    }

    func refreshStatus() async {
        let s = await UNUserNotificationCenter.current().notificationSettings()
        authorized = s.authorizationStatus == .authorized || s.authorizationStatus == .provisional
    }

    func schedule(title: String, date: Date, id: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "PackWise reminder"
        content.sound = .default
        let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(req)
    }

    func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
