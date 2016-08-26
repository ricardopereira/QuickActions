//
//  QuickActions.swift
//  QuickActions
//
//  Created by Ricardo Pereira on 20/02/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import UIKit

public enum ShortcutIcon: Int {
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

public protocol ShortcutType: RawRepresentable {}

public extension RawRepresentable where Self: ShortcutType {

    public init?(type: String) {
        assert(type is RawValue)
        // FIXME: try another solution to restrain the RawRepresentable as String
        self.init(rawValue: type as! RawValue)
    }

    public var value: String {
        return self.rawValue as? String ?? ""
    }

}

public struct Shortcut {

    public let type: String
    public let title: String
    public let subtitle: String?
    public let icon: ShortcutIcon?

    public init<T: ShortcutType>(type: T, title: String, subtitle: String?, icon: ShortcutIcon?) {
        self.type = type.value
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

}

public extension Shortcut {

    @available(iOS 9.0, *)
    public init(shortcutItem: UIApplicationShortcutItem) {
        if let range = shortcutItem.type.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "."), options: .BackwardsSearch) {
            type = shortcutItem.type.substringFromIndex(range.endIndex)
        }
        else {
            type = "unknown"
        }
        title = shortcutItem.localizedTitle
        subtitle = shortcutItem.localizedSubtitle
        // FIXME: shortcutItem.icon!.type isn't accessible
        icon = nil
    }

    @available(iOS 9.0, *)
    private func toApplicationShortcut(bundleIdentifier: String) -> UIApplicationShortcutItem {
        return UIMutableApplicationShortcutItem(type: bundleIdentifier + "." + type, localizedTitle: title, localizedSubtitle: subtitle, icon: icon!.toApplicationShortcutIcon(), userInfo: nil)
    }

}

@available(iOS 9.0, *)
public extension UIApplicationShortcutItem {

    public var toShortcut: Shortcut {
        return Shortcut(shortcutItem: self)
    }

}

public protocol QuickActionSupport {

    @available(iOS 9.0, *)
    func prepareForQuickAction<T: ShortcutType>(shortcutType: T)

}

public class QuickActions<T: ShortcutType> {

    private let bundleIdentifier: String

    public init(_ application: UIApplication, actionHandler: QuickActionSupport?, bundleIdentifier: String, shortcuts: [Shortcut], launchOptions: NSDictionary? = nil) {
        self.bundleIdentifier = bundleIdentifier

        if #available(iOS 9.0, *) {
            install(shortcuts, toApplication: application)
        }

        if #available(iOS 9.0, *), let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            handle(actionHandler, shortcutItem: shortcutItem)
        }
    }

    /// Install initial Quick Actions (app shortcuts)
    @available(iOS 9.0, *)
    private func install(shortcuts: [Shortcut], toApplication application: UIApplication) {
        application.shortcutItems = shortcuts.map { $0.toApplicationShortcut(bundleIdentifier) }
    }

    @available(iOS 9.0, *)
    public func handle(actionHandler: QuickActionSupport?, shortcutItem: UIApplicationShortcutItem) -> Bool {
        return handle(actionHandler, shortcut: shortcutItem.toShortcut)
    }

    public func handle(actionHandler: QuickActionSupport?, shortcut: Shortcut) -> Bool {
        guard let viewController = actionHandler else { return false }
        if #available(iOS 9.0, *) {
            // FIXME: Can't use `shortcutType`: Segmentation fault: 11
            //let shortcutType = T.init(type: shortcut.type)
            viewController.prepareForQuickAction(T.init(type: shortcut.type)!)
            return true
        }
        else {
            return false
        }
    }

    public func add(shortcuts: [Shortcut], toApplication application: UIApplication) {
        if #available(iOS 9.0, *) {
            var items = shortcuts.map { $0.toApplicationShortcut(bundleIdentifier) }
            items.appendContentsOf(application.shortcutItems ?? [])
            application.shortcutItems = items
        }
    }

    public func add(shortcut: Shortcut, toApplication application: UIApplication) {
        add([shortcut], toApplication: application)
    }

    public func remove(shortcut: Shortcut, toApplication application: UIApplication) {
        if #available(iOS 9.0, *) {
            if let index = application.shortcutItems?.indexOf(shortcut.toApplicationShortcut(bundleIdentifier)) where index > -1 {
                application.shortcutItems?.removeAtIndex(index)
            }
        }
    }

    public func clear(application: UIApplication) {
        if #available(iOS 9.0, *) {
            application.shortcutItems = nil
        }
    }

}
