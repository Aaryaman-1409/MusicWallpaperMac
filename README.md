# MusicWallpaperMac
A menu-bar app that automatically changes the desktop wallpaper based on the cover art of the current Apple Music song. Uses k-means clustering to find the most dominant color in the cover art and uses this info to generate an aestheically pleasing wallpaper. See screenshots below for examples. Once the app is running, changing songs on Apple Music should change the desktop wallpaper accordingly within 1-2 seconds. 

Note: The app returns to an included default wallpaper if the Music App is quit. To change the default wallpaper, right click the app, click on 'Show Package Contents' and go to Contents/Resources. Here you can replace the defaultWallpaper.jpg with your wallpaper of choice. Make sure that the file is named to 'defaultWallpaper.jpg'.

# Installation: 
Simply download and extract the MusicWallpaper.app.zip file from releases. The MusicWallpaper.app file within can then be opened like any other app.

**Before opening, read the notes below:**

Upon running, you may be prompted by the alert that the app is damaged. This is because I can't pay for the $99 developer license from Apple, and so my app isn't notarized by them. There are two ways to get around this.

1. When opening the app for the first time, right-click the app, then hold option and press open instead of double tapping to open
2. Enter the command: xattr -d com.apple.quarantine "/path/to/.app" in your terminal. 

After the app opens succesfully, these steps are not required anymore, and the app can be opened normally. 

You can also build from scratch in case you don't want to do these steps. For the Swift version, just clone the SwiftVersion folder and open the 
.xcodeproj file in Xcode. From there, you can build the app normally. 

Building or using the python version is not recommended since the resulting app is much larger and lacks a few of the Swift version's features. However, there might be reasons the python version might be desired, e.g. 
not needing xcode to build. For the python version, building details are in the readme in the Python Version folder. 

# Usage: 
After clicking on the app, a violin icon 🎷 should appear in the menu bar. This indicates that the program is running. Changing the track on Apple Music shoud change the desktop wallpaper within 1-2 seconds. Click on the violin icon and press 'Quit' to stop the program.

# Screenshots: 
<img width="1440" alt="Screen Shot 2022-06-04 at 2 53 00 AM" src="https://user-images.githubusercontent.com/59561784/171972526-a5b0801f-7e4d-41a4-95c2-338c6dce9400.png">

<img width="1440" alt="Screen Shot 2022-06-04 at 2 52 43 AM" src="https://user-images.githubusercontent.com/59561784/171972621-117c9b93-827d-4ecf-a707-dfefd1de21a0.png">

<img width="1440" alt="Screen Shot 2022-06-04 at 2 52 10 AM" src="https://user-images.githubusercontent.com/59561784/171972631-dc8e835c-3ec4-4405-845a-4d14b4af5c06.png">
