//
//  CountdownInterfaceController.swift
//  PersistentTimer
//
//  Created by William Peroche on 16/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//


import WatchKit
import Foundation


class CountdownInterfaceController: WKInterfaceController, TimerDelegate {

    @IBOutlet var pauseButton: WKInterfaceButton!
    @IBOutlet var timerLabel: WKInterfaceLabel!
    var timer : Timer?
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        timer = TimerManager.sharedInstance.currentTimer
        self.timerLabel.setText(timer?.timeInString)
        if let _ = timer?.timePause {
            self.pauseButton.setTitle("Resume")
        } else {
            self.pauseButton.setTitle("Pause")
        }
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        timer?.subscribe(self)
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        timer?.unsubscribe(self)
    }

    @IBAction func cancelAction() {
        timer?.stop()
        WKInterfaceController.reloadRootControllersWithNames(["InterfaceController"], contexts: nil)

        
    }
    
    @IBAction func pauseAction() {
        if let _ = timer?.timePause {
            timer?.resume()
            self.pauseButton.setTitle("Pause")
        } else {
            timer?.pause()
            self.pauseButton.setTitle("Resume")
        }
    }
    
    func timeUpdate(timeInString: String) {
        self.timerLabel.setText(timeInString)
    }
}
