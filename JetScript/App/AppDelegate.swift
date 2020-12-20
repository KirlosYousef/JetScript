//
//  AppDelegate.swift
//  JetScript
//
//  Created by Kirlos Yousef on 17/12/2020.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = MainView()
            .frame(minWidth: WindowSize().minWidth, maxWidth: .infinity,
                   minHeight: WindowSize().minHeight, maxHeight: .infinity)
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: WindowSize().minWidth,
                                height: WindowSize().minHeight),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView.environmentObject(Script()))
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}

