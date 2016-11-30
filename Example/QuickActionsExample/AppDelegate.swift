//
//  AppDelegate.swift
//  QuickActionsExample
//
//  Created by Ricardo Pereira on 01/03/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import UIKit
import QuickActions

enum AppShortcut: String, ShortcutType {
    case createExpense
    case lastItems
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var quickActions: QuickActions<AppShortcut>?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = MainViewController()

        let shortcuts = [
            Shortcut(
                type: AppShortcut.createExpense,
                title: NSLocalizedString("CreateExpenseTitle", comment: ""),
                subtitle: NSLocalizedString("CreateExpenseSubTitle", comment: ""),
                icon: .add
            )
        ]

        if let actionHandler = window?.rootViewController as? QuickActionSupport,
           let bundleIdentifier = Bundle.main.bundleIdentifier {
            quickActions = QuickActions(application, actionHandler: actionHandler, bundleIdentifier: bundleIdentifier, shortcuts: shortcuts, launchOptions: launchOptions)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let shortcuts = [Shortcut(type: AppShortcut.lastItems, title: "Last items", subtitle: nil, icon: nil)]
        quickActions?.add(shortcuts, toApplication: application)
    }

    @available(iOS 9, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Swift.Void) {
        // This callback is used if your application is already launched in the background, if not application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) will be called (handle the shortcut in those callbacks and return `false`)
        guard let quickActions = quickActions else {
            return completionHandler(false)
        }
        guard let actionHandler = window?.rootViewController as? QuickActionSupport else {
            return completionHandler(false)
        }
        completionHandler(quickActions.handle(actionHandler, shortcutItem: shortcutItem))
    }

}

