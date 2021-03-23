#  Architecture
## Structure
HKI Bike Buddy is built using the model-view-viewmodel (MVVM) design pattern. In MVVM the business logic and data (model) is abstracted by the viewmodel which offers public properties and actions for the view. The views are used to build the actual user interfaces.

![BikeBuddyScreen](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/ArchitectureGraph.png)

**The project is divided into the following groups:**
* stores: Rental Stations are stored here. Handles saving and fetching ManagedBikeRentalStation objects to/from Core Data.
* services: Handles fetching data from the Routing API, management of user location and user defaults.
* views: Contains the views of the UI
* viewmodels: Contains the viewmodels for views
The user interface is built almost entirely using SwiftUI. UiKit was used on one view where MapKit was needed.
