import SwiftUI
import SwiftData

struct TemplateLibraryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \PackTemplate.createdAt, order: .reverse) private var templates: [PackTemplate]
    @Query(sort: \Trip.updatedAt, order: .reverse) private var trips: [Trip]
    @State private var selectedTripID: UUID?
    @State private var showDeleteConfirm: PackTemplate?

    var body: some View {
        NavigationStack {
            List {
                if templates.isEmpty {
                    Section {
                        Text("No templates yet. Add a starter below — all stored locally, no account needed.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Section("Starter templates") {
                    ForEach(Array(starterTemplates.enumerated()), id: \.offset) { _, t in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(t.name).font(.subheadline.weight(.medium))
                                Text(t.detail).font(.caption).foregroundStyle(.secondary)
                                Text("\(t.items.count) items · \(t.tag)").font(.caption2).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Add") {
                                let m = PackTemplate(name: t.name, tag: t.tag, detail: t.detail, items: t.items)
                                context.insert(m)
                                try? context.save()
                                #if canImport(UIKit)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                #endif
                            }
                            .buttonStyle(.bordered).controlSize(.small)
                            .accessibilityLabel("Add template \(t.name) to library")
                        }
                        .padding(.vertical, 2)
                    }
                }
                if !templates.isEmpty {
                    Section("Your templates") {
                        ForEach(templates) { tpl in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(tpl.name).font(.subheadline.weight(.medium))
                                    Spacer()
                                    Text(tpl.tag ?? "Custom").font(.caption2).padding(.horizontal, 6).padding(.vertical, 2).background(.secondary.opacity(0.15), in: Capsule())
                                }
                                if let d = tpl.detail { Text(d).font(.caption).foregroundStyle(.secondary) }
                                Text("\(tpl.decodedItems.count) items").font(.caption2).foregroundStyle(.secondary)
                                HStack {
                                    Picker("Apply to trip", selection: $selectedTripID) {
                                        Text("Choose trip").tag(nil as UUID?)
                                        ForEach(trips) { Text($0.title).tag($0.id as UUID?) }
                                    }.labelsHidden().pickerStyle(.menu)
                                    Button("Apply") {
                                        guard let id = selectedTripID, let trip = trips.first(where: { $0.id == id }) else { return }
                                        for it in tpl.decodedItems {
                                            let item = PackingItem(name: it.name, category: it.category, quantity: it.quantity, essential: it.essential, trip: trip)
                                            context.insert(item)
                                        }
                                        trip.updatedAt = Date()
                                        try? context.save()
                                        #if canImport(UIKit)
                                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                                        #endif
                                    }
                                    .disabled(selectedTripID == nil)
                                    .buttonStyle(.borderedProminent).controlSize(.small)
                                    .accessibilityLabel("Apply \(tpl.name) to selected trip")
                                    Spacer()
                                    Button("Delete", role: .destructive) { showDeleteConfirm = tpl }
                                        .buttonStyle(.bordered).controlSize(.small)
                                        .accessibilityLabel("Delete template \(tpl.name)")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Templates")
            .confirmationDialog("Delete template?", isPresented: Binding(get: { showDeleteConfirm != nil }, set: { if !$0 { showDeleteConfirm = nil } }), titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let tpl = showDeleteConfirm { context.delete(tpl); try? context.save() }
                    showDeleteConfirm = nil
                }
                Button("Cancel", role: .cancel) { showDeleteConfirm = nil }
            }
        }
    }
}
