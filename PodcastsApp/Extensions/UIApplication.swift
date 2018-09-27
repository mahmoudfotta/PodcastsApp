//
//  UIApplication.swift
//  PodcastsApp
//
//  Created by mahmoud gamal on 9/18/18.
//  Copyright © 2018 mahmoud gamal. All rights reserved.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}
