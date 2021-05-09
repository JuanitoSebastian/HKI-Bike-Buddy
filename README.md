# HKI Bike Buddy
![HKIBikeBuddy](https://raw.githubusercontent.com/JuanitoSebastian/HKI-Bike-Buddy/main/Documentation/graphics/ReadMeHeader.png)
HKI Bike buddy is an iOS app for viewing real-time information of city bike stations in Helsinki, Espoo and Vantaa. Instead of having to search a map to find the nearest bike rental stations HKI Bike Buddy shows the stations as a list ordered from closest to furthest from your current location. Bike rental stations can be favourited for easy access and favourite stations can be placed on the home screen as widgets.

## Structure
- 🗂 **HKIBikeBuddy.xcodeproj**: Xcode project
- 🗂 **HKIBikeBuddy**: Main application code
- 🗂 **UnitTests**: Unit tests for the app
- 🗂 **Documentation**: Project documentation
- 🗂 **Widget**: Widget implementation
- 🗂 **Intention**: [Intents](https://developer.apple.com/design/human-interface-guidelines/siri/overview/custom-intents/) implementation (required for customizable widget)

## Documentation
[🏛 Architecture](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/blob/main/Documentation/Architecture.md)\
[🧪 Testing](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/blob/main/Documentation/Testing.md)\
[📱 User guide](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/blob/main/Documentation/UserGuide.md)\
[⏱ Project report](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/blob/main/Documentation/ProjectReport.md)

## Installation
HKI Bike Buddy will be available in the App Store at latest July 2021.

### Requirements
The application can be run on iPhones with iOS 13 or later.

### Accessing project in the development environment
If you are interested in exploring this project you are going to need:
1. A macOS computer
2. Xcode 11 or a later release
3. An Apple ID

### Installation & running the app
1. Download the latest [release](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/releases) or clone the repository:
```
git clone https://github.com/JuanitoSebastian/HKI-Bike-Buddy.git
```
2. Open HelsinkiBikeBuddy.xcodeproj to access the Xcode workspace
3. To build the project you have to [login with your Apple ID to sign the build](https://help.apple.com/xcode/mac/current/#/dev23aab79b4).
4. Build and run the project with ``⌘ + R``

If you do not have SwiftLint installed [remove Swiftlint from the build phases of the *HKIBikeBuddy* target](https://raw.githubusercontent.com/JuanitoSebastian/HKI-Bike-Buddy/main/Documentation/graphics/SwiftlintBuildPhase.png).

### Testing
Open HelsinkiBikeBuddy.xcodeproj to access the Xcode workspace and run the tests by pressing ``⌘ + U``
