import Foundation

/// Pure, testable logic for composing an outfit's ordered item list.
///
/// The outfits canvas drag-and-drop and the save flow both funnel through
/// these functions so the ordering rules are unit-testable without a view.
enum OutfitComposer {
    /// Appends `id` to the composition unless it is already present.
    static func adding(_ id: UUID, to ids: [UUID]) -> [UUID] {
        guard !ids.contains(id) else { return ids }
        return ids + [id]
    }

    /// Removes `id` from the composition.
    static func removing(_ id: UUID, from ids: [UUID]) -> [UUID] {
        ids.filter { $0 != id }
    }

    /// Moves `id` so it sits directly before `before` in the composition.
    /// If either id is absent, the list is returned unchanged.
    static func moving(_ id: UUID, before: UUID, in ids: [UUID]) -> [UUID] {
        guard let from = ids.firstIndex(of: id),
              let to = ids.firstIndex(of: before),
              from != to else { return ids }
        var result = ids
        result.remove(at: from)
        let adjustedTo = result.firstIndex(of: before) ?? result.endIndex
        result.insert(id, at: adjustedTo)
        return result
    }
}
