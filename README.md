# PassthroughView - SwiftUI Touch Passthrough Implementation

This project demonstrates how to create a SwiftUI view that allows touches to pass through transparent areas to underlying UIKit views, while still handling touches on visible SwiftUI content.

## 🎯 Overview

The `PassthroughHostingController` enables SwiftUI views to coexist with UIKit views by implementing intelligent touch passthrough. When a user taps on a transparent area of a SwiftUI view, the touch passes through to the underlying UIKit view. When they tap on visible SwiftUI content (text, buttons, images), the SwiftUI view handles the touch normally.

## 🏗️ Architecture

### Core Components

1. **PassthroughHostingController** - A custom `UIHostingController` that wraps SwiftUI content
2. **PassthroughView** - A custom `UIView` that implements the touch passthrough logic
3. **Pixel Transparency Detection** - Extension that checks if a specific pixel is transparent

## 🔧 How It Works

### 1. PassthroughHostingController

```swift
class PassthroughHostingController<Content: View>: UIHostingController<Content> {
    private let passthroughView = PassthroughView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Embed SwiftUI view inside passthrough container
        guard let hostingView = super.view else { return }

        hostingView.backgroundColor = .clear
        passthroughView.addSubview(hostingView)
        view = passthroughView

        // Set up constraints to maintain SwiftUI layout
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: passthroughView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: passthroughView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: passthroughView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: passthroughView.bottomAnchor)
        ])
    }
}
```

**Key Features:**

- Wraps the standard SwiftUI hosting view in a custom passthrough container
- Maintains SwiftUI's layout system through Auto Layout constraints
- Preserves all SwiftUI functionality while adding passthrough capabilities

### 2. PassthroughView - The Magic Happens Here

```swift
final class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }

        // 1. Don't intercept self or fully transparent views
        if hitView === self || hitView.isHidden || hitView.alpha < 0.01 {
            return nil
        }

        // 2. Check pixel transparency at the touch point
        if hitView.isTransparent(at: point) {
            return nil  // Pass through to underlying views
        }

        // 3. Block the touch for visible content
        return hitView
    }
}
```

**Touch Passthrough Logic:**

1. **Self Check**: If the touch hits the passthrough view itself, pass it through
2. **Transparency Check**: If the touched pixel is transparent, pass it through
3. **Content Block**: If the touched pixel is opaque (visible content), handle the touch

### 3. Pixel Transparency Detection

```swift
extension UIView {
    func isTransparent(at point: CGPoint) -> Bool {
        let scale = UIScreen.main.scale
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return false }

        context.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let alpha = image?.cgImage?.alpha(at: CGPoint(x: 0, y: 0)) else {
            return false
        }

        return alpha == 0
    }
}
```

**How It Works:**

- Renders a 1x1 pixel area around the touch point
- Extracts the alpha channel value of that pixel
- Returns `true` if the pixel is completely transparent (alpha = 0)

## 🚀 Usage Example

### Setting Up the Passthrough View

```swift
class ViewController: UIViewController {
    private var hostingVC: PassthroughHostingController<MySwiftUIView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }

    private func setupSwiftUIView() {
        let swiftUIView = MySwiftUIView()
        let hostingVC = PassthroughHostingController(rootView: swiftUIView)

        self.hostingVC = hostingVC
        addChild(hostingVC)
        hostingVC.view.frame = view.bounds
        hostingVC.view.backgroundColor = .clear
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
    }
}
```

### SwiftUI View with Passthrough Areas

```swift
struct MySwiftUIView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Transparent area - touches pass through to UIKit
            Color.clear

            // Visible content - blocks touches
            VStack {
                Text("This blocks touches")
                Button("This also blocks touches") {
                    // Handle button tap
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .onTapGesture {} // Empty gesture ensures this area blocks touches
        }
    }
}
```

### Complete Example with Proper Gesture Handling

```swift
struct MySwiftUIView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Top area - touches pass through (no gesture)
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom sheet - blocks touches
            VStack {
                Text("Bottom Sheet")
                Button("Action") {
                    print("Button tapped")
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .onTapGesture {} // Critical: Empty gesture blocks passthrough

            // Floating button - blocks touches
            Button("Floating") {
                print("Floating button tapped")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(25)
            .onTapGesture {} // Critical: Empty gesture blocks passthrough
        }
    }
}
```
