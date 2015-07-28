# NewsFlow
Basic RSS Reader written by Ty Jacobs in Swift using XCode 6.4 (meaning, Swift 1.2 as opposed to Swift 2)

This app was developed to meet the requirements for a "Code Test" by A&F in July 2015.
I also used it to develop my skills in Swift after taking a class at CocoaConf 2015.

Beyond the basic requirements, I did the following:
1. The app works on all sizes/shapes of iOS devices
2. App branding: app name, cool icon, color scheme, launch screen, navigation bar graphics
3. Clever alternating row colors with subtle curve to match the branding
4. Pull-down-to-reload gesture
5. Local persistence using Core Data
6. App retains all stories and not just most recent ones


As of July 28 2015 the app is still missing a few of the requirements

1. Display of DETAIL view when offline (the main table view DOES display)
2. Tests (supposed to be TDD but I am adding after the fact)
3. Add an action to archive a story (not in requirements but I want to do it)