# NewsFlow
Basic RSS Reader written by Ty Jacobs in Swift using XCode 6.4 (meaning, NOT Swift2)

This app was developed to meet the requirements for a "Code Test" by A&F in July 2015.

I also used it to develop my skills in Swift after taking a class at CocoaConf 2015.

The app runs on ANY size iOS device and works online or offline as specified in the requirements.  It does so by saving news stories in a simple Core Data database on the device.

As of July 28 2015 the app is still missing a few of the requirements

1. Display of DETAIL view when offline (the main table view DOES display)
2. Tests (supposed to be TDD but I am adding after the fact)
3. Some bells and whistles I want to add, beyond the requirements:
   A. Sorting of the stories so the newest ones are on top
   B. An action to archive a story (delete it from the list)
   C. More customized detail view