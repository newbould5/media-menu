//
//  PlayerViewController.swift
//  media menu
//
//  Created by Michael Newbould on 06/07/2019.
//  Copyright © 2019 Michael Newbould. All rights reserved.
//

import Cocoa

class PlayerViewController: NSViewController {
    let delegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate

    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var playButton: NSButton!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        delegate.reloadSong()
        view.window?.makeFirstResponder(playButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        delegate.addObserver(self, forKeyPath: "text", options: [.new], context: nil)
        
        textLabel.placeholderString = "Not playing"
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        textLabel.placeholderString = change![NSKeyValueChangeKey.newKey] as? String
    }
    
}

extension PlayerViewController {
    
    @IBAction func previous(_ sender: NSButton) {
        delegate.prev()
    }
    
    @IBAction func next(_ sender: NSButton) {
        delegate.next()
    }
    
    @IBAction func playpause(_ sender: NSButton) {
        delegate.playpause()
        //change button?
    }
    
    @IBAction func quit(_ sender: NSButton) {
        NSApplication.shared.terminate(sender)
    }
    
    @IBAction func hide(_ sender: NSButton) {
        delegate.switchText()
        sender.title = sender.title == "Hide" ? "Show" : "Hide"
    }
}
