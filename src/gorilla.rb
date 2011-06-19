framework 'AppKit' 
framework 'Foundation'
framework 'Cocoa' 


require 'notification_handler'
require 'gorilla_helpers'
include GorillaHelpers



BUNDLE_ID = 'com.primates.gorilla'
PREFERENCES = read_prefs(BUNDLE_ID)

workspace = NSWorkspace.sharedWorkspace
center =    workspace.notificationCenter
handler =   NotificationHandler.new(PREFERENCES)

center.addObserver(handler, selector: "will_launch_application:",   name: NSWorkspaceWillLaunchApplicationNotification, object: nil)
center.addObserver(handler, selector: "did_launch_application:",   name: NSWorkspaceDidLaunchApplicationNotification,    object: nil)
center.addObserver(handler, selector: "did_terminate_application:",   name: NSWorkspaceDidTerminateApplicationNotification,    object: nil)
# center.addObserver(handler, selector: "will_analyze:",   name: GorillaAnalyzeStats,    object: nil)



NSLog "The gorilla is alive..."
this = NSApplication.sharedApplication 
this.run
