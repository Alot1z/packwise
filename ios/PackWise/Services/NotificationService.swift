import Foundation
import UserNotifications

@MainActor
final class NotificationService: ObservableObject {
    @Published var authorized = false
    @Published var pendingCount: Int = 0

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            authorized = granted
            await refreshPendingCount()
        } catch { authorized = false }
    }

    func refreshStatus() async {
        let s = await UNUserNotificationCenter.current().notificationSettings()
        authorized = s.authorizationStatus == .authorized || s.authorizationStatus == .provisional
        await refreshPendingCount()
    }

    func refreshPendingCount() async {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        pendingCount = pending.count
    }

    func schedule(title: String, date: Date, id: String) async throws {
        guard date > Date() else { throw SchedulingError.dateInPast }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "PackWise reminder"
        content.sound = .default
        content.categoryIdentifier = "packwise.reminder"
        let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(req)
        await refreshPendingCount()
    }

    func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        Task { await refreshPendingCount() }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        pendingCount = 0
    }

    enum SchedulingError: LocalizedError {
        case dateInPast
        var errorDescription: String? {
            switch self { case .dateInPast: return "Reminder date is in the past." }
        }
    }
}
