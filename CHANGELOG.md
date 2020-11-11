# [1.1.6] - Nov 11, 2020

**Fixed:**
* Issue where DEP Notify could crash after enabling FileVault.

**Added:**
* Added support for Apple Silicon systems. DEP Notify is now a fat binary.

# [1.1.5] - Oct 5, 2019

**Fixed:**
* Fixed issue with uncentered window on macOS Catalina
* Fixed regex pattern 2 which was not working correctly

**Added:**
* Hardened runtime
* Notarization of the package
* Swift 5

# [1.1.4] - Jan 14, 2019

**Added:**
* copy and paste text functions

# [1.1.3] - Nov 27, 2018

**Changed:**
* Jamf log doesn't show Alert window when FileVault is enabled -@fgd (Do we want to keep this change? -clayton)
* Redesigned the Registration Window -@fgd
* DEPNotify now displays a popup bubble when clicking the help button -@fgd
* Removed Cancel button in the EULA window. Now the users HAS to click the Action button. -@fgd
* Registration Window - Text input comliance indicator lights now appear inside the text input field -@fgd
* Registration Window - Text input comliance indicator lights now disappear when user starts typing -@fgd
* Most Registration window defaults keys have been changed to reflect new additions -@fgd
* User input plist file. When customizing the User Input plist path you now have to include a name for the plist file

**Fixed:**
* "Logout:" Displaying a logout alert no longer displays the EULA window afterwards -@fgd
* "Quit:" Displaying a Quit alert no longer displays the EULA window afterwards -@fgd
* Dark Mode now works in Registration and EULA views, and help Bubble -@fgd

**Added:**
* "Video:" plays a video from a stream or local source. DEPNotify automatically detects if it’s a local or http video. (Video formats accepted .m4v, .mp4, .m3u8) Video Size is 700px x 328px -@fgd
* "YouTube" plays a youtube video in DEPNotify. Video Size is 700px x 328px -@fgd
* "Website" loads a webpage in DEPNotify. Size is 700px x 328px -@fgd
* Add "LastRegistrationDate" key to DEPNotify.plist -@fgd
* Add "com.depnotify.provisioning.logout" bom file on logout action (Button) -@fgd
* Add "com.depnotify.provisioning.restart" bom file on restart action (Button) -@fgd
* Add "com.depnotify.provisioning.done" bom file on Quit (Button) -@fgd
* Add "com.depnotify.registration.done" bom file after Registration action -@fgd
* Add "com.depnotify.agreement.done" bom file after EULA action -@fgd
* Clicking the help button on the main screen now displays a popup window with customizable Title and Content -@fgd
* Registration Window -@fgd
    * Added two more popup menus for a total of 2 text fields and 4 popups
    * Added optional informative popup bubles to each user input option
    * Checking the Sensitive Information checkbox displays a popup window with several security and privacy compliance options
    * Added 6 new keys file for security and data compliance to the user input plist
* Status text can now be aligned to either right, center or left -@fgd

# [1.1.0] - May 19, 2018

**Changed:**

* Redesigned EULA
* Logo images will now resize up or down proportionally as necessary
  * The log image is now a banner too, 660x105 so if you want to fill the top
* Done dotfile has been moved
  * Previous path: `/Users/Shared/.DEPNotifyDone`
  * New path: `/var/tmp/com.depnotify.provisioning.done`
* `ContinueButtonAgreement` has been replaced with `ContinueButtonEULA`
* Logout commands now uses a more forceful API - @clburlison [#11]
* If you cancel the EULA the continue button gets re-enabled so the user can go back to the EULA
* When using setting a MainTextImage, we hide MainText, MainTitle, and Logo. Set MainText to reset the default view.

**Fixed:**

* The continue button now auto-resizes so you can have really long buttons
* EULA text is no longer editable if you had nothing in the field
* DeterminateManualStep should work as you think it should
* If using the -jamf option and enabling FileVault with jamf, DEPNotify will only show one alert screen
* MainImageText auto scales and allows for animation, 660x313 [#13]

**Added:**

* "ContinueButtonRegister:" -@fgd
* "ContinueButtonEULA:" this replaces "ContinueButtonAgreement" - @fgd
* "ContinueButtonRestart" - @fgd
* "ContinueButtonLogout" - @fgd
* New registration window for user input - @fgd
* A demo script is included to show off a few common action. DEPNotify/Sample Setup/SampleTest.sh
* "quitSuccessiveEULA" to allow DEPNotify to be closed after EULA agreement - @headmin

# [1.0.3] - November 28, 2017

* Add "DeterminateManual:" and "DeterminateManualStep:"
* "DeterminateOff:" and "DeterminateOffReset:"
* Support reading from Munki Log - @clburlison
* Support reading from FileWave Log - @DDeRusha/@Soxln4
* Add "KillCommandFile:"
* Add "MainTextImage:" and "MainTitle:" - @erikng/@fgd
* Even newer UI - @erikng/@fgd
* Full Screen Support
* Add "QuitKey:"
* Add EULA acceptance screen - @fgd
* Touch /Users/Shared/.DEPNotifyDone when finished - @fgd
* Create /Users/Shared/DEPNotify.plist when finished - @fgd
* Update to Swift 4

# [1.0.2] - September 18, 2017

* Updated UI to be larger and look more modern macOS - @erikng
* Jamf log now looks for "Executing"

# [1.0.1] - June 13, 2017

* Added "EnableJamf:"
* "LogoutNow:"
* "NotificationImage:"
* Window Styles "Activate" and "ActivateOnStep"
* "Restart:" and "RestartNow:"

# [1.0] - April 23, 2017

* Initial commit of DEPNotify

<!-- Links -->
[README]: https://gitlab.com/Mactroll/DEPNotify/blob/master/README.md
[1.0]: https://gitlab.com/Mactroll/DEPNotify/tags/version-1.0
[1.0.1]: https://gitlab.com/Mactroll/DEPNotify/tags/version-1.0.1
[1.0.2]: https://gitlab.com/Mactroll/DEPNotify/tags/1.0.2
[1.0.3]: https://gitlab.com/Mactroll/DEPNotify/tags/1.0.3
[1.0.4]: https://gitlab.com/Mactroll/DEPNotify/tags/1.0.4
[1.1.0]: https://gitlab.com/Mactroll/DEPNotify/tags/1.1.0
[1.2.0]: https://gitlab.com/Mactroll/DEPNotify/tags/1.2.0
