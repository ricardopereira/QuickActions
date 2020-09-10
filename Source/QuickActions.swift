//
//  QuickActions.swift
//  QuickActions
//
//  Created by Ricardo Pereira on 20/02/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import UIKit

public enum ShortcutIcon: Int {
    case compose
    case play
    case pause
    case add
    case location
    case search
    case share
    case prohibit
    case contact
    case home
    case markLocation
    case favorite
    case love
    case cloud
    case invitation
    case confirmation
    case mail
    case message
    case date
    case time
    case capturePhoto
    case captureVideo
    case task
    case taskCompleted
    case alarm
    case bookmark
    case shuffle
    case audio
    case update
    case custom

    @available(iOS 9.0, *)
    func toApplicationShortcutIcon() -> UIApplicationShortcutIcon? {
        if self == .custom {
            NSException(name: NSExceptionName(rawValue: "Invalid option"), reason: "`Custom` type need to be used with `toApplicationShortcutIcon:imageName`", userInfo: nil).raise()
            return nil
        }
        let icon = UIApplicationShortcutIcon.IconType(rawValue: self.rawValue) ?? UIApplicationShortcutIcon.IconType.confirmation
        return UIApplicationShortcutIcon(type: icon)
    }

    @available(iOS 9.0, *)
    func toApplicationShortcutIcon(_ imageName: String) -> UIApplicationShortcutIcon? {
        if self == .custom {
            return UIApplicationShortcutIcon(templateImageName: imageName)
        }
        else {
            NSException(name: NSExceptionName(rawValue: "Invalid option"), reason: "Type need to be `Custom`", userInfo: nil).raise()
            return nil
        }
    }

}

public protocol ShortcutType: RawRepresentable {}

public extension RawRepresentable where Self: ShortcutType {

    init?(type: String) {
        assert(type is RawValue)
        // FIXME: try another solution to restrain the RawRepresentable as String
        self.init(rawValue: type as! RawValue)
    }

    var value: String {
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
    init(shortcutItem: UIApplicationShortcutItem) {
        if let range = shortcutItem.type.rangeOfCharacter(from: CharacterSet(charactersIn: "."), options: .backwards) {
            type = String(shortcutItem.type[range.upperBound...])
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
    fileprivate func toApplicationShortcut(_ bundleIdentifier: String) -> UIApplicationShortcutItem {
        return UIMutableApplicationShortcutItem(type: bundleIdentifier + "." + type, localizedTitle: title, localizedSubtitle: subtitle, icon: icon?.toApplicationShortcutIcon(), userInfo: nil)
    }

}

@available(iOS 9.0, *)
public extension UIApplicationShortcutItem {

    var toShortcut: Shortcut {
        return Shortcut(shortcutItem: self)
    }

}

public protocol QuickActionSupport {

    @available(iOS 9.0, *)
    func prepareForQuickAction<T: ShortcutType>(_ shortcutType: T)

}

open class QuickActions<T: ShortcutType> {

    fileprivate let bundleIdentifier: String

    public init(_ application: UIApplication, actionHandler: QuickActionSupport?, bundleIdentifier: String, shortcuts: [Shortcut], launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        self.bundleIdentifier = bundleIdentifier

        if #available(iOS 9.0, *) {
            install(shortcuts, toApplication: application)
        }

        if #available(iOS 9.0, *), let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            handle(actionHandler, shortcutItem: shortcutItem)
        }
    }

    /// Install initial Quick Actions (app shortcuts)
    @available(iOS 9.0, *)
    fileprivate func install(_ shortcuts: [Shortcut], toApplication application: UIApplication) {
        application.shortcutItems = shortcuts.map { $0.toApplicationShortcut(bundleIdentifier) }
    }

    @available(iOS 9.0, *)
    @discardableResult
    open func handle(_ actionHandler: QuickActionSupport?, shortcutItem: UIApplicationShortcutItem) -> Bool {
        return handle(actionHandler, shortcut: shortcutItem.toShortcut)
    }

    open func handle(_ actionHandler: QuickActionSupport?, shortcut: Shortcut) -> Bool {
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

    open func add(_ shortcuts: [Shortcut], toApplication application: UIApplication) {
        if #available(iOS 9.0, *) {
            var items = shortcuts.map { $0.toApplicationShortcut(bundleIdentifier) }
            items.append(contentsOf: application.shortcutItems ?? [])
            application.shortcutItems = items
        }
    }

    open func add(_ shortcut: Shortcut, toApplication application: UIApplication) {
        add([shortcut], toApplication: application)
    }

    open func remove(_ shortcut: Shortcut, toApplication application: UIApplication) {
        if #available(iOS 9.0, *) {
            if let index = application.shortcutItems?.firstIndex(of: shortcut.toApplicationShortcut(bundleIdentifier)) , index > -1 {
                application.shortcutItems?.remove(at: index)
            }
        }
    }

    open func clear(_ application: UIApplication) {
        if #available(iOS 9.0, *) {
            application.shortcutItems = nil
        }
    }

}
