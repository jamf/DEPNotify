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

# create plist key to NOT bail out after EULA is accepted in ~/Library/Preferences/menu.nomad.DEPNotify.plist
defaults write menu.nomad.DEPNotify quitSuccessiveEULA -bool false

# Now to show a EULA button
echo "Command: ContinueButtonEULA: EULA" >> /var/tmp/depnotify.log

# Wait for user to accept EULA, nag them every minute or so
timer=1
nagtime=60
finished=false
rm -f /var/tmp/com.depnotify.agreement.done
while ! $finished; do
    let "timer++"
    echo "Status: Waiting until you accept EULA $timer" >> /var/tmp/depnotify.log
    sleep 1
    if [ -e "/var/tmp/com.depnotify.agreement.done" ]; then
        finished=true
        eula_accepted=$(defaults read /Users/Shared/DEPNotify.plist "EULA Agreed")
        echo "Command: MainText: Good, you're on board with the EULA." >> /var/tmp/depnotify.log
        echo "Status: Just confirmed you accepted the EULA: $eula_accepted" >> /var/tmp/depnotify.log
    fi
    if (( "$timer" > "$nagtime" )); then
        echo "Command: Status: you need to accept the EULA" >> /var/tmp/depnotify.log
        sleep 1
        echo "Command: Notification: Reminder - still waiting for you to accept the EULA." >> /var/tmp/depnotify.log
        timer=1
        echo "Command DeterminateOff:" >> /var/tmp/depnotify.log
        echo "Command: Determinate: $nagtime" >> /var/tmp/depnotify.log
    fi
done

echo "Command: ContinueButton: Agree" >> /var/tmp/depnotify.log

echo "Command: MainText: You to enter the Asset Tag in the registration now." >> /var/tmp/depnotify.log

# create plist for setup Registration fields in ~/Library/Preferences/menu.nomad.DEPNotify.plist
defaults write menu.nomad.DEPNotify RegisterMainTitle 'Register this Mac'
defaults write menu.nomad.DEPNotify RegisterButtonLabel 'Register'
defaults write menu.nomad.DEPNotify PathToPlistFile '/Users/Shared/'
defaults write menu.nomad.DEPNotify UITextFieldLowerPlaceholder '123456'
defaults write menu.nomad.DEPNotify UITextFieldLowerLabel 'Asset Tag'

# Now to show a Registration button which opens Registration Window
echo "Command: ContinueButtonRegister: Registration" >> /var/tmp/depnotify.log

# Wait for user to perform registration, nag them every minute or so
timer=1
nagtime=60
finished=false
rm -f /var/tmp/com.depnotify.registration.done
echo "Command DeterminateOff:" >> /var/tmp/depnotify.log
echo "Command: Determinate: $nagtime" >> /var/tmp/depnotify.log
while ! $finished; do
    let "timer++"
    echo "Status: Waiting until you perform registration $timer" >> /var/tmp/depnotify.log
    sleep 1
    if [ -e "/var/tmp/com.depnotify.registration.done" ]; then
        finished=true
        assettag=$(defaults read /Users/Shared/DEPNotify.plist "Asset Tag")
        echo "Command: MainText: Your Mac will be registered with Asset Tag: $assettag." >> /var/tmp/depnotify.log
        echo "Status: Basic setup is done now." >> /var/tmp/depnotify.log
    fi
    if (( "$timer" > "$nagtime" )); then
        echo "Command: Status: Registration is needed to complete the setup, please fill out the registration now." >> /var/tmp/depnotify.log
        sleep 1
        echo "Command: Notification: Reminder - still waiting for you to do registration." >> /var/tmp/depnotify.log
        timer=1
        echo "Command DeterminateOff:" >> /var/tmp/depnotify.log
        echo "Command: Determinate: $nagtime" >> /var/tmp/depnotify.log
    fi
done

# Wait a tic
sleep 3


# Show a quit dialog
echo "Command: Quit: The process is now complete." >> /var/tmp/depnotify.log
