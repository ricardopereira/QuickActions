[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/QuickActions.svg?style=flat-square)](https://cocoapods.org/pods/QuickActions) [![Platform support](https://img.shields.io/badge/platform-ios-lightgrey.svg?style=flat-square)](https://github.com/ricardopereira/QuickActions/blob/master/LICENSE)[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/ricardopereira/QuickActions/blob/master/LICENSE)


# QuickActions
Swift wrapper for iOS QuickActions (App Icon Shortcuts)

## Usage

Install a list of shortcuts:


```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    let shortcuts = [Shortcut(id: "CreateExpense", title: NSLocalizedString("CreateExpenseTitle", comment: ""), subtitle: NSLocalizedString("CreateExpenseSubTitle", comment: ""), icon: .Add)]

    if let rootViewController = window?.rootViewController, bundleIdentifier = NSBundle.mainBundle().bundleIdentifier {
        quickActions = QuickActions(application, viewController: rootViewController, bundleIdentifier: bundleIdentifier, shortcuts: shortcuts, launchOptions: launchOptions)
    }
}
```

Add more shortcuts:

```swift
func applicationDidEnterBackground(application: UIApplication) {
    let shortcuts = [Shortcut(id: "LastItems", title: "Last items", subtitle: nil, icon: nil)]
    quickActions?.add(shortcuts, toApplication: application)
}
```

Handle each shortcut:

```swift
@available(iOS 9, *)
func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
    // This callback is used if your application is already launched in the background, if not application(_:,willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions) will be called (handle the shortcut in those callbacks and return `false`)
    guard let quickActions = quickActions else { return completionHandler(false) }
    guard let rootViewController = window?.rootViewController else { return completionHandler(false) }
    completionHandler(quickActions.handle(rootViewController, shortcutItem: shortcutItem))
}
```

Prepare your view controller using the `QuickActionSupport` protocol:

```swift
class MainViewController: UIViewController, QuickActionSupport {

    func prepareForQuickAction(shortcut: Shortcut) {
        print(shortcut)
    }    

}
```

## Installation

#### <img src="https://cloud.githubusercontent.com/assets/432536/5252404/443d64f4-7952-11e4-9d26-fc5cc664cb61.png" width="24" height="24"> [Carthage]

[Carthage]: https://github.com/Carthage/Carthage

To install it, simply add the following line to your **Cartfile**:

```ruby
github "ricardopereira/QuickActions"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation]
for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### <img src="https://dl.dropboxusercontent.com/u/11377305/resources/cocoapods.png" width="24" height="24"> [CocoaPods]

[CocoaPods]: http://cocoapods.org

To install it, simply add the following line to your **Podfile**:

```ruby
pod "QuickActions"
```

You will also need to make sure you're opting into using frameworks:

```ruby
use_frameworks!
```

Then run `pod install` with CocoaPods 0.36 or newer.

## Requirements

* iOS 8.0+
* Xcode 7 (Swift 2.0)

## Author

Ricardo Pereira, [@ricardopereiraw](https://twitter.com/ricardopereiraw)

## License

QuickActions is available under the MIT license. See the [LICENSE] file for more info.

[LICENSE]: /LICENSE

