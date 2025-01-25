//
//  WelcomeViewController.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import UIKit
import SnapKit

// temp onboarding :)
class WelcomeViewController: UIViewController {
    private let label = UILabel()
    private let animationDuration: TimeInterval = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        label.text = "Welcome!"
        label.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        label.textColor = UIColor(hex: "0A2D73")
        label.textAlignment = .center
        label.alpha = 0
        
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.label.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.goToMain()
            }
        }
    }
}
