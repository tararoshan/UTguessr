//
//  SceneDelegate.swift
//  UTGuessr
//
//  Created by Alex Lu on 10/5/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // https://fluffy.es/how-to-transition-from-login-screen-to-tab-bar-controller/
    // For some reason, this isn't working --
    func changeRootViewController(_ targetVC: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        // Change the root view controller to the main tab controller (see "scene" func)
        window.rootViewController = targetVC
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Check if the user has logged in before
        // TODO change this for the keychain!
        if let loggedUsername = UserDefaults.standard.string(forKey: "UTGuessrUsername") {
            // Instantiate the main tab bar controller, set it as the root
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabController")
            window?.rootViewController = mainTabBarController
        } else {
            // If the user hasn't logged in: instantiate the login screen, set it as the root
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginScreen")
            window?.rootViewController = loginNavController
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

