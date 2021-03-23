#  Architecture
## Structure
HKI Bike Buddy is built using the model-view-viewmodel (MVVM) design pattern. In MVVM the business logic and data (model) is abstracted by the viewmodel which offers public properties and actions for the view. The views are used to build the actual user interfaces.

![BikeBuddyScreen](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/ArchitectureGraph.png)

**The project is divided into the following groups:**
* stores: Rental Stations are stored here. Handles saving and fetching ManagedBikeRentalStation objects to/from Core Data.
* services: Handles fetching data from the Routing API, management of user location and user defaults.
* views: Contains the views of the UI
* viewmodels: Contains the viewmodels for views

## User interface
**The UI of the application consists of the following views:**
* Welcome screen featuring a prompt asking the user to enable location services.
* Main view featuring a list of bike rental stations and a tab bar. User can change between nearby stations and favourite stations from the tab bar.
* A detailed view of a bike rental station featuring a map showing the location of the user relative to the location of the bike rental station.
* A settings view where the maximum distance for bike rental stations to be considered nearby can be changed.

The UI is built almost entirely using SwiftUI. UiKit was used on one view where MapKit was needed (MapView). Navigation between the views of the application is done using the SwiftUI components NavigationView and TabView which are contained in *ContentView.swift*.
