//
//  Timer.swift
//  PersistentTimer
//
//  Created by William Peroche on 16/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import UIKit
import Foundation
import WatchKit
import WatchConnectivity

protocol TimerDelegate : class {
    func timeUpdate(timeInString : String)
}

class Timer: NSObject, WKExtensionDelegate {
    
    var hour : Int = 0
    var minute : Int = 0 {
        didSet {
            save()
        }
    }
    var second : Int = 0 {
        didSet {
            save()
        }
    }
    var remainingTotalTime : Int = 0
    var timeStarted : NSDate?
    var timePause : NSDate?
    var name : String = ""
    var id : String?
    var totalPauseTime : Int = 0
    var repeating = false
    var timeInString : String {
        get {
            var timeValue = getTimerValue()
            if let _ = timeStarted {
                timeValue = remainingTotalTime
            }
            if (remainingTotalTime == 0 && timeStarted != nil) {
                
                WKInterfaceDevice.currentDevice().playHaptic(.Notification)
                NSLog("Play haptic")
                
            }
            return TimerManager.timerInString(timeValue)
        }
    }
    private var myDelegates : [TimerDelegate] = []
    private var scheduledTimer : NSTimer?
    
    override init() {
        super.init()
        id = NSUUID().UUIDString
        timeStarted = nil
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(hour, forKey: "hour")
        aCoder.encodeInteger(minute, forKey: "minute")
        aCoder.encodeInteger(second, forKey: "second")
        aCoder.encodeInteger(totalPauseTime, forKey: "totalPauseTime")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(timeStarted, forKey: "timeStarted")
        aCoder.encodeObject(timePause, forKey: "timePause")
        aCoder.encodeBool(repeating, forKey: "repeating")
        
    }
    
    init(coder aDecoder: NSCoder) {
        super.init()
        name = aDecoder.decodeObjectForKey("name") as! String
        id = aDecoder.decodeObjectForKey("id") as? String
        hour = aDecoder.decodeIntegerForKey("hour")
        minute = aDecoder.decodeIntegerForKey("minute")
        second = aDecoder.decodeIntegerForKey("second")
        totalPauseTime = aDecoder.decodeIntegerForKey("totalPauseTime")
        timeStarted = aDecoder.decodeObjectForKey("timeStarted") as? NSDate
        timePause = aDecoder.decodeObjectForKey("timePause") as? NSDate
        repeating = aDecoder.decodeBoolForKey("repeating")
        
        if let _ = timeStarted {
            remainingTotalTime = getTimerValue()
            startTimer()
        }
        
    }
    
    func save() {
        TimerManager.sharedInstance.addTimer(self)
    }
    
    func updateTime () {
        if (remainingTotalTime == 0 && timeStarted != nil) {
            if !repeating {
                stop()
                for myDelegate in myDelegates {
                    myDelegate.timeUpdate(TimerManager.timerInString(getTimerValue()))
                }
                return
            }
            
        }
        
        let timerValue = getTimerValue()
        
        if let _ = timeStarted {
            let currentDate = NSDate()
            var timeLapse : Int = (Int)(currentDate.timeIntervalSinceDate(timeStarted!))
            
            
            if (timePause != nil) {
                timeLapse = (Int)((timePause!.timeIntervalSinceDate(timeStarted!)))
            }
            
            remainingTotalTime = timerValue - ((timeLapse - totalPauseTime) % (timerValue + 1))
            if !repeating {
                if ((timeLapse - totalPauseTime) / (timerValue + 1) > 1) {
                    remainingTotalTime = 0
                }
            }
            
        } else  {
            remainingTotalTime = timerValue
        }
        
        for myDelegate in myDelegates {
            myDelegate.timeUpdate(self.timeInString)
        }
        
        
        
        
    }
    
    func start() {
        timeStarted = NSDate()
        timePause = nil
        totalPauseTime = 0
        remainingTotalTime = getTimerValue()
        save()
        startTimer()
        TimerManager.reloadComplications()
        
        let dict = NSDictionary(objects: [NSNumber(integer: remainingTotalTime), timeStarted!], forKeys: ["count", "startDate"])
        updatePhone(["timer": dict])
    }
    
    func stop() {
        timeStarted = nil
        timePause = nil
        totalPauseTime = 0
        save()
        stopTimer()
        TimerManager.reloadComplications()
        updatePhone(["cancelNotification": "cancel"])
    }
    
    func pause() {
        timePause = NSDate()
        save()
        TimerManager.reloadComplications()
    }
    
    func resume() {
        let pauseTime = (Int)(NSDate().timeIntervalSinceDate(timePause!))
        totalPauseTime += pauseTime
        timePause = nil
        save()
        TimerManager.reloadComplications()
    }
    
    func getTimerValue() -> Int {
        var timerValue = 0
        timerValue += second
        timerValue += minute * 60
        timerValue += hour * 60 * 60
        
        return timerValue
    }
    
    
    
    func subscribe(delegate : TimerDelegate) {
        var found = false
        
        for myDelegate in myDelegates {
            if myDelegate === delegate {
                found = true
                break
            }
        }
        
        if !found {
            myDelegates.append(delegate)
        }
        
        
    }
    
    func unsubscribe(delegate : TimerDelegate) {
        var index = 0
        for myDelegate in myDelegates {
            if myDelegate === delegate {
                myDelegates.removeAtIndex(index)
                return
            }
            index++
        }
    }
    
    private func startTimer() {
        stopTimer()
        scheduledTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        if let _ = scheduledTimer {
            scheduledTimer?.invalidate()
            scheduledTimer = nil
        }
    }
    
    private func updatePhone(context: [String : AnyObject]) {
        if WCSession.isSupported() {
            
            if (WCSession.defaultSession().reachable) {
                print("reachable")
                
                WCSession.defaultSession().sendMessage(context, replyHandler: { (respond) -> Void in
                    
                    }, errorHandler: { (error) -> Void in
                        
                })
            }
            
        }
    }
    
}
