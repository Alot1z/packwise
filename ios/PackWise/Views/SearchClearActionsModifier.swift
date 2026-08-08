import SwiftUI

/// Availability-safe wrapper for `.searchActions` (iOS 18+ only).
///
/// PackWise's deployment target is iOS 17, where `searchActions` does not
/// exist — calling it unguarded is a hard compile error. On iOS 18+ this
/// presents a "Clear search" button in the search accessory toolbar whenever
/// the field has text; on iOS 17 it degrades to the platform's built-in
/// clear button inside the search field (same user outcome, no API needed).
///
/// Usage:  `.searchable(...).searchClearAction($text)`
///
/// Implementation notes:
/// * The iOS-18 branch is a *separate* private struct fully annotated
///   `@available(iOS 18.0, *)`. That keeps `searchActions` confined to a
///   type that the compiler will not type-check on the iOS 17 target.
/// * The `ViewModifier.body` returns `AnyView` so Swift does not need to
///   unify the two branches into a `_ConditionalContent<…>`. `AnyView`
///   erasure is the canonical, compiler-confirmed workaround for
///   "SwiftUI iOS-version shims" with generic content.
///
/// This combination is the bulletproof form: no path through the code at
/// the iOS-17 deployment target ever requires `.searchActions` to resolve
/// on the generic `Content`, so compilation succeeds on iOS 17 while the
/// rich accessory toolbar is delivered on iOS 18+.
struct SearchClearActionsModifier: ViewModifier {
    @Binding var search: String
    var clearLabel: String = "Clear search"

    func body(content: Content) -> AnyView {
        if #available(iOS 18.0, *) {
            AnyView(
                SearchActionsWrapper(
                    content: content,
                    search: $search,
                    clearLabel: clearLabel
                )
            )
        } else {
            AnyView(content)
        }
    }
}

@available(iOS 18.0, *)
private struct SearchActionsWrapper<Content: View>: View {
    let content: Content
    @Binding var search: String
    var clearLabel: String

    var body: some View {
        content.searchActions {
            if !search.isEmpty {
                Button(clearLabel) { search = "" }
            }
        }
    }
}

extension View {
    /// Adds a "Clear search" action to the search accessory toolbar.
    /// No-op on iOS 17 (the search field already offers a built-in clear).
    func searchClearAction(
        _ search: Binding<String>,
        clearLabel: String = "Clear search"
    ) -> some View {
        modifier(SearchClearActionsModifier(search: search, clearLabel: clearLabel))
    }
}
