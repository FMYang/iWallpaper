//
//  AppDelegate.swift
//  iWallpaper
//
//  Created by yfm on 2024/1/5.
//

import UIKit
import KafkaRefresh
import Kingfisher
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configRefreshStyle()
        var config = DiskStorage.Config(name: "wallpaper", sizeLimit: 0)
        config.expiration = .days(7)
        ImageCache.default.diskStorage.config = config
        
        DispatchQueue.main.async {
            self.clearDocumentDirectory()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate {
    func configRefreshStyle() {
        KafkaRefreshDefaults.standard()?.headDefaultStyle = .replicatorWoody
        KafkaRefreshDefaults.standard()?.footDefaultStyle = .replicatorWoody
        KafkaRefreshDefaults.standard()?.themeColor = .red
    }
}

extension AppDelegate {
    func clearDocumentDirectory() {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileUrls = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
            for fileUrl in fileUrls {
                try fileManager.removeItem(at: fileUrl)
            }
            print("Document directory cleared.")
        } catch {
            print("Failed to clear document directory:", error)
        }
    }
}

