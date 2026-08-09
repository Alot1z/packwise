import SwiftUI
import WidgetKit

// MARK: - Widget Bundle

@main
struct PackWiseWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextTripWidget()
        PackingProgressWidget()
    }
}
