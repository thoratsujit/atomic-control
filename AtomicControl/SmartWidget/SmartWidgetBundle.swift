//
//  SmartWidgetBundle.swift
//  SmartWidget
//
//  Created by Sujit Thorat on 17/09/24.
//

import WidgetKit
import SwiftUI

@main
struct SmartWidgetBundle: WidgetBundle {
    var body: some Widget {
        SmartDeviceWidget()
        if #available(iOSApplicationExtension 18.0, *) {
            SmartWidgetControl()
        }
    }
}
