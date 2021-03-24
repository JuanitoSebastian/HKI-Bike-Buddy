#  Architecture
## Structure
HKI Bike Buddy is built using the model-view-viewmodel (MVVM) design pattern. In MVVM the business logic and data (model) is abstracted by the viewmodel which offers public properties and actions for the view. The views are used to build the actual user interfaces.

![ArchitectureDiagram](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/ArchitectureGraph.png)

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

The UI is built almost entirely using SwiftUI. UiKit was used on one view where MapKit was needed (MapView). Navigation between the views of the application is done using the SwiftUI components NavigationView and TabView which are contained in ``ContentView.swift``.

## Models
There are two types of bike rental stations in the application: favourite stations and non-favourite stations. [Core Data](https://developer.apple.com/documentation/coredata) is used for persistance storage of objects. Core Data is an object graph management and persistance framework made by Apple. In HKI Bike Buddy it is used to save stations on the device so that the users favourite stations can be recalled after the application has been closed. Core Data abstracts the actual management of a database making it easier to persistently save objects. This is why the data model of the application consists of two bike rental station classes: ManagedBikeRentalStation and UnmanagedBikeRentalStation. ManagedBikeRentalStation class has been generated using the ``HelsinkiBikeBuddy.xcdatamodeld`` and is a subclass of NSManagedObject (required for an object to be saved using Core Data). All bike rental stations start out as UnmanagedBikeRentalStations. When the user favourites a station it is converted into a ManagedBikeRentalStation object (and is saved on the device). When a station is un-favourited it is converted back to a UnmanagedBikeRentalStation (and so removed from persistent storage).

![ModelsDiagram](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/ModelsDiagram.png)

Both ManagedBikeRentalStation and UnmanagedBikeRentalStation classes conform to the RentalStation protocol. This makes it possible to work interchangeably with both types of bike rental stations and not having to write class specific implementations. Some fruther information about the variables and functions:
*  ``fetched`` is Date object containing the information of when the data of the station was last updated with from the API
*  ``distance(to location: CLLocation): CLLocationDistance`` returns the distance between the RentalStation and the CLLocation object given as parameter. This is used to sort the RentalStations from nearest to furthest from the user.
