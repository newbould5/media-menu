//
//  PlayerService.swift
//  media menu
//
//  Created by Michael Newbould on 28/01/2021.
//  Copyright © 2021 Michael Newbould. All rights reserved.
//

import Foundation

@available(OSX 10.15, *)
class PlayerService: ObservableObject {
    //TODO use lastUsedPlayer where needed
    //TODO do we still need activePlayer? can we not just check if the last is still active?
    
    @Published var state: String
    
    private var players: [Player] = [ SpotifyPlayer() ]
    private var lastUsedPlayer: Player
    private let queue: DispatchQueue = DispatchQueue(label: "action")
    
    init() {
        self.state = ""
        self.lastUsedPlayer = players[0]
        let refresh = DispatchQueue(label: "refresh")
        refresh.async{
            while true {
                self.refresh()
                sleep(2)
            }
        }
    }

    func prev() {
        queue.async {
            let player = self.lastUsedPlayer
            player.prev()
            self.refreshPlayer(player: player)
        }
    }
    
    func playpause(){
        queue.async {
            let player = self.lastUsedPlayer
            player.playpause(isPlaying: self.isPlaying())
            self.refreshPlayer(player: player)
        }
    }
    
    func next(){
        queue.async {
            let player = self.lastUsedPlayer
            player.next()
            self.refreshPlayer(player: player)
        }
    }
    
    func getState() -> String {
        return state
    }
    
    func enableSonos() {
        players.append(SonosPlayer())
    }
    
    func disableSonos() {
        if players.count == 2 {
            players.remove(at: 1)
        }
        self.lastUsedPlayer = players[0]
    }
    
    private func refresh() {
        for player in players {
            let state = player.getState()
            if state != "Not playing" {
                self.state = state
                self.lastUsedPlayer = player
                return
            }
        }
        self.state = "Not playing"
    }
    
    private func refreshPlayer(player: Player) {
        state = player.getState()
    }
    
    private func isPlaying() -> Bool {
        return self.state != "Not playing"
    }
    
}
