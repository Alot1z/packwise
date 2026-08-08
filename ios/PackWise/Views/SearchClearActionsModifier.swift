import SwiftUI

/// Availability-safe wrapper for `.searchActions` (iOS 18+ only).
///
/// PackWise targets iOS 17 where `searchActions` does not exist. Calling
/// `content.searchActions` directly on `ViewModifier.Content`
/// (`_ViewModifier_Content`) inside a `ViewModifier` body is a hard
/// compile error — even inside `@available(iOS 18.0, *)` and `if #available`
/// — because `ViewModifier.Content` never exposes `.searchActions`,
/// regardless of availability gating. The fix is to avoid `ViewModifier`
/// entirely: call `.searchActions` on the original `View` (which, on iOS 18,
/// does carry the modifier) through a private `@available(iOS 18.0, *)`
/// view-extension helper. On iOS 17 the fallback returns `self` unchanged
/// (the `searchable` field already has a built-in clear button).
///
/// Usage: `.searchable(...).searchClearAction($text)`
extension View {
    @ViewBuilder
    func searchClearAction(_ search: Binding<String>, clearLabel: String = "Clear search") -> some View {
        if #available(iOS 18.0, *) {
            _compatSearchClear(search: search, clearLabel: clearLabel)
        } else {
            self
        }
    }
}

@available(iOS 18.0, *)
private extension View {
    func _compatSearchClear(search: Binding<String>, clearLabel: String) -> some View {
        self.searchActions {
            if !search.wrappedValue.isEmpty {
                Button(clearLabel) { search.wrappedValue = "" }
            }
        }
    }
}
