//
//  AppDelegate.swift
//  media menu
//
//  Created by Michael Newbould on 05/07/2019.
//  Copyright © 2019 Michael Newbould. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let image = NSImage(named:NSImage.Name("media-play-symbol"))
    var showingText = false
    var mode = "advanced"
    @objc dynamic var text = ""
    
    let menu:NSMenu = NSMenu() //TODO remove later
    let popover = NSPopover()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("media-play-symbol"))
            button.action = #selector(clicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
//            button.action = #selector(togglePopover(_:))
        }
        
        constructMenu() //TODO remove
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        popover.contentViewController = storyboard.instantiateController(withIdentifier: "PlayerViewController") as? NSViewController
        popover.behavior = NSPopover.Behavior.transient
        
        var _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(AppDelegate.refresh), userInfo: nil, repeats: true)

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
    
    //TODO could show pop up with controls like skip play prev... and add hide button there
    //this way we dont need to fiddle with all of this and keep a more natural flow
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
    
    @objc func clickedBasic(sender: NSStatusBarButton!){
        let event:NSEvent! = NSApp.currentEvent!
        if (event.type == NSEvent.EventType.rightMouseUp) {
            statusItem.menu = menu //set the menu
            statusItem.popUpMenu(menu)// show the menu
            statusItem.menu = nil //need to set it back to nil otherwise new left click will open the menu
        }
        else{
            switchText()
        }
    }
    
    func switchText() {
        let button = statusItem.button
        if(showingText){
            button?.image = image
            button?.title = ""
        } else {
            button?.image = nil
            button?.title = text
        }
        showingText = !showingText
    }
    
    @objc func reloadSong(){
        var error: NSDictionary? = nil
        var title = "Not playing"
        if let scriptObject = NSAppleScript(source: currentTrackScript) {
            if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
                title=outputString
            }
        }
        
        if (title == "Not playing" && showingText) {
            // show icon
            switchText()
        } else if (title != "Not playing") {
            text = title
            if (!showingText) {
                // show title, this will also trigger an update
                switchText()
            } else {
                // update title
                statusItem.button?.title = text
            }
        }
    }
    
    @objc func refresh() {
        if (mode == "basic") {
            // basic mode will not constantly look for state change
            if (showingText) {
                reloadSong()
            }
        } else {
            // advanced mode will automatically show title or hide title depending on whether a song is playing or not
            reloadSong()
        }
    }
    
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "Basic mode", action: #selector(switchMode(trigger:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    @objc func switchMode(trigger: NSMenuItem){
        if (trigger.state.rawValue == 0) {
            switchToBasic(trigger: trigger)
        }
        else {
            switchToAdvanced(trigger: trigger)
        }
    }
    
    func switchToBasic(trigger: NSMenuItem){
        if let button = statusItem.button {
            button.action = #selector(clickedBasic(sender:))
        }
        trigger.state = NSControl.StateValue(rawValue: 1)
        mode = "basic"
    }
    
    func switchToAdvanced(trigger: NSMenuItem){
        if let button = statusItem.button {
            button.action = #selector(clicked(sender:))
        }
        trigger.state = NSControl.StateValue(rawValue: 0)
        mode = "advanced"
    }
    
    func execScript(source: String) {
        var error: NSDictionary? = nil
        if let scriptObject = NSAppleScript(source: source) {
            scriptObject.executeAndReturnError(&error)
        }
        refresh()
    }
    
    func prev (){
        execScript(source: prevScript)
    }
    
    func playpause(){
        execScript(source: playpauseScript)
    }
    
    func next(){
        execScript(source: nextScript)
    }
    
    let currentTrackScript = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    return (name of current track) & " - " & (artist of current track)
                else
                    return "Not playing"
                end if
            end tell
        end if
    """
    
    let currentArtistScript = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    return artist of current track
                else
                    return ""
                end if
            end tell
        end if
    """
    
    let songURLScript = """
    tell application "Spotify"
        return spotify url of current track
    end tell
        
    """
    
    let playpauseScript = """
    if application "Spotify" is running
        tell application "Spotify"
            playpause
        end tell
    end if
        
    """
    
    let nextScript = """
    if application "Spotify" is running
        tell application "Spotify"
            next track
        end tell
    end if
        
    """
    
    let prevScript = """
    if application "Spotify" is running
        tell application "Spotify"
            previous track
        end tell
    end if
        
    """

}

