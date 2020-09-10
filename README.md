[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/QuickActions.svg)](https://cocoapods.org/pods/QuickActions)
[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com/ios/)
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)


# QuickActions
Swift wrapper for [iOS Home Screen Quick Actions](https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/Adopting3DTouchOniPhone/index.html#//apple_ref/doc/uid/TP40016543-CH1-SW2)

This wrapper creates dynamic quick actions. It is possible to define static quick actions in your app’s Info.plist file but I think it is nicer to add localizable shortcuts dynamically and handle them with type safety.

## Usage

```swift
import QuickActions
```

Define your application shortcuts with an enum. Don't forget to declare the enum with `String` and `ShortcutType`:

```swift
enum AppShortcut: String, ShortcutType {
    case createExpense
    case lastItems
}
```

Install a list of shortcuts:


```swift
var quickActions: QuickActions<AppShortcut>?

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    let shortcuts = [Shortcut(type: AppShortcut.CreateExpense, title: NSLocalizedString("CreateExpenseTitle", comment: ""), subtitle: NSLocalizedString("CreateExpenseSubTitle", comment: ""), icon: .Add)]

    if let actionHandler = window?.rootViewController as? QuickActionSupport, bundleIdentifier = Bundle.main.bundleIdentifier {
        quickActions = QuickActions(application, actionHandler: actionHandler, bundleIdentifier: bundleIdentifier, shortcuts: shortcuts, launchOptions: launchOptions)
    }
}
```

Add more shortcuts:

```swift
func applicationDidEnterBackground(application: UIApplication) {
    let shortcuts = [Shortcut(type: AppShortcut.lastItems, title: "Last items", subtitle: nil, icon: nil)]
    quickActions?.add(shortcuts, toApplication: application)
}
```

Handle each shortcut:

```swift
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
```

Prepare your view controller using the `QuickActionSupport` protocol:

```swift
class MainViewController: UIViewController, QuickActionSupport {

    func prepareForQuickAction<T: ShortcutType>(_ shortcutType: T) {
        if let shortcut = AppShortcut(rawValue: shortcutType.value), case .createExpense = shortcut {
            print("Prepare the view to create a new expense")
        }

        //or

        if let shortcut = AppShortcut(rawValue: shortcutType.value) {
            switch shortcut {
            case .createExpense:
                print("Prepare the view to create a new expense")
            case .lastItems:
                print("Prepare the view to show last items")
            }
        }
    }    

}
```

## Installation

#### <img src="https://cloud.githubusercontent.com/assets/432536/5252404/443d64f4-7952-11e4-9d26-fc5cc664cb61.png" width="24" height="24"> [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

To install it, simply add the following line to your **Cartfile**:

```ruby
github "ricardopereira/QuickActions" ~> 6.0.0
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### <img src="https://raw.githubusercontent.com/ricardopereira/resources/master/img/cocoapods.png" width="24" height="24"> [CocoaPods]

[CocoaPods]: http://cocoapods.org

To install it, simply add the following line to your **Podfile**:

```ruby
pod 'QuickActions' '~> 6.0.0'
```

You will also need to make sure you're opting into using frameworks:

```ruby
use_frameworks!
```

Then run `pod install` with CocoaPods 1.8.0 or newer.

#### Manually
1. Download and drop ```QuickActions.swift``` in your project.  
2. Congratulations! 

## Requirements

* iOS 10.0+
* Xcode 11.0 (Swift 5)

## Author

Ricardo Pereira, [@ricardopereiraw](https://twitter.com/ricardopereiraw)

## License

QuickActions is available under the MIT license. See the [LICENSE] file for more info.

[LICENSE]: /LICENSE

