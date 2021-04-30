# 🏛 Architecture 
## Structure
HKI Bike Buddy is built using SwiftU. The apps global state is contained in an instance of the class [AppState](https://github.com/JuanitoSebastian/HelsinkiBikeBuddy/blob/main/HKIBikeBuddy/state/AppState.swift) which is injected using the [@EnvironmentObject](https://developer.apple.com/documentation/swiftui/environmentobject) property wrapper in the root view of the application. All of the data presented in the UI and all of the user actions are handled by the AppState. AppState makes the necessary requests to services and handles interaction with Bike Rental Station objects in the store.

![ArchitectureDiagram](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/ArchitectureGraph.png)

**The main application code is divided into the following groups:**
* state: Contains the AppState
* stores: Handles storing the state of the app
* services: Handles fetching data from the [Routing API](https://digitransit.fi/en/developers/apis/1-routing-api/) and management of user location.
* views: Contains the views of the UI
* extensions: Extensions to existing classes and structs
* utils: Utilities (Logging, Haptics...)

## User Interface
![ArchitectureUiViews](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/ArchitectureUiViews.png)
### The UI of the application consists of the following views:
1. Welcome screen featuring a prompt asking the user to enable location services.
2. Main view featuring a list of bike rental stations and a tab bar. User can change between nearby stations and favourite stations from the tab bar.
3. Detailed view of a bike rental station featuring a map showing the location of the user relative to the location of the bike rental station.
4. Settings view where the maximum distance for bike rental stations to be considered nearby can be changed.

Each of these views are their own struct which conforms to the [View protocol](https://developer.apple.com/documentation/swiftui/view). Many of these views have been divided into further useful sub-views (such as [Card](https://github.com/JuanitoSebastian/HelsinkiBikeBuddy/blob/main/HKIBikeBuddy/views/components/Card.swift) and [CapacityBar](https://github.com/JuanitoSebastian/HelsinkiBikeBuddy/blob/main/HKIBikeBuddy/views/components/CapacityBar.swift)) enabling easy reuse of UI components. Navigation between the views of the application is done using the SwiftUIs NavigationView and TabView which are contained in ``MainRentalStationsView.swift``.

The state of the application and content in the views are kept in sync using the [Combine framework](https://developer.apple.com/documentation/combine). AppState conforms to the [ObservableObject](https://developer.apple.com/documentation/combine/observableobject) protocol enabling us to mark its variables with the @Published property wrapper. Views can then subscribe to these ObservedObjects and when @Published properties are updated the views get a notification that a value has changed and a re-render of the view is triggered.

UiKit is used on only one view where MapKit is needed (MapView). 

## Models
### Bike Rental Station
<p align="center">
<img src="https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/BikeRentalStation.png">
</p>

Information about a city bike stations current state is stored in a Bike Rental Station object. Creation of new BikeRentalStation objects is handled by BikeRentalStationApiService which fetches stations from Routing API. BikeRentalStationStore in turn handles marking stations as favourites and the persistent storage of station objects. BikeRentalStations conform to the [Codable](https://developer.apple.com/documentation/swift/codable) protocol. This makes it possible to encode them into JSON objects (enables saving them persistently into a file) and makes it easy to convert the RoutingAPI responses into BikeRentalStation objects.

Some fruther information about the variables and functions:
*  ``fetched`` is Date object containing the information of when the data of the station was last updated with from the API
*  ``distance(to location: CLLocation): CLLocationDistance`` returns the distance between the BikeRentalStations location and the CLLocation object given as parameter. This is used to sort the BikeRentalStations from nearest to furthest from the user.

## Storage
BikeRentalStations are stored in the BikeRentalStationStore class. This class is accessed via a [singleton](https://en.wikipedia.org/wiki/Singleton_pattern) instance. BikeRentalStation objects are stored in a `[String: BikeRentalStation]` dictionary where the stationIds work as keys. In addition to the dictionary the stationIds are stored in a `[String]` array which is wrapped in a [CurrentValueSubject](https://developer.apple.com/documentation/combine/currentvaluesubject). This enables the AppState to listen for changes in the array containing the stationIds. Whenever new station objects are inserted into the dictionary the array is updated. This way the AppState knows when to re-render the main rental stations view so that it includes the new stations.

### Persistence
BikeRentalStationStore persistently stores the favourite stations. BikeRentalStation objects are encoded to JSON objects and saved into a `.data` file. The BikeRentalStations are loaded into from the file when the application is first opened. The contents of the file are updated whenever the application is moved to the background or closed. Below is an example of how the BikeRentalStations are encoded and saved.
```
[
    {
        "spacesAvailable":16,
        "state":true,
        "fetched":640609384.62917197,
        "favourite":true,
        "lon":24.992037110168354,
        "bikesAvailable":4,
        "allowDropoff":true,
        "lat":60.181861779166056,
        "stationId":"243",
        "name":"Mustikkamaa"
    }
]
```

