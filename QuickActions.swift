//
//  QuickActions.swift
//  QuickActions
//
//  Created by Ricardo Pereira on 20/02/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import UIKit

enum ShortcutIcon: Int {
    case Compose
    case Play
    case Pause
    case Add
    case Location
    case Search
    case Share
    case Prohibit
    case Contact
    case Home
    case MarkLocation
    case Favorite
    case Love
    case Cloud
    case Invitation
    case Confirmation
    case Mail
    case Message
    case Date
    case Time
    case CapturePhoto
    case CaptureVideo
    case Task
    case TaskCompleted
    case Alarm
    case Bookmark
    case Shuffle
    case Audio
    case Update
    case Custom

    @available(iOS 9.0, *)
    func toApplicationShortcutIcon() -> UIApplicationShortcutIcon? {
        if self == .Custom {
            NSException(name: "Invalid option", reason: "`Custom` type need to be used with `toApplicationShortcutIcon:imageName`", userInfo: nil).raise()
            return nil
        }
        if #available(iOS 9.1, *) {
            let icon = UIApplicationShortcutIconType(rawValue: self.rawValue) ?? UIApplicationShortcutIconType.Confirmation
            return UIApplicationShortcutIcon(type: icon)
        } else {
            let icon = UIApplicationShortcutIconType(rawValue: self.rawValue) ?? UIApplicationShortcutIconType.Add
            return UIApplicationShortcutIcon(type: icon)
        }
    }

    @available(iOS 9.0, *)
    func toApplicationShortcutIcon(imageName: String) -> UIApplicationShortcutIcon? {
        if self == .Custom {
            return UIApplicationShortcutIcon(templateImageName: imageName)
        }
        else {
            NSException(name: "Invalid option", reason: "Type need to be `Custom`", userInfo: nil).raise()
            return nil
        }
    }

}

struct Shortcut {

    let id: String
    let title: String
    let subtitle: String?
    let icon: ShortcutIcon?

    init(id: String, title: String, subtitle: String?, icon: ShortcutIcon) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

}

extension Shortcut {

    @available(iOS 9.0, *)
    init(shortcutItem: UIApplicationShortcutItem) {
        if let range = shortcutItem.type.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "."), options: .BackwardsSearch) {
            id = shortcutItem.type.substringFromIndex(range.endIndex)
        }
        else {
            id = "unknown"
        }
        title = shortcutItem.localizedTitle
        subtitle = shortcutItem.localizedSubtitle
        // FIXME: shortcutItem.icon!.type isn't accessible
        icon = nil
    }

    @available(iOS 9.0, *)
    private func toApplicationShortcut(bundleIdentifier: String) -> UIApplicationShortcutItem {
        return UIMutableApplicationShortcutItem(type: bundleIdentifier + "." + id, localizedTitle: title, localizedSubtitle: subtitle, icon: icon!.toApplicationShortcutIcon(), userInfo: nil)
    }

}

@available(iOS 9.0, *)
extension UIApplicationShortcutItem {

    var toShortcut: Shortcut {
        return Shortcut(shortcutItem: self)
    }

}

protocol QuickActionSupport {

    @available(iOS 9.0, *)
    func prepareForQuickAction(shortcut: Shortcut)

}

class QuickActions {

    let bundleIdentifier: String

    init(_ application: UIApplication, viewController: UIViewController?, bundleIdentifier: String, shortcuts: [Shortcut], launchOptions: NSDictionary? = nil) {
        self.bundleIdentifier = bundleIdentifier

        if #available(iOS 9.0, *) {
            install(shortcuts, toApplication: application)
        }

        if #available(iOS 9.0, *), let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            handle(viewController, shortcutItem: shortcutItem)
        }
    }

    /// Install initial Quick Actions (app shortcuts)
    @available(iOS 9.0, *)
    private func install(shortcuts: [Shortcut], toApplication application: UIApplication) {
        application.shortcutItems = shortcuts.map { $0.toApplicationShortcut(bundleIdentifier) }
    }

    @available(iOS 9.0, *)
    func handle(viewController: UIViewController?, shortcutItem: UIApplicationShortcutItem) -> Bool {
        return handle(viewController, shortcut: shortcutItem.toShortcut)
    }

    func handle(viewController: UIViewController?, shortcut: Shortcut) -> Bool {
        guard let viewController = viewController as? QuickActionSupport else { return false }
        if #available(iOS 9.0, *) {
            viewController.prepareForQuickAction(shortcut)
            return true
        }
        else {
            return false
        }
    }

    func add(shortcuts: [Shortcut], toApplication application: UIApplication) {
        if #available(iOS 9.0, *) {
            var items = shortcuts.map { $0.toApplicationShortcut(bundleIdentifier) }
            items.appendContentsOf(application.shortcutItems ?? [])
            application.shortcutItems = items
        }
    }

    func add(shortcut: Shortcut, toApplication application: UIApplication) {
        add([shortcut], toApplication: application)
    }

    func remove(shortcut: Shortcut, toApplication application: UIApplication) {
        if #available(iOS 9.0, *) {
            if let index = application.shortcutItems?.indexOf(shortcut.toApplicationShortcut(bundleIdentifier)) where index > -1 {
                application.shortcutItems?.removeAtIndex(index)
            }
        }
    }

    func clear(application: UIApplication) {
        if #available(iOS 9.0, *) {
            application.shortcutItems = nil
        }
    }

}
