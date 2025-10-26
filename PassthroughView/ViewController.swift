//
//  ViewController.swift
//  PassthroughView
//
//  Created by WasiqNisar on 23/10/2025.
//

import UIKit
import SwiftUI
class ViewController: UIViewController {
    private let tapView = UIView()
    private var hostingVC: PassthroughHostingController<MySwiftUIView>?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIKitView()
        setupSwiftUIView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hostingVC?.view.frame = view.bounds
    }
    private func setupUIKitView() {
        tapView.backgroundColor = .systemYellow
        tapView.layer.cornerRadius = 12
        tapView.frame = CGRect(
            x: 60,
            y: 150,
            width: 250,
            height: 100
        )
        tapView.isUserInteractionEnabled = true
        view.addSubview(tapView)
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(
                handleUIKitTap
            )
        )
        view.addGestureRecognizer(tap)
    }
    private func setupSwiftUIView() {
        let swiftUIView = MySwiftUIView()
        let hostingVC = PassthroughHostingController(
            rootView: swiftUIView
        )
        self.hostingVC = hostingVC
        addChild(hostingVC)
        hostingVC.view.frame = view.bounds
        hostingVC.view.backgroundColor = .clear
        view.addSubview(hostingVC.view)
        hostingVC.didMove(toParent: self)
    }
    @objc private func handleUIKitTap() {
        let alert = UIAlertController(
            title: "UIKit View Tapped!",
            message: "Touch passed through SwiftUI clear area 🎯",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )
        present(
            alert,
            animated: true
        )
    }
}
