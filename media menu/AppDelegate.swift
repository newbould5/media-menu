//
//  AppDelegate.swift
//  media menu
//
//  Created by Michael Newbould on 05/07/2019.
//  Copyright © 2019 Michael Newbould. All rights reserved.
//

import Cocoa
import Combine

@available(OSX 10.15, *)
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let image = NSImage(named:NSImage.Name("media-play-symbol"))
    var showingText = false
    @Published var text = "Not playing" //this is needed for the popover unfortunately
    
    let playerService = PlayerService()
    
    let menu:NSMenu = NSMenu()
    let popover = NSPopover()
    var preferences = NSWindowController()
    
    var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // set some defaults if not set
        if UserDefaults.standard.object(forKey: "speaker") == nil {
            UserDefaults.standard.set("Office", forKey: "speaker")
        }
        if UserDefaults.standard.object(forKey: "sonosbin") == nil {
            UserDefaults.standard.set("/usr/local/bin/sonos", forKey: "sonosbin")
        }
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("media-play-symbol"))
            button.action = #selector(clicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        constructMenu() //right click menu
        
        // popup
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        popover.contentViewController = storyboard.instantiateController(withIdentifier: "PlayerViewController") as? NSViewController
        popover.behavior = NSPopover.Behavior.transient
        
        // preferences
        let vc = storyboard.instantiateController(withIdentifier: "PreferencesViewController") as? NSViewController
        let window = NSWindow(contentViewController: vc!)
        let controller = NSWindowController(window: window)
        preferences = controller

        //on state change update whats shown
        playerService.$state.sink() {
            self.text = $0
            self.reloadSong()
        }.store(in: &cancellables)
    }
    
    func togglePopover(_ sender: Any?) -> () {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    
    @objc func clicked(sender: NSStatusBarButton!){
        let event:NSEvent! = NSApp.currentEvent!
        if (event.type == NSEvent.EventType.rightMouseUp) {
            statusItem.menu = menu //set the menu
            statusItem.popUpMenu(menu)// show the menu
            statusItem.menu = nil //need to set it back to nil otherwise new left click will open the menu
        }
        else{
            togglePopover(sender)
        }
    }
    
    func switchText() {
        if(showingText){
            hideText()
        } else {
            showText()
        }
    }
    
    func hideText() {
        DispatchQueue.main.async {
            self.statusItem.button?.image = self.image
            self.statusItem.button?.title = ""
            self.showingText = false
        }
    }
    
    func showText(){
        DispatchQueue.main.async {
            self.statusItem.button?.image = nil
            self.statusItem.button?.title = self.text
            self.showingText = true
        }
    }
    
    func reloadSong () {
        if text == "Not playing" && showingText {
            hideText()
        }
        if text != "Not playing" {
            showText()
        }
    }
    
    func constructMenu() {
        let menuItem = NSMenuItem(title: "Sonos", action: #selector(toggleSonos(trigger:)), keyEquivalent: "")
        menu.addItem(menuItem)
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences(trigger:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        if (UserDefaults.standard.bool(forKey: "sonos")) {
            menuItem.state = NSControl.StateValue(1)
            playerService.enableSonos()
        }
    }
    
    @objc
    func toggleSonos(trigger: NSMenuItem) {
        if (trigger.state.rawValue == 0) {
            playerService.enableSonos()
            trigger.state = NSControl.StateValue(1)
            UserDefaults.standard.set(true, forKey: "sonos")
        }
        else {
            playerService.disableSonos()
            trigger.state = NSControl.StateValue(0)
            UserDefaults.standard.set(false, forKey: "sonos")
        }
    }
    
    @objc
    func openPreferences(trigger: NSMenuItem) {
        preferences.showWindow(trigger)
    }

    func prev (){
        playerService.prev()
    }
    
    func playpause(){
        playerService.playpause()
    }
    
    func next(){
        playerService.next()
    }

}

