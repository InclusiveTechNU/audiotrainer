//
//  main.swift
//  TutorialTransfer
//
//  Created by Tommy McHugh on 12/8/21.
//

import Foundation
import AudioTrainerSupport

// TODO: Move this to a command line argument
/// Transfers the array of breakpoints as the timestamps to seperate
/// the tutorial in the destination tutorial.
let breakpoints = [1, 2, 3, 4]

let arguments = CommandLine.arguments[1...]
if arguments.count != 2 {
    fatalError("""
    TutorialTransfer requires three arguments:
        (1) the source tutorial
        (2) the destination tutorial
    """)
}

let sourceURL = URL(fileURLWithPath: arguments[0])
let destinationURL = URL(fileURLWithPath: arguments[1])


