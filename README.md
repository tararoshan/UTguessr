# UTguessr
Mobile UT-themed Geoguessr app. iOS Mobile Computing group project.

**Important:** please use xCode version 15 to run the app (otherwise there may be issues with loading color assets).

## Contributions

Alex Lu (Release: 25%, Overall: 25%)
 - added MapKit to gameplay (with Teresa)
 - scroll view embedded in view (with Teresa)
 - added images to gameplay (with Teresa)
 - added the map annotation (with Teresa)
 - added gameplay functionality (with Game class) (with Teresa)
 - populated Firebase storage for images
 - upload images to firebase storage (for final)
 - cache DB images and download changes in DB (for final, done in LoadingScreenVC)

Teresa Luo (Release: 25%, Overall: 25%)
 - added MapKit to gameplay (with Alex)
 - scroll view embedded in view (with Alex)
 - added images to gameplay (with Alex)
 - added the map annotation (with Alex)
 - added gameplay functionality (with Game class) (with Alex)
 - stored images and locations in Core Data
 - populated leaderboards page (global highscores)
 - upload images to firestore (will shift to firebase storage for final)
 - upload usernames & profile pictures to firestore
 - calculating user scores & adding to DB
 - show running tally of scores at the end of the round
 - added top contributor badge

Tara Roshan (Release: 25%, Overall: 25%)
 - added the loading screen
 - added the app icon
 - created the tab bar controller
 - created the main menu and its segues to different pages
 - added placeholders for tab controller's profile, leaderboard, settings
 - modal popup asking if the user wanted to quit the game
 - allow user to set profile picture
 - allow user to set username

Megan Sickler (Release: 25%, Overall: 25%)
 - added the signup screen
 - added the login screen
 - created our Firebase database
 - added Firebase authentication to the application
 - added sounds to upload photo button & pin placement, etc
 - added dark mode theme
 - added toggles for sound effects & theme

## Deviations
 - completed all of our checkpoints for beta, but we have bugs
    - button sound effects play *after*, not during, button press (lag time)
    - modal popup still shows up when a round finishes
    - synchronization issues & caching the profile page
    - sign-out feature
    - error checking for sign-up: if no text entered, app crashes
