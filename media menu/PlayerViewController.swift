//
//  PlayerViewController.swift
//  media menu
//
//  Created by Michael Newbould on 06/07/2019.
//  Copyright © 2019 Michael Newbould. All rights reserved.
//

import Cocoa
import Combine

@available(OSX 10.15, *)
class PlayerViewController: NSViewController {
    let delegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate
    var cancellables = Set<AnyCancellable>()

    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var playButton: NSButton!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.makeFirstResponder(playButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate.$text.sink() {
            let text = $0
            DispatchQueue.main.async {
                self.textLabel.placeholderString = text
            }
        }.store(in: &cancellables)
        
        textLabel.placeholderString = "Not playing"
    }
    
}

@available(OSX 10.15, *)
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
}
