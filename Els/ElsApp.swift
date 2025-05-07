import SwiftUI

@main
struct ElsApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                DashBoardView() // Your dashboard view
                    .frame(width: 850, height: 600)
                    .padding(.bottom,25)
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
    }
}
