# DEPNotify

![DEPNotify Logo](https://gitlab.com/Mactroll/DEPNotify/raw/master/DEPNotify/Assets.xcassets/DEPNotify.imageset/depnotify_512.png)

DEPNotify is a small light weight notification app that was designed to let your users know what's going on during a DEP enrollment. The app is focused on being very simple to use and easy to deploy.

## Basic Usage

DEPNotify is completely controlled via echoing text to it's control file. By default this is `/var/tmp/depnotify.log` but you can change this to anything you want by launching the app with the `-v [some path]`.

The application then reacts to `Command:` and `Status:` lines written to the control file. 

##Commands
DEPNotify 