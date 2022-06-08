//
//  main.swift
//  Swift-AppleScriptObjC
//
//  Created by Aaryaman Sharma on 6/8/22.
//

import Foundation
import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
