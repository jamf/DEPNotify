# [1.0.4] - unreleased

Please see the [README] for usage.

**Changed:**

* Redesigned EULA
* Logo is now 2:1 ratio instead of previous 1:1 ratio
* Done dotfile has been moved
  * Previous path: `/Users/Shared/.DEPNotifyDone`
  * New path: `/var/tmp/com.depnotify.provisioning.done`
* `ContinueButtonAgreement` has been replaced with `ContinueButtonEULA`
* Logout commands now use a more forceful API - @clburlison [!11]

**Added:**

* "ContinueButtonRegister:" -@fgd
* "ContinueButtonEULA:" this replaces "ContinueButtonAgreement" - @fgd
* "ContinueButtonRestart" - @fgd
* "ContinueButtonLogout" - @fgd
* New registration window for user input - @fgd

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
