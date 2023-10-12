//
//  MainViewController.swift
//  QuickActionsExample
//
//  Created by Ricardo Pereira on 01/03/16.
//  Copyright © 2016 Ricardo Pereira. All rights reserved.
//

import UIKit
import QuickActions

class MainViewController: UIViewController, QuickActionSupport {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }

    func prepareForQuickAction<T: ShortcutType>(_ shortcutType: T) {
        if let shortcut = AppShortcut(rawValue: shortcutType.value), case .createExpense = shortcut {
            print("Prepare the view to create a new expense")
        }
    }

}

