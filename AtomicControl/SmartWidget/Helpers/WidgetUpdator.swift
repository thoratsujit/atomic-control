//
//  WidgetUpdator.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 21/09/24.
//

import Foundation
import WidgetKit

enum WidgetUpdator {
    static func reloadWidgets() {
#if os(iOS)
        if #available(iOS 18.0, *) {
            ControlCenter.shared.reloadAllControls()
        }
#endif
        WidgetCenter.shared.reloadAllTimelines()
    }
}
