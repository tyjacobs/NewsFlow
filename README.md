# NewsFlow
Basic RSS Reader written by Ty Jacobs in Swift 2 using XCode 7.1.1

This app was developed to meet the requirements for a "Code Exercise: RSS Feed Reader" by A&F in Nov 2015.

The app uses CocoaPods, specifically ReachabilitySwift and Alamofire


Beyond the basic requirements, I did the following:
1. The app works on all sizes/shapes of iOS devices
2. App branding: app name, cool icon, color scheme, launch screen, navigation bar graphics
3. Clever alternating row colors with subtle curve to match the branding
4. Pull-down-to-reload gesture
5. Local persistence using Core Data
6. App retains all stories and not just most recent ones
7. Swipe left then tap Delete to permanently remove a story from the list


As of Nov 22 2015 the app is still missing a few of the requirements
1. Display of DETAIL view when offline
2. Text displayed in the main table view needs processing to handle encoded characters such as &#39; (apostrophe)
3. After using the app, I also realize a nice feature would be to highlight new ("fresh") items after a manual refresh