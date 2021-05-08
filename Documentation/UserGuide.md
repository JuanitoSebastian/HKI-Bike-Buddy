# 📱 User Guide
## Installation & running the app
1. Clone the repository:
```
git clone https://github.com/JuanitoSebastian/HKI-Bike-Buddy.git
```
2. Open HelsinkiBikeBuddy.xcodeproj to access the Xcode workspace
3. To build the project you have to [login with your Apple ID to sign the build](https://help.apple.com/xcode/mac/current/#/dev23aab79b4).
4. Build and run the project with ``⌘ + R``

### App Won't Start: Untrusted Developer?
When installing apps built in Xcode to an iPhone you might encounter and error stating that the developer is not trusted. This can be fixed by going to ``Settings`` > ``General`` > ``Device Management`` and marking the Apple ID you used to build the app as trusted.

## Launching The App
Launch the application by tapping the HKI Bike Buddy icon on the home screen of your device.
<p align="center">
<img src="https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/StartAndAuth.gif">
</p>

When the application is launched for first time it asks for your permission to use the location information of the device. 
- **Tap** the *Enable location services* button and authorize HKI Bike Buddy to use the location services of the system.


## Exploring Bike Rental Stations
<p align="center">
<img src="https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/DetailedFavourite.gif">
</p>

In the main view of the application you can explore the city bike stations around you. You can either view the stations nearest to you by choosing *Nearby Stations* from the tab bar or you can view the stations you have marked as favourites by choosing *My Stations*. The stations are sorted from nearest to furthest.
- **Long press** a station to view it on the map.
- **Swipe down** to exit the map view
- **Tap the heart** to mark a station as your favourite

## Settings
The settings of the application can be accessed by tapping the gear icon in the upper right corner of the main view. Here you can adjust the maximum distance between you and a bike rental station for it to be considered nearby. Edit the maximum distance by dragging the indicator on the slider. Changes to the settings are saved automatically.
- **Tap** the back button to exit the settings view
