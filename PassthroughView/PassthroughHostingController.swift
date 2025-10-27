//
//  PassthroughHostingController.swift
//  PassthroughView
//
//  Created by WasiqNisar on 23/10/2025.
//

import SwiftUI

class PassthroughHostingController<Content: View>: UIHostingController<Content> {
    private let passthroughView = PassthroughView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keep SwiftUI's layout intact but embed inside passthrough container
        guard let hostingView = super.view else { return }
        
        hostingView.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        passthroughView.backgroundColor = .clear
        
        passthroughView.addSubview(hostingView)
        view = passthroughView
        
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: passthroughView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: passthroughView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: passthroughView.trailingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: passthroughView.bottomAnchor)
        ])
    }
    
    final class PassthroughView: UIView {
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let hitView = super.hitTest(point, with: event) else { return nil }

            // 1. If the hit view is the PassthroughView itself (the overall background).
            if hitView === self {
                // Use the pixel check to decide if the background is clear.
                if isTransparent(at: point) {
                    return nil // Transparent background -> PASS THROUGH
                }
                return hitView // Opaque background -> BLOCK (Shouldn't happen with .clear)
            }
            
            // 2. If the hit view is a child view (the SwiftUI content, e.g., the sheet).
            
            // If the child view's touch point is not visually rendered (e.g., the gap
            // between views or a clipped corner on the sheet's background).
            // We still need this check to pass through holes *within* the sheet's views.
            if isTransparent(at: point) {
                return nil // Pass through if the pixel is visually clear
            }

            // The touch landed on an opaque pixel *within the sheet's content* (Text, Button, Sheet Background).
            // To guarantee Text blocks the touch (fixing the cross-version issue), we simply block it here.
            return hitView // BLOCK TOUCH
        }
    }
}

extension UIView {
    func isTransparent(at point: CGPoint) -> Bool {
        // Render a 1x1 area around the touch point
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

extension CGImage {
    func alpha(at point: CGPoint) -> UInt8 {
        guard let dataProvider = self.dataProvider,
              let data = dataProvider.data else { return 255 }
        let pixelData = CFDataGetBytePtr(data)
        let bytesPerPixel = bitsPerPixel / 8
        let pixelIndex = Int(point.y) * bytesPerRow + Int(point.x) * bytesPerPixel
        return pixelData?[pixelIndex + 3] ?? 255
    }
}
