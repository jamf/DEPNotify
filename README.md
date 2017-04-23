# DEPNotify

![DEPNotify Logo](https://gitlab.com/Mactroll/DEPNotify/raw/master/DEPNotify/Assets.xcassets/DEPNotify.imageset/depnotify_512.png)

DEPNotify is a small light weight notification app that was designed to let your users know what's going on during a DEP enrollment. The app is focused on being very simple to use and easy to deploy.

## Basic Usage

DEPNotify is completely controlled via echoing text to it's control file. By default this is `/var/tmp/depnotify.log` but you can change this to anything you want by launching the app with the `-v [some path]`.

The application then reacts to `Command:` and `Status:` lines written to the control file. 

##Commands
DEPNotify responds to a number of commands. All are prefaced with `Command:` and then the verb.

**Alert:** This creates an alert sheet on the DEPNotify window with an "Ok" button to allow the user to clear the alert. The text that follows the `Alert:` will be the contents to the alert.

*Example:* `Command: Alert: The installation is now finished`

**Determinate:** This makes the process bar be determinate instead of just a spinny bar. You need to follow this with the number of stages you'd like to have in the bar. Once set, every status update that you send DEPNotify will increment the bar by one stage.

*Example:* `Command: Determinate: 5`

**Help:**  This will show a help button in the lower right corner of the DEPNotify window. Pressing the button will open up the path that you specify. Note that this can be both web URLs, such as http://www.apple.com/support, or file paths to local files such as file:///Applications/Chess.app.

*Example:* `Command: Help: http://www.apple.com/support`


**Image:** This will replace the very fancy DEPNotify logo, created by Erik Gomez, with a very fancy image of your own. Note that DEPNotify should scale the image up or down to fit the space.

*Example:* `Command: Image: /tmp/logo.png`

**Logout:** This will show a sheet dialog and then log the user out when the "Logout" is clicked. This is commonly used to log the user out and initiate a FileVault encryption process.

*Example:* `Command: Logout: Please logout now to start disk encryption.`

**MainText:** This command will change the main body of text in the application.

*Example:* `Command: MainText: Something about how amazing the DEP process you've created is.`

*Notification:* This will issue a notification to the Mac's notification center and display it.

*Example:* 






