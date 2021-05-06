# 🧪 Testing
HKI Bike Buddy features automated unit and integration testing on the business logic. System testing is done manually in the simulator and in real use case scenarios with an iPhone 12 Pro Max and an iPhone X.
## Automated tests
The application features automated unit tests which can be found in the [LogicTests](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/tree/main/LogicTests) folder. 
The tests can be run in Xcode by pressing ⌘ + U.
### Testing Asynchronous Operations
Testing of async functions (such as Combine publishers) is performed using the [XCTestExpectation](https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations/testing_asynchronous_operations_with_expectations) class. XCTestExpectation allows us to monitor if an asynchronous task succeeds or fails. 
``` swift
let expectation = self.expectation(description: "Awaiting publisher")
_ = store.bikeRentalStationIds.sink { receivedValue in
    if receivedValue.contains("094") {
        expectation.fulfill() // The right value was found, we can fulfill expectations
    }
}
waitForExpectations(timeout: timeout) // Wait for expectation
```
### Determining if tests are running
To test some of the applications functionalities we need to be able to determine if the app is being run in testing mode. When the app is being tested it is run with a  ``-isTest`` flag. This lets the application know that tests are performed. 
This is needed in the testing of [UserLocationServices](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/blob/main/HKIBikeBuddy/services/UserLocationService.swift). UserLocationServices provide a CLLocation object which contains the current coordinate data of the device. When the application is in normal operation we are not able to edit this object. During testing it is necessary to be able to change the location data so we can see that the application reacts to the changes correctly. 
### Testing the store
The saving and loading of data is also tested. During testing the data is written to a separate test file.
### Test coverage
Currently only the business logic of application is tested and the test coverage is at 67.88% percent.
![TestCoverageReport](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/TestCov.png)
