#  Architecture
## Structure
HKI Bike Buddy is built using SwiftUI and the Model-View-ViewModel design approach (since [MVVM is "built in" to SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/)). The apps global state is contained in an instance of the class AppState wihch is injected using the [@EnvironmentObject](https://developer.apple.com/documentation/swiftui/environmentobject) property wrapper in the root view of the application. All of the data presented in the UI and all of the user actions are handled by the AppState. AppState makes the necessary requests to services and handles delivering of Bike Rental Station objects from store.

![ArchitectureDiagram](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/ArchitectureGraph.png)

**The project is divided into the following groups:**
* stores: Handles storing the state of the app
* services: Handles fetching data from the [Routing API](https://digitransit.fi/en/developers/apis/1-routing-api/) and management of user location.
* views: Contains the views of the UI
* extensions: Extensions to existing classes and structs
* utils: Utilities

## User interface
**The UI of the application consists of the following views:**
* Welcome screen featuring a prompt asking the user to enable location services.
* Main view featuring a list of bike rental stations and a tab bar. User can change between nearby stations and favourite stations from the tab bar.
* A detailed view of a bike rental station featuring a map showing the location of the user relative to the location of the bike rental station.
* A settings view where the maximum distance for bike rental stations to be considered nearby can be changed.

UiKit was used on one view where MapKit was needed (MapView). Navigation between the views of the application is done using the SwiftUIs NavigationView and TabView which are contained in ``MainRentalStationsView.swift``.

## Models
Information about a city bike stations current state is stored in a Bike Rental Station object. Creation of new BikeRentalStation objects is handled by BikeRentalStationApiService which fetches stations from Routing API. BikeRentalStationStore in turn handles marking stations as favourites and the persistent storage of station objects.

![BikeRentalStationModel](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/BikeRentalStation.png)

Some fruther information about the variables and functions:
*  ``fetched`` is Date object containing the information of when the data of the station was last updated with from the API
*  ``distance(to location: CLLocation?): CLLocationDistance?`` returns the distance between the BikeRentalStations location and the CLLocation object given as parameter. This is used to sort the BikeRentalStations from nearest to furthest from the user.

## Storage
BikeRentalStations are stored in the BikeRentalStationStore class. This class is accessed via a [singleton](https://en.wikipedia.org/wiki/Singleton_pattern) instance.

### Persistence
```
[
    {
        "spaces":16,
        "state":true,
        "fetched":640609384.62917197,
        "favourite":true,
        "lon":24.992037110168354,
        "bikes":4,
        "allowDropoff":true,
        "lat":60.181861779166056,
        "stationId":"243",
        "name":"Mustikkamaa"
    }
]
```

