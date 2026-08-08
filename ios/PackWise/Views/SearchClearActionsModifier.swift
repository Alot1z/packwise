import SwiftUI

/// Availability-safe wrapper for `.searchActions` (iOS 18+ only).
///
/// PackWise's deployment target is iOS 17, where `searchActions` does not
/// exist — calling it unguarded is a hard compile error. On iOS 18+ this
/// presents a "Clear search" button in the search accessory toolbar whenever
/// the field has text; on iOS 17 it degrades to the platform's built-in clear
/// button inside the search field (same user outcome, no API needed).
///
/// Usage:  `.searchable(...).searchClearAction($text)`
struct SearchClearActionsModifier: ViewModifier {
    @Binding var search: String
    var clearLabel: String = "Clear search"

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.searchActions {
                if !search.isEmpty {
                    Button(clearLabel) { search = "" }
                }
            }
        } else {
            content
        }
    }
}

extension View {
    /// Adds a "Clear search" action to the search accessory toolbar.
    /// No-op on iOS 17 (the search field already offers a built-in clear).
    func searchClearAction(_ search: Binding<String>, clearLabel: String = "Clear search") -> some View {
        modifier(SearchClearActionsModifier(search: search, clearLabel: clearLabel))
    }
}
