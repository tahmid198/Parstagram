//
//  SceneDelegate.swift
//  Parstagram
//
//  Created by Tahmid Zaman on 3/12/21.
//

import UIKit
import Parse

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        
        
        //Add user persistence across app restarts
        if PFUser.current() != nil{ //Checks if user is logged in
            login()    //If user is logged in we skip the login View Controller and switch to feed view automatically
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    //Login user
    func login(){
       let main = UIStoryboard(name: "Main", bundle: nil) //name: "Main" = Main.storyboard file name. Here we are loading up the Main storyboard. BTW it is possible to have multiple storyboards and have segues between them
        let feedNavigationController = main.instantiateViewController(identifier: "FeedNavigationController") //"FeedNavigationController" is the storyboardID of the navigation controller that is embedded with in the Feed View Controller
        window?.rootViewController = feedNavigationController//There is always one window per application. rootViewController is the window being displayed and if we change what it is it will automatically swith the window with no animation
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

