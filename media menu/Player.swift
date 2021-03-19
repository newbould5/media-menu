//
//  Player.swift
//  media menu
//
//  Created by Michael Newbould on 28/01/2021.
//  Copyright © 2021 Michael Newbould. All rights reserved.
//

import Foundation

protocol Player {    
    func playpause(isPlaying: Bool)
    func next()
    func prev()
    func getState() -> String
}
