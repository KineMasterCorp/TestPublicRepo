//
//  AppDelegate.swift
//  FeedUI
//
//  Created by ETHAN2 on 2021/05/24.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var homeViewController: HomeViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        homeViewController = HomeViewController()
        let interactor = HomeInteractorImpl(presenter: HomePresenter(view: homeViewController!),
                                            navigator: HomeNavigatorImpl(viewController: homeViewController!))
        homeViewController?.interactor = interactor
                
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = homeViewController
        window!.makeKeyAndVisible()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch(let error) {
            print(error.localizedDescription)
        }

        return true
    }
}

