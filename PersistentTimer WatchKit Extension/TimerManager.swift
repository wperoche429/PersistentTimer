//
//  TimerManager.swift
//  PersistentTimer
//
//  Created by William Peroche on 16/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import Foundation
import ClockKit

class TimerManager {
    static let sharedInstance = TimerManager()
    var currentTimer : Timer?
    
    init () {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("saveTimers") {
            self.currentTimer = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as? Timer
        } else {
            self.currentTimer = Timer()
            self.currentTimer?.repeating = true
            addTimer(self.currentTimer!)
        }
        
        TimerManager.reloadComplications()
    }
    
    func addTimer(time : Timer) {
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(time), forKey: "saveTimers")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func reloadComplications() {
        if let complications: [CLKComplication] = CLKComplicationServer.sharedInstance().activeComplications {
            if complications.count > 0 {
                for complication in complications {
                    CLKComplicationServer.sharedInstance().reloadTimelineForComplication(complication)
                    NSLog("Reloading complication \(complication.description)...")
                }
                
            }
        }
    }
    
}