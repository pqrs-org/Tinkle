import MetalKit
import SwiftUI

struct ContentView: View {
    let mtkView: MTKView
    let delegate: MetalViewRenderer

    var body: some View {
        VStack {
            Text("SwiftUI + Metal")

            RepresentedMTKView(view: mtkView).frame(
                minWidth: 200.0,
                minHeight: 200.0
            )

            Divider()

            VStack {
                Text("Choose effect color")
                HStack {
                    Button(action: {
                        self.delegate.setColor(vector_float3(1.0, 0.3, 0.2))
                    }) {
                        Text("Red")
                    }
                    Button(action: {
                        self.delegate.setColor(vector_float3(0.2, 1.0, 0.3))
                    }) {
                        Text("Green")
                    }
                    Button(action: {
                        self.delegate.setColor(vector_float3(0.3, 0.2, 1.0))
                    }) {
                        Text("Blue")
                    }
                }
            }

            Divider()

            Button(action: {
                self.delegate.restart()
            }) {
                Text("Restart")
            }
        }
    }
}
