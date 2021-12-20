//
//  ViewController.swift
//  VisualEffectTestProject
//
//  Created by kjs on 2021/12/20.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = .darkGray

        VisualEffects.snow.manager.ready(for: self.view.layer).run()
    }
}
