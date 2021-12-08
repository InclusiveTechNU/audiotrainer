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
let breakpoints: [[NSNumber]] = [[12.05, 24.95]]

if CommandLine.arguments.count != 3 {
    fatalError("""
    TutorialTransfer requires three arguments:
        (1) the source tutorial
        (2) the destination tutorial
    """)
}

let sourceURL = URL(fileURLWithPath: CommandLine.arguments[1])
let destinationURL = URL(fileURLWithPath: CommandLine.arguments[2])

let sourceData = try! Data(contentsOf: sourceURL)
guard let sourceRecording = try! NSKeyedUnarchiver.unarchivedObject(ofClass: ATRecording.self,
                                                                    from: sourceData) else {
    fatalError("Failed to decode source recording")
}


let destinationData = try! Data(contentsOf: destinationURL)
guard let destinationRecording = try! NSKeyedUnarchiver.unarchivedObject(ofClass: ATRecording.self,
                                                                         from: destinationData) else {
    fatalError("Failed to decode destination recording")
}

destinationRecording.replaceAudioBuffer(sourceRecording.audioBuffer)
destinationRecording.updateSectionsBreakpoints(withBreakpoints: breakpoints)

let newFileName = "TRANSFERRED-\(destinationURL.lastPathComponent)"
let outputURL = destinationURL.deletingLastPathComponent()
                              .appendingPathComponent(newFileName)
destinationRecording.export(toPath: outputURL)
print("Completed Transfer to path \(outputURL.absoluteString)!")
