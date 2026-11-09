import SwiftUI

@main
struct F1WidgetApp: App {
    @State private var model = AppModel()

    var body: some Scene {
        Window("F1 Widget", id: "main") {
            ContentView()
                .environment(model)
                .frame(minWidth: 720, minHeight: 480)
                .task { await model.refresh() }
        }
    }
}
