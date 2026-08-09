import SwiftUI

/// Availability-safe wrapper for `.searchActions` (iOS 18+ only).
///
/// PackWise targets iOS 17 where `searchActions` does not exist.
/// A `@available(iOS 18.0, *) private extension View` was previously used
/// to host the `searchActions` call but the Xcode compiler still type-checks
/// the body against the iOS 17 deployment target and rejects
/// `self.searchActions` as a nonexistent member.
///
/// The reliable fix is a generic wrapper View struct marked
/// `@available(iOS 18.0, *)` — the entire struct body lives in the
/// iOS 18 availability domain so `base.searchActions` resolves correctly.
/// On iOS 17 the fallback returns `self` unchanged (the `searchable`
/// field already has a built-in clear button).
///
/// Usage: `.searchable(...).searchClearAction($text)`
extension View {
    @ViewBuilder
    func searchClearAction(_ search: Binding<String>, clearLabel: String = "Clear search") -> some View {
        if #available(iOS 18.0, *) {
            SearchActionsView(base: self, search: search, clearLabel: clearLabel)
        } else {
            self
        }
    }
}

/// Hosts the iOS 18 `.searchActions` call on a generic View base.
/// The entire type is guarded by `@available(iOS 18.0, *)` so the
/// compiler never evaluates `base.searchActions` against iOS 17.
@available(iOS 18.0, *)
private struct SearchActionsView<Base: View>: View {
    let base: Base
    @Binding var search: String
    let clearLabel: String

    var body: some View {
        base.searchActions {
            if !search.isEmpty {
                Button(clearLabel) { search = "" }
            }
        }
    }
}
