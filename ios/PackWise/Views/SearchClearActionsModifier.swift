import SwiftUI

/// Availability-safe wrapper for `.searchActions` (iOS 18+ only).
///
/// PackWise targets iOS 17 where `searchActions` does not exist. Calling
/// `content.searchActions` directly on `ViewModifier.Content`
/// (`_ViewModifier_Content`) inside a `ViewModifier` body is a hard
/// compile error — even inside `if #available` — because the compiler still
/// resolves the member on the generic content type for the deployment target.
///
/// This file fixes that by never touching `searchActions` from a `ViewModifier`
/// at all. The public API is a `View` extension that either applies a
/// dedicated `@available(iOS 18.0, *)` modifier or returns `self` unchanged
/// on iOS 17 (where the search field already has a built-in clear button).
///
/// Usage: `.searchable(...).searchClearAction($text)`
extension View {
    @ViewBuilder
    func searchClearAction(_ search: Binding<String>, clearLabel: String = "Clear search") -> some View {
        if #available(iOS 18.0, *) {
            self.modifier(SearchActionsModifier18(search: search, clearLabel: clearLabel))
        } else {
            self
        }
    }
}

@available(iOS 18.0, *)
private struct SearchActionsModifier18: ViewModifier {
    @Binding var search: String
    var clearLabel: String

    func body(content: Content) -> some View {
        content.searchActions {
            if !search.isEmpty {
                Button(clearLabel) { search = "" }
            }
        }
    }
}
