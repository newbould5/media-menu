//
//  PreferencesViewController.swift
//  media menu
//
//  Created by Michael Newbould on 14/03/2021.
//  Copyright © 2021 Michael Newbould. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak var speaker: NSTextField!
    @IBOutlet weak var sonosBin: NSTextField!
    
    func windowWillClose(_ notification: Notification) {
        let speakerVal = speaker?.stringValue
        let sonosBinVal = sonosBin?.stringValue
        
        if speakerVal != nil && speakerVal != "" {
            UserDefaults.standard.set(speakerVal, forKey: "speaker")
        }

        if sonosBinVal != nil && sonosBinVal != "" {
            UserDefaults.standard.set(sonosBinVal, forKey: "sonosbin")
        }
        
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self

        let speakerVal = UserDefaults.standard.object(forKey: "speaker") as! String
        speaker.placeholderString = speakerVal
        
        let sonosBinVal = UserDefaults.standard.object(forKey: "sonosbin") as! String
        sonosBin.placeholderString = sonosBinVal
    }
    
}
