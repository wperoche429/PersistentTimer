//
//  InterfaceController.swift
//  PersistentTimer WatchKit Extension
//
//  Created by William Peroche on 16/11/15.
//  Copyright © 2015 William Peroche. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var secondPicker: WKInterfacePicker!
    @IBOutlet var minutePicker: WKInterfacePicker!
    var timer : Timer?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        timer = TimerManager.sharedInstance.currentTimer

        var minItems: [WKPickerItem] = []
        var secItems: [WKPickerItem] = []
        for min in 0...59 {
            let pickerItem = WKPickerItem()
            pickerItem.title = String(min)
            minItems.append(pickerItem)
            for sec in 0...59 {
                let pickerItem = WKPickerItem()
                pickerItem.title = String(sec)
                secItems.append(pickerItem)
            }
        }        
        minutePicker.setItems(minItems)
        minutePicker.setSelectedItemIndex((timer?.minute)!)
        
        let secIndex = ((timer?.minute)! * 60) + (timer?.second)!
        secondPicker.setItems(secItems)
        secondPicker.setSelectedItemIndex(secIndex)

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        secondPicker.focus()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    @IBAction func minuteChanged(value: Int) {
        timer?.minute = value
    }

    @IBAction func secondChanged(value: Int) {
        
        timer?.second = value % 60
        timer?.minute = value / 60
        minutePicker.setSelectedItemIndex((timer?.minute)!)

        
    }
    
    @IBAction func startAction() {
        timer?.start()
        WKInterfaceController.reloadRootControllersWithNames(["CountdownInterfaceController"], contexts: nil)
    }
    
    @IBAction func resetAction() {
        timer?.second = 0;
        timer?.minute = 0;
        secondPicker.setSelectedItemIndex(0)
        minutePicker.setSelectedItemIndex(0)
    }
}
