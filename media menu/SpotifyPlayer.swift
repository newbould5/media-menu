//
//  SpotifyPlayer.swift
//  media menu
//
//  Created by Michael Newbould on 28/01/2021.
//  Copyright © 2021 Michael Newbould. All rights reserved.
//

import Foundation

class SpotifyPlayer: Player {
    
    func getState() -> String {
        return execScript(source: currentTrackScript)
    }
    
    func prev (){
        let _ = execScript(source: prevScript)
    }
    
    func playpause(isPlaying: Bool){
        let _ = execScript(source: playpauseScript)
    }
    
    func next(){
        let _ = execScript(source: nextScript)
    }
    
    func execScript(source: String) -> String {
        var output = ""
        var error: NSDictionary? = nil
        if let scriptObject = NSAppleScript(source: source) {
            if let outputString = scriptObject.executeAndReturnError(&error).stringValue {
                output=outputString
            }
        }
        return output
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
        else
            return "Not playing"
        end if
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
