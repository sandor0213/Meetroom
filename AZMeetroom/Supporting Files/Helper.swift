//
//  Helper.swift
//  AZMeetroom
//
//  Created by Balogh Sandor on 5/27/19.
//  Copyright © 2019 AdlerBalogh. All rights reserved.
//

import Foundation

final class Helper: NSObject {
    
    public class func getWeekNumber() -> String {
        let calendar = Calendar.current
        let weekOfYear = String(calendar.component(.weekOfYear, from: Date.init(timeIntervalSinceNow: 0)))
        return weekOfYear
    }
}

