identify# DEPNotify

![DEPNotify Logo](https://gitlab.com/Mactroll/DEPNotify/raw/master/DEPNotify/Assets.xcassets/DEPNotify.imageset/depnotify_512.png)

DEPNotify is a small light weight notification app that was designed to let your users know what's going on during a DEP enrollment. The app is focused on being very simple to use and easy to deploy.

# Table of Contents

* [**Download**](#download)
* [**Basic Usage**](#basic-usage)
* [**Application Flags**](#application-flags)
* [**Default File Locations**](#default-file-locations)
* [**Commands**](#commands)
  * [**Main Window Configuration**](#main-window-configuration)
  * [**Interaction**](#interaction)
  * [**Notification**](#notification)
  * [**Completion**](#completion)
* [**Status Updates**](#status-updates)
* [**DEPNotify Plist**](#depnotify-plist)
  * [**Main Window Configuration**](#main-window-configuration)
  * [**EULA Window Configuration**](#eula-window-configuration)
  * [**Registration Window Configuration**](#registration-window-configuration)
* [**Workflow**](#workflow)
* [**Advanced Workflows**](#advanced-workflows)
* [**Changelog**](#changelog)
* [**Notes**](#notes)

# Download

Get the latest version, visit our tags: [DEPNotify tags](https://gitlab.com/Mactroll/DEPNotify/tags)

# Basic Usage

DEPNotify is completely controlled via echoing text to its control file. By default this is `/var/tmp/depnotify.log` but can be changed with the [`-path`](#-path) flag.

The application then reacts to `Command:` and `Status:` lines written to the control file.

# Application Flags

Application flags augment default settings or alert DEPNotify of different management software solutions to pull information from.

#### `-path`
This replaces the default control file located at `/var/tmp/depnotify.log` allowing to select the path with `-path [some path]`.

*Example:* `/Applications/DEPNotify.app/Contents/MacOS/DEPNotify -path /private/tmp/setup.txt`

#### `-fullScreen`
This flag will create a full screen behind the DEPNotify screen to focus the user on the task at hand. By default, DEPNotify launches as a window that can be moved by the end user. Additionally, command-control-x will quit DEPNotify, although this can be modified via the DEPNotify configuration.

*Example:* `/Applications/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen`

## MDM Specific Flags

#### `-filewave`
This has DEP Notify read in the FileWave log at `/var/log/fwcld.log` and then update the status line in the DEP Notify window with any downloads and installations.

*Example:* `/Applications/DEPNotify.app/Contents/MacOS/DEPNotify -filewave`

#### `-jamf`
This has DEP Notify read in the Jamf log at `/var/log/jamf.log` and then update the status line in the DEP Notify window with any installations or policy executions from the Jamf log. Note there is nothing special you need to name your items in Jamf for them to be read.

*Example:* `/Applications/DEPNotify.app/Contents/MacOS/DEPNotify -jamf`

  * jamf.log will be parsed for the following strings:
    * Downloading *- currently only found when Jamf DEBUG logging is enabled*
    * Installing
    * Successfully installed
    * failed *- when a package fails to install, it will attempt to find the package and reason it failed*
    * Error:
    * FileVault, Encrypt, and Encryption *- if one of these is listed, it will open an "alert sheet" via the **Alert:** command stating:  "FileVault has been enabled on this machine and a reboot will be required to start the encryption process."*
    * DEPNotify Quit *- upon reading, a **Command: Quit:** is issued stating "Setup Complete!" and if FileVault was enabled, it reiterates a reboot is needed.*
      * So, if a policy name contains this string, and executes on the machine, DEPNotify will quit itself.

  * The following strings will be ignored:
    * flat package *- for lines with "downloading flat package"*
    * bom *- for lines with "downloading bom" or "failed to download a bom" file for a package -- only seen when Jamf DEBUG logging is enabled*
    * an Apple package... *- for lines with "Installing an Apple package" -- only seen when Jamf DEBUG logging is enabled*
    * com.jamfsoftware.task.errors *- for lines that display Jamf Errors that we don't want displayed*

  * If you have Prefixes, Postfixes, or other Patterns in your package names, that you do not want displayed to screen, you can add those into the code as well.

#### `-munki`
This has DEP Notify read in the Munki log at `/Library/Managed Installs/Logs/ManagedSoftwareUpdate.log` and then update the status line in the DEP Notify window with any downloads and installations.

*Example:* `/Applications/DEPNotify.app/Contents/MacOS/DEPNotify -munki`

# Default File Locations

* DEPNotify.app: `/Applications/Utilities/DEPNotify.app`
* Configuration and Control File: `/var/tmp/depnotify.log`
* Configuration plist: `/Users/username/Library/Preferences/menu.nomad.DEPNotify.plist`
* EULA and Registration responses: `/Users/Shared/UserInput.plist`
* Completion BOM file: `/var/tmp/com.depnotify.provisioning.done`
* Restart BOM file: `/var/tmp/com.depnotify.provisioning.restart`
* EULA BOM file: `/var/tmp/com.depnotify.agreement.done`
* Registration BOM file: `/var/tmp/com.depnotify.registration.done`
* EULA text file: `/Users/Shared/eula.txt`

# Commands

DEPNotify responds to a number of commands. All are prefaced with `Command:` and then the verb. Most are then followed by some text or other attribute.

## Main Window Configuration

Below are commands that will modify the main window properties, text, or associated images.

#### Image:
This will replace the very fancy DEPNotify logo, created by Erik Gomez, with a very fancy image of your own. Note that DEPNotify should scale the image up or down to fit the space.

*Example:* `Command: Image: /tmp/logo.png`

#### KillCommandFile:
This command will tell DEPNotify to remove the command file from the filesystem when DEPNotify is quit. Keep in mind file permissions to ensure that the file can actually be removed by DEPNotify.

*Example:* `Command: KillCommandFile:`

#### MainText:
This command will change the main body of text in the application.

*Example:* `Command: MainText: Something about how amazing the DEP process you've created is.`
*Example w/ New Lines:* `Command: MainText: Something about how amazing the DEP process you've created is. \n \n It really is amazing.`

#### MainTextImage:
This command will change the main body to an icon of your choosing

*Example:* `Command: MainTextImage: /tmp/logo.png`

#### MainTitle:
This command will change the main title of text in the application.

*Example:* `Command: MainTitle: Something about how amazing the DEP process you've created is.`

#### Video:
Plays a video from a stream or local source. DEPNotify automatically detects if it’s a local or http video. (Video formats accepted .m4v, .mp4, .m3u8)

*Example:* `Command: Video: https://example.com/awesome_video.mp4`  
*Example:* `Command: Video: /var/tmp/awesome_video.mp4`

#### Website:
Loads a website in DEPNotify.

*Example:* `Command: Website: https://apple.com`

#### WindowStyle:
This command has a few modifiers to it:
    * `Activate` This will force the DEPNotify window to the front of all other windows.
    * `ActivateOnStep` This will force the window to the front for each new progress bar step, so that you don't have to issue the Activate command each time.
    * `NotMovable` This will center the DEPNotify window and make it unable to be moved.

*Example:* `Command: WindowStyle: NotMovable`

#### WindowTitle:
This will change the title of the DEPNotify window.

*Example:* `Command: WindowTitle: My Great DEP Notification App`

#### YouTube:
Plays a youtube video in DEPNotify.

*Example:* `Command: YouTube: <youtube_id_here>`

## Interaction

Below are commands allow for user interactions like EULA screen or registration screen. There are also commands for modifying the "progress" bar.

#### ContinueButtonRegister:
This places a Continue button at the bottom of the screen that that calls the Registration window. Creates a bom file `/var/tmp/com.depnotify.registration.done` on successful completion.

*Example:* `Command: ContinueButtonRegister: <Button Label>`

#### ContinueButtonEULA:
This places a Continue button at the bottom of the screen to display a URLA or other agreement you need the user to agree to. Creates a bom file `/var/tmp/com.depnotify.provisioning.done` on successful completion.

*Example:* `Command: ContinueButtonEULA: <Button Label>`

#### Determinate:
This makes the progress bar be determinate instead of just a spinny bar. You need to follow this with the number of stages you'd like to have in the bar. Once set, every status update that you send DEPNotify will increment the bar by one stage.

*Example:* `Command: Determinate: 5`

#### DeterminateManual:
This makes the progress bar be determinate instead of just a spinny bar. You need to follow this with the number of stages you'd like to have in the bar. Once set, you will need to manually tell DEPNotify when to update instead of relying on status updates or information from the various log files. This allows you to create a progress bar independent of status updates.

*Example:* `Command: DeterminateManual: 5`

#### DeterminateManualStep:
When in `DeterminateManual` mode this will advance the progress bar by one step, or by the number following the verb.

*Example:* `Command: DeterminateManualStep: 2`

#### DeterminateOff:
Disables a deterministic state for the progress bar. Note that the steps already occurred in the bar will remain, allowing you to move between a deterministic behavior and non-deterministic without loosing your place.

*Example:* `Command: DeterminateOff:`

#### DeterminateOffReset:
After turning off the deterministic state of the progress bar, you need to reset it the count to 0.

*Example:* `Command: DeterminateOffReset:`

## Notification

Below are commands for dropdown alerts and notification center alerts for end users.

#### Alert:
This creates an alert sheet on the DEPNotify window with an "Ok" button to allow the user to clear the alert. The text that follows the `Alert:` will be the contents to the alert.

*Example:* `Command: Alert: The installation is now finished`

#### Notification:
This will issue a notification to the Mac's notification center and display it.

*Example:* `Command: Notification: Please look at this notification.`

#### NotificationImage:
This sets an image to use for the user notifications. Keep in mind that this may not be what you are looking for. After setting this notifications will still have the DEP Notify icon in them, but will also have the image set with this command.

*Example:* `Command: NotificationImage: /tmp/image.png`

#### NotificationOn:
This will cause all status updates to be sent to the Notification Center as well. It takes no modifiers.

*Example:* `Command: NotificationOn:`

## Completion

Below are commands that can be used to quit, logout, or restart the Mac after workflows are completed.

#### ContinueButton:
This places a Continue button at the bottom of the screen that quits DEPNotify. Creates a bom file `/var/tmp/com.depnotify.provisioning.done` on successful completion.

*Example:* `Command: ContinueButton: <Button Label>`

#### ContinueButtonLogout:
This places a Continue button at the bottom of the screen that will perform a logout of the Mac. Creates a bom file `/var/tmp/com.depnotify.provisioning.done` on successful completion.

*Example:* `Command: ContinueButtonLogout: <Button Label>`

#### ContinueButtonRestart:
This places a Continue button at the bottom of the screen that will perform a soft restart of the Mac. Creates a bom file `/var/tmp/com.depnotify.provisioning.restart` on successful completion.

*Example:* `Command: ContinueButtonRestart: <Button Label>`

#### Logout:
This will show a sheet dialog and then log the user out when the "Logout" is clicked. This is commonly used to log the user out and initiate a FileVault encryption process.

*Example:* `Command: Logout: Please logout now to start disk encryption.`

#### LogoutNow:
Executes an immediate logout of the user session without waiting until the user responds to the alert  

*Example:* `Command: LogoutNow:`

#### Quit
The first of two ways to quit DEPNotify. This option takes no modifiers and will immediately quit the application. Note there is no `:` on this command.

*Example:* `Command: Quit`

#### Quit:
The second way to quit the application. This method will allow you to show a dialog with text of your choosing. The user will then be able to dismiss the dialog to quit the application.

*Example:* `Command: Quit: Thanks for using this app.`

#### QuitKey:
This will change the default key to quit DEPNotify. By default this is the "x" key with the command and control keys held down. Settign `QuitKey:` allows you to change "x" to any other single character. Note: you are unable to modify the requirement for the command and control keys.

*Example:* `Command: QuitKey: j`

#### Restart:
This will cause the machine to begin the restart process. The user will get a notification to accept with the text following the command.

*Example:* `Command: Restart: Your session will end now.`

#### Restartnow:
This will cause a restart event without requiring the user to accept.

*Example:* `Command: RestartNow:`

## Deprecated Commands

Below commands have been removed from the product as newer methods have been added.

#### Help: (deprecated)

*This command was removed in version X.X.X and changed to a help bubble that is configured by plist.*

This will show a help button in the lower right corner of the DEPNotify window. Pressing the button will open up the path that you specify. Note that this can be both web URLs, such as http://www.apple.com/support, or file paths to local files such as file:///Applications/Chess.app.

*Example:* `Command: Help: http://www.apple.com/support`

# Status Updates

This are very simple. Just echo set `Status:` followed by the text of your status. If you've set `NotificationOn:` the status will also be sent as a notification. Also, if you have `Determinate:` set, each time you send a status the process bar will increment by one.

*Example:* `Status: Reticulating splines...`

# DEPNotify Plist

For more functionality and advanced workflows, additional options are slowly being added into the `menu.nomad.DEPNotify.plist`. This file is able to configure various things like EULA window, registration window, status text alignment, and help bubbles.

## Main Window Configuration

Main window configurations modify the look, feel, and some of the underlying locations of files.

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| statusTextAlignment | String | Sets the main screen status text alignment under the progress bar. Can be left, center or right | defaults write menu.nomad.DEPNotify	statusTextAlignment left |
| helpBubbleTitle | String | Sets the main screen help bubble title | defaults write menu.nomad.DEPNotify helpBubbleTitle "My Title" |
| helpBubbleBody | String | Sets the main screen help bubble body text | defaults write menu.nomad.DEPNotify helpBubbleBody "Here is how can I help you" |
| pathToPlistFile | String | Sets the UserInput.plist file location. This file is used for responses from EULA and registration windows | defaults write menu.nomad.DEPNotify pathToPlistFile "/My/Path/myplistfile.plist" |

## EULA Window Configuration

The EULA window adds a button the end user must press to activate a dropdown that the user can read and then accept some terms of agreement to use the computer.

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| EULAMainTitle | String | Sets EULA main title | defaults write menu.nomad.DEPNotify EULAMainTitle "End User Level Agreement" |
| EULASubTitle | String | Sets EULA sub title | defaults write menu.nomad.DEPNotify EULASubTitle "Agree to the following terms and conditions to start using this Mac." |
| pathToEULA | String | Set the path to the EULA text file | defaults write menu.nomad.DEPNotify pathToEULA "/Users/Shared/eula.txt" |
| quitSuccessiveEULA | Boolean | Allows DEPNotify to quit upon agreeing to the EULA | defaults write menu.nomad.DEPNotify quitSuccessiveEULA -bool true |

## Registration Window Configuration

Registration window adds a button the end user must press to activate a dropdown that will allow the user to fill in associated data about themselves, the computer, use case for computer, or any other idea you have. A sensitive data box is enabled by default that allow the user to self identify if there is client or other types of secured data on the device.

#### General Settings

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| registrationMainTitle | String | Sets registration main title | defaults write menu.nomad.DEPNotify registrationMainTitle "Please register your Mac" |
| registrationPicturePath | String | Sets custom image shown on page | defaults write menu.nomad.DEPNotify	registrationPicturePath "/Path/to/picture.jpg" |
| registrationButtonLabel | String | Sets button label name | defaults write menu.nomad.DEPNotify registrationButtonLabel "Registration" |

#### Text Field 1

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| textField1Label | String | Enables text input 1 and sets custom label | defaults write menu.nomad.DEPNotify	textField1Label "Full name" |
| textField1Placeholder | String | Enables text input 1 text placeholder | defaults write menu.nomad.DEPNotify	 textField1Placeholder "Placeholder" |
| textField1IsOptional | Boolean | User can leave text input 1 text field empty | defaults write menu.nomad.DEPNotify	textField1IsOptional -bool true |
| textField1Bubble | Array | Enables text input 1 information bubble and sets custom content | defaults write menu.nomad.DEPNotify	textField1Bubble -array "Title" "Informative text" |

#### Text Field 2

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| textField2Label | String | Enables text input 2 and sets custom label | defaults write menu.nomad.DEPNotify	textField2Label "Full name" |
| textField2Placeholder | String | Enables text input 2 text placeholder | defaults write menu.nomad.DEPNotify	 textField2Placeholder "Placeholder" |
| textField2IsOptional | Boolean | User can leave text input 2 text field empty | defaults write menu.nomad.DEPNotify	textField2IsOptional -bool true |
| textField2Bubble | Array | Enables text input 2 information bubble and sets custom content | defaults write menu.nomad.DEPNotify	textField2Bubble -array "Title" "Informative text" |

#### Popup Menu 1

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| popupButton1Label | String | Enables popup button 1 and sets custom label | defaults write menu.nomad.DEPNotify	popupButton1Label "Region" |
| popupButton1Content | Array | Contents of the popup menu 1 | defaults write menu.nomad.DEPNotify popupButton1Content -array "US" "APAC" "Europe" "Americas" |
| popupMenu1Bubble | Array | Enables popup menu 1 information bubble and sets custom content | defaults write menu.nomad.DEPNotify	popupMenu1Bubble -array "Title" "Informative text" |

#### Popup Menu 2

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| popupButton2Label | String | Enables popup button 2 and sets custom label | defaults write menu.nomad.DEPNotify	popupButton2Label "Region" |
| popupButton2Content | Array | Contents of the popup menu 2 | defaults write menu.nomad.DEPNotify popupButton2Content -array "US" "APAC" "Europe" "Americas" |
| popupMenu2Bubble | Array | Enables popup menu 2 information bubble and sets custom content | defaults write menu.nomad.DEPNotify	popupMenu2Bubble -array "Title" "Informative text" |

#### Popup Menu 3

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| popupButton3Label | String | Enables popup button 3 and sets custom label | defaults write menu.nomad.DEPNotify	popupButton3Label "Region" |
| popupButton3Content | Array | Contents of the popup menu 3 | defaults write menu.nomad.DEPNotify popupButton3Content -array "US" "APAC" "Europe" "Americas" |
| popupMenu3Bubble | Array | Enables popup menu 3 information bubble and sets custom content | defaults write menu.nomad.DEPNotify	popupMenu3Bubble -array "Title" "Informative text" |

#### Popup Menu 4

| Key | Type | Description | Example |
| --- | ---- | ----------- | ------- |
| popupButton4Label | String | Enables popup button 4 and sets custom label | defaults write menu.nomad.DEPNotify	popupButton4Label "Region" |
| popupButton4Content | Array | Contents of the popup menu 4 | defaults write menu.nomad.DEPNotify popupButton4Content -array "US" "APAC" "Europe" "Americas" |
| popupMenu4Bubble | Array | Enables popup menu 4 information bubble and sets custom content | defaults write menu.nomad.DEPNotify	popupMenu4Bubble -array "Title" "Informative text" |

# Workflow

While every DEP workflow is different, here's a simple method of using DEPNotify with a DEP process.

* Install DEPNotify as early on as possible during your DEP process
* Install a default command file if you'd like, DEPNotify will read an existing command file at the location you specify and then do those actions all at once. This is helpful for setting the logo and the text.
* Launch DEPNotify. When scripting the opening of DEPNotify, best practice is to use `sudo -u $currentUser open -a /path/to/DEPNotify.app --args -flags`
* As you complete actions for the user write the status updates, or other changes, to the command file. `echo "Command: Quit: The process is now complete." >> /var/tmp/depnotify.log` is one example of doing this.
* Quit DEPNotify when you're done either with `Quit` or `Quit:`
* Remove DEPNotify

# Advanced Workflows

* **Using Filewave argument `-filewave`**
This has DEP Notify read in the Filewave log at /var/log/fwcld.log and then update the status line in the DEPNotify window with any downloads, installs or complete installs from the Filewave log. Progress bar will move depending on how many installs or filesets being deployed. Note there is nothing special you need to name your items in Filewave for them to be read.

* Create LaunchAgent to open DEPNotify with argument `-filewave` (stage1)
* Create LaunchDaemon and script watching for the DEPNotify process to start.
* When the DEPNotify process starts, curl down the Filewave client and install. -create script (stage1)
* **Recommended** - Energy saver profile - Mac’s sleep in 15min out of box, disrupting the DEP process. (stage1)

# Changelog

See [CHANGELOG.md](./CHANGELOG.md)

# Notes

* The application is written entirely in Swift of the course of a few weeks. It should be fairly easy for anyone with basic to moderate knowledge of Swift to enhance this as you see fit.
* DEPNotify was specifically designed to show some notifications to a user while the DEP process completes. The goal was to not block the user from experiencing their new machine. If you would like a more elaborate process, please look at projects like SplashBuddy.
* Comments and feature requests about additional functionality are welcome.
* For information, help and otherwise good times, feel more than welcome to visit the #depnotify channel on the MacAdmins Slack, http://macadmins.slack.com
