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

## Main Operations of the App
Here are a few of the main actions of the application explained.

### Updating the Store with the API
The AppStates ``fetchFromApi()``method is called when the app first starts, when the app becomes active from the backround and when the user manually requests an update by pulling down the list of bike rental stations.
![ApiUpdateDiagram](https://raw.githubusercontent.com/JuanitoSebastian/HKI-Bike-Buddy/main/Documentation/graphics/UpdatingStationsWithAPI.png)
The AppState first check that the device is connected to the internet. If there is no internet connection an alert is displayed to the user and the fetch is not performed. Interaction between the AppState and BikeRentalStationAPI is done in a separate background thread so that waiting for the fetch to finish does not freeze the UI on the main thread. AppState first calls the ``fetchNearbyBikeRentalStations()`` function. This function requests bike rental station objects from the API that are nearest to the users current location. Once the stations are received they are inserted to the store. AppState then checks if there are stations in the store that were not updated by ``fetchNearbyBikeRentalStations()`` (these could be stations that are favourited by the user but are not currently nearby). These stations are then updated using the ``fetchBikeRentalStations()`` function. 
Updating the store features two asynchronous functions that have to be executed one after the other in the correct order. This is achieved using [DispatchSemaphores](https://developer.apple.com/documentation/dispatch/dispatchsemaphore).

### Marking a Station as Favourite
When users want to mark stations as favourites they tap the heart.

<p align="center">
<img src="https://raw.githubusercontent.com/JuanitoSebastian/HKI-Bike-Buddy/main/Documentation/graphics/FavouritingStation.png">
</p>

When the heart is tapped the UI first calls the [Haptics](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/blob/main/HKIBikeBuddy/utils/Haptics.swift) ``feedback()`` function to generate a light haptic nudge of the device. Then two methods of the AppState are called. First the ``markStationAsFavourite(_ bikeRentalStation: BikeRentalStation)`` function is called which simply sets the favourite value of a given bike rental station to true. Then the ``addStationToFavouritesList(_ bikeRentalStation: BikeRentalStation)`` function is called. This function inserts the given bike rental station object to the list of favourite stations (by calling the AppStates private function  ``insertStation``). The station is inserted to the list so that the list is kept in the right order (stations sorted from nearest to furthest from user). After the station object is inserted into the array of favourite stations a re-render of the view is triggered.

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
```json
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
## Dependencies
### Reachability
The application uses [Reachability.swift](https://github.com/ashleymills/Reachability.swift) for determining the current connectivity state of the device.
