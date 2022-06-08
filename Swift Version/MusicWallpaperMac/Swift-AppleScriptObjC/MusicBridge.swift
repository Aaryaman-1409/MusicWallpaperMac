//
//  Support.swift
//  Swift-AppleScriptObjC
//

import Cocoa



@objc(NSObject) protocol MusicBridge {
    
    // Important: ASOC does not bridge C primitives, only Cocoa classes and objects,
    // so Swift Bool/Int/Double values MUST be explicitly boxed/unboxed as NSNumber
    // when passing to/from AppleScript.
    
    //could be implemented as computed variables with no get and set. These functions are basically there to check if the return values and names of the applescript to objC conversions are correct. The extensions below then convert these to swift readable form.
    func _isRunning()->NSNumber
    
    func _trackInfo()-> NSString?
    func _trackArtwork()-> NSData?
    
    // applescript parameters are converted to objc positional parameters with the same name
    // e.g on random_func: param is converted to objC as random_func(param), with type NSsmth However
    // in swift positional parameters are not the default. So first you name the label of the
    // parameter the same, i.e random_func(param:NSString). Then to make it positional,
    // you rename to label to be blank random_func(_ param:NSString)
    func setDesktop(_ theString: NSString)
}


extension MusicBridge { // native Swift versions of the above ASOC APIs
    
    func isRunning()-> Bool { return self._isRunning().boolValue }
}



