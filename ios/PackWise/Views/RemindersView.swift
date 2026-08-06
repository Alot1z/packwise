import SwiftUI
import SwiftData

struct RemindersView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Reminder.fireDate) private var reminders: [Reminder]
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @State private var showAdd = false
    @StateObject private var notifications = NotificationService()

    var body: some View {
        NavigationStack {
            List {
                if reminders.isEmpty {
                    Section { Text("No reminders yet. Add packing or preparation reminders — delivered via Apple notifications, all local.").font(.caption).foregroundStyle(.secondary) }
                }
                ForEach(reminders) { r in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(r.title).font(.subheadline.weight(.medium))
                        Text(r.fireDate.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(.secondary)
                        if let t = r.trip { Text(t.title).font(.caption2).foregroundStyle(.secondary) }
                    }
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            notifications.cancel(id: r.id.uuidString)
                            context.delete(r); try? context.save()
                        }
                    }
                }
                Section {
                    Button("Enable notifications") { Task { await notifications.requestAuthorization() } }
                    Text(notifications.authorized ? "Notifications enabled." : "Permission required for reminders. Enable in Settings if prompted.").font(.caption).foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Reminders")
            .toolbar { Button { showAdd = true } label: { Label("Add", systemImage: "plus") } }
            .sheet(isPresented: $showAdd) { AddReminderSheet() }
            .task { await notifications.refreshStatus() }
        }
    }
}

private struct AddReminderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @State private var title = ""
    @State private var date = Date().addingTimeInterval(3600)
    @State private var tripID: UUID?
    @StateObject private var notifications = NotificationService()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title — e.g. Finish packing", text: $title)
                DatePicker("When", selection: $date)
                Picker("Trip (optional)", selection: $tripID) {
                    Text("None").tag(nil as UUID?)
                    ForEach(trips) { Text($0.title).tag($0.id as UUID?) }
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trip = tripID.flatMap { id in trips.first(where: { $0.id == id }) }
                        let r = Reminder(title: title.trimmingCharacters(in: .whitespaces), fireDate: date, trip: trip)
                        context.insert(r); try? context.save()
                        Task {
                            await notifications.requestAuthorization()
                            try? await notifications.schedule(title: r.title, date: r.fireDate, id: r.id.uuidString)
                        }
                        dismiss()
                    }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
