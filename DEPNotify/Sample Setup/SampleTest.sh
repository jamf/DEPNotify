#!/bin/bash

###
### Quick run down of many DEPNotify commands
###

#
# SETUP
#

# Set a main image
# Image can be up to 660x105 it will scale up or down proportionally to fit

echo "Command: Image: /System/Library/CoreServices/Setup Assistant.app/Contents/Resources/mac book pro.tiff" >> /var/tmp/depnotify.log

# Set the Main Title at the top of the window

echo "Command: MainTitle: Welcome To DEPNotify" >> /var/tmp/depnotify.log

# Set the Body Text

echo "Command: MainText: This is some text showing how to do line\\nbreaks and other things to fill up some space.\\n\\nDEPNotify can really make your DEP workflows easier by showing progress to your users." >> /var/tmp/depnotify.log

# Now set things spinning

echo "Command DeterminateOff:" >> /var/tmp/depnotify.log

# pause a spell

sleep 3

# Set things to determinate and teach a bit about how to run DEPNotify

echo "Command: MainText: Now we are going to set the progress bar to 4 determinate steps." >> /var/tmp/depnotify.log

# And set the progress bar

echo "Command: Determinate: 4" >> /var/tmp/depnotify.log

echo "Status: Testing Step 1" >> /var/tmp/depnotify.log

sleep 3

echo "Status: Testing Step 2" >> /var/tmp/depnotify.log

sleep 3

echo "Status: Show a help button" >> /var/tmp/depnotify.log

# Show the help button with a URL to www.apple.com

echo "Command: Help: https://www.apple.com" >> /var/tmp/depnotify.log

# Now to show a notification - note that if DEPNotify is in the foreground you won't see this

echo "Command: Notification: This is a sample notification" >> /var/tmp/depnotify.log

sleep 3

# And now to show a full alert

echo "Command: Alert: The window is now unmovable" >> /var/tmp/depnotify.log

# Now to make the window unmoveable

echo "Command: WindowStyle: NotMovable" >> /var/tmp/depnotify.log

# Now to show a EULA button

echo "Command: ContinueButtonEULA:" >> /var/tmp/depnotify.log
echo "Command: ContinueButton: Agree" >> /var/tmp/depnotify.log

# Wait a tic

sleep 15

# Show a quit dialog

echo "Command: Quit:" >> /var/tmp/depnotify.log

