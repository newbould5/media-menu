//
//  SonosPlayer.swift
//  media menu
//
//  Created by Michael Newbould on 28/01/2021.
//  Copyright © 2021 Michael Newbould. All rights reserved.
//

import Foundation

class SonosPlayer: Player {
    
    var artistExpression = try! NSRegularExpression(pattern: "Artist: (.*)")
    
    func playpause(isPlaying: Bool) {
        let cmd = isPlaying ? "pause" : "play"
        let _ = execSh(cmd: cmd)
    }
    
    func next() {
        let _ = execSh(cmd: "next")
    }
    
    func prev() {
        let _ = execSh(cmd: "prev")
    }
    
    func getState() -> String {
        let result = execSh(cmd: "track")
        let playing = result.matchingStrings(regex: "Playback state is '(.*?)':")
        
        if playing == "PLAYING" {
            let artist = result.matchingStrings(regex: "Artist: (.*)")
            let track = result.matchingStrings(regex: "Title: (.*)")
            return track + " - " + artist
        }
        return "Not playing"
    }
    
    func execSh(cmd: String) -> String {
        let sonosbin = UserDefaults.standard.object(forKey: "sonosbin") as! String
        let speaker = UserDefaults.standard.object(forKey: "speaker") as! String
        let command = sonosbin + " " + speaker + " " + cmd
        do {
            let task = Process()
            let pipe = Pipe()
            task.launchPath = "/usr/bin/env"
            task.arguments = ["zsh", "-c", command]
            task.standardOutput = pipe
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            try pipe.fileHandleForReading.close()
            
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } catch {
            print("unable to execute cmd \(cmd), \(error)")
            return ""
        }
    }
}

extension String {
    func matchingStrings(regex: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return "" }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        if !results.isEmpty {
            let result = results[0]
            return result.range(at: 1).location != NSNotFound ? nsString.substring(with: result.range(at: 1)) : ""
        }
        return ""
    }
}
