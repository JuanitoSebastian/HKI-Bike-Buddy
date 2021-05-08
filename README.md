# HKI Bike Buddy
![HKIBikeBuddy](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/ReadMeHeader.png)
HKI Bike buddy is an iOS app for viewing real-time information of city bike stations in Helsinki, Espoo and Vantaa. Instead of having to search a map to find the nearest bike rental stations, this app shows the stations as a list ordered from closest to furthest from your current location Bike rental stations can be favourited for easy access and favourite stations can be placed on the home screen as widgets.

## Structure
- 🗂 **HKIBikeBuddy.xcodeproj**: Xcode project
- 🗂 **HKIBikeBuddy**: Main application code
- 🗂 **Documentation**: Project documentation
- 🗂 **LogicTests**: Unit tests for the app
- 🗂 **Widget**: Widget implementation
- 🗂 **Intention**: [Intents](https://developer.apple.com/design/human-interface-guidelines/siri/overview/custom-intents/) implementation (required for customizable widget)

## Documentation
[🏛 Architecture](https://github.com/JuanitoSebastian/HelsinkiBikeBuddy/blob/main/Documentation/Architecture.md)\
[🧪 Testing](https://github.com/JuanitoSebastian/HelsinkiBikeBuddy/blob/main/Documentation/Testing.md)\
[📱 User guide](https://github.com/JuanitoSebastian/HelsinkiBikeBuddy/blob/main/Documentation/UserGuide.md)\
[⏱ Project report](https://github.com/JuanitoSebastian/HelsinkiBikeBuddy/blob/main/Documentation/ProjectReport.md)

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
1. Clone the repository:
```
git clone https://github.com/JuanitoSebastian/HKI-Bike-Buddy.git
```
or download the latest [release](https://github.com/mluukkai/OtmTodoApp/releases)
2. Open HelsinkiBikeBuddy.xcodeproj to access the Xcode workspace
3. To build the project you have to [login with your Apple ID to sign the build](https://help.apple.com/xcode/mac/current/#/dev23aab79b4).
4. Build and run the project with ``⌘ + R``

### Testing
The tests can be run by pressing ``⌘ + U``
