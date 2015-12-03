//
//  AppDelegate.swift
//  PersistentTimer
//
//  Created by William Peroche on 16/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        setupWatchConnectivity()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    }
    
    private func setupWatchConnectivity() {
        // 1
        if WCSession.isSupported() {
            // 2
            let session = WCSession.defaultSession()
            // 3
            session.delegate = self
            // 4
            session.activateSession()
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("receive")
        if let _ = applicationContext["cancelNotification"] as? String {
          UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
        if let timer = applicationContext["timer"] as? NSDictionary {
            let timerCount = timer.objectForKey("count") as! NSNumber
            let startDate = timer.objectForKey("startDate") as! NSDate
            createNotification(timerCount.integerValue, startDate: startDate)
            
        }
        
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("receive message")
        if let _ = message["cancelNotification"] as? String {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
        if let timer = message["timer"] as? NSDictionary {
            let timerCount = timer.objectForKey("count") as! NSNumber
            let startDate = timer.objectForKey("startDate") as! NSDate
            createNotification(timerCount.integerValue, startDate: startDate)
            
        }
    }
    
    func createNotification(timer : Int, startDate : NSDate) {
        for var i in 1...64 {
            let localNotif = UILocalNotification()
            localNotif.fireDate = startDate.dateByAddingTimeInterval((Double)(timer * i))
            localNotif.alertTitle = "Cycle ends"
            localNotif.alertBody = "Cycle ends"
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
            
        }
        
    }


}

