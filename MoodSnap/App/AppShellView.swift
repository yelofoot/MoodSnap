import SwiftUI

struct AppShellView: View {
    var body: some View {
        TabView {
            Text("Home")
                .tabItem { Label("Home", systemImage: "house.fill") }
            Text("Settings")
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    AppShellView()
}
