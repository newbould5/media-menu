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
    var text = ""
    
    let menu:NSMenu = NSMenu()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("media-play-symbol"))
            button.action = #selector(clicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        constructMenu()
        
        var _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(AppDelegate.refresh), userInfo: nil, repeats: true)

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
            switchText()
        }
    }
    
    @objc func switchText() {
        let button = statusItem.button
        if(showingText){
            button?.image = image
            button?.title = ""
        } else {
            reloadSong()
            button?.image = nil
            button?.title = text
        }
        showingText = !showingText
    }
    
    @objc func reloadSong(){
        var error: NSDictionary? = nil
        var title = ""
        var artist = ""
        if let scriptObject = NSAppleScript(source: currentTrackScript) {
            if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
                title=outputString
            }
        }
        
        if let scriptObject = NSAppleScript(source: currentArtistScript) {
            if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
                artist=outputString
            }
        }
        text = title == "Not playing" ? title : title + " - " + artist
    }
    
    @objc func refresh(){
        if(showingText){
            reloadSong()
            statusItem.button?.title = text
        }
    }
    
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    let currentTrackScript = """
        if application "Spotify" is running then
            tell application "Spotify"
                if player state is playing then
                    return name of current track
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
    
    let skipScript = """
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

