//
//  SplashViewController.swift
//  NewsApp
//
//  Created by Ahror Jabborov on 1/23/25.
//

import UIKit
import SnapKit
import Reachability

// this is the custom splash screen with spinning logo and internet check
final class SplashViewController: UIViewController {
    
    private let logoImageView = UIImageView()
    private let reachability = try? Reachability()
    private var timer: Timer?
    private var isCheckingConnection = false
    private var isConnected = false
    private let spinAnimationKey = "spinAnimation"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "0A2D73")
        configureLogo()
        configureReachability()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSequence()
    }
    
    private func configureLogo() {
        logoImageView.image = UIImage(named: "app_logo")
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }
    }
    
    private func configureReachability() {
        reachability?.whenReachable = { [weak self] network in
            self?.handleReachable(network)
        }
        reachability?.whenUnreachable = { [weak self] _ in
            self?.handleUnreachable()
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Error starting Reachability: \(error)")
        }
    }
    
    private func startSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.beginSpinning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startConnectionCheck()
            }
        }
    }
    
    private func beginSpinning() {
        let spinAnimation = CABasicAnimation(keyPath: "transform.rotation")
        spinAnimation.fromValue = 0
        spinAnimation.toValue = CGFloat.pi
        spinAnimation.duration = 1
        spinAnimation.repeatCount = .infinity
        logoImageView.layer.add(spinAnimation, forKey: spinAnimationKey)
    }
    
    private func stopSpinning() {
        logoImageView.layer.removeAnimation(forKey: spinAnimationKey)
    }
    
    private func startConnectionCheck() {
        guard !isCheckingConnection else { return }
        isCheckingConnection = true
        isConnected = reachability?.connection != .unavailable
        
        if isConnected {
            stopSpinning()
            proceedNext()
            return
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isCheckingConnection = false
            if self.isConnected {
                self.stopSpinning()
                self.proceedNext()
            } else {
                self.stopSpinning()
                self.presentOfflineAlert()
            }
        }
    }
    
    private func handleReachable(_ network: Reachability) {
        isConnected = true
        if isCheckingConnection {
            timer?.invalidate()
            timer = nil
            isCheckingConnection = false
            stopSpinning()
            proceedNext()
        }
    }
    
    private func handleUnreachable() {
        isConnected = false
    }
    
    private func presentOfflineAlert() {
        let alertController = UIAlertController(title: "No Internet",
                                                message: "Retry?",
                                                preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.isConnected = false
            self.beginSpinning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startConnectionCheck()
            }
        }
        alertController.addAction(retryAction)
        present(alertController, animated: true)
    }
    
    private func proceedNext() {
        reachability?.stopNotifier()
        let hasSeenWelcome = UserDefaults.standard.bool(forKey: "hasSeenWelcome")
        if hasSeenWelcome {
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.goToMain()
            }
        } else {
            let welcomeViewController = WelcomeViewController()
            let navigationController = UINavigationController(rootViewController: welcomeViewController)
            guard let window = view.window else { return }
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve) {
                window.rootViewController = navigationController
            }
        }
    }
    
    deinit {
        reachability?.stopNotifier()
    }
}
