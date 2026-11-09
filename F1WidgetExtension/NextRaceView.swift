import F1Core
import SwiftUI
import WidgetKit

struct NextRaceView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NextRaceEntry

    var body: some View {
        NextRaceWidgetView(
            weekend: entry.weekend,
            session: entry.session,
            now: entry.date,
            style: entry.style,
            appearance: entry.appearance,
            layout: family == .systemSmall ? .small : .medium
        )
    }
}
