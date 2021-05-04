# 🧪 Testing
HKI Bike Buddy features automated unit and integration testing on the business logic. System testing is done manually in the simulator and in real use case scenarios with an iPhone 12 Pro Max and an iPhone X.
## Automated tests
The application features automated unit tests which can be found in the [LogicTests](https://github.com/JuanitoSebastian/HKI-Bike-Buddy/tree/main/LogicTests) folder. 
The tests can be run in Xcode by pressing ⌘ + U.
### Testing Combine publishers
Testing of publishers is done using the [XCTestExpectation class](https://developer.apple.com/documentation/xctest/asynchronous_tests_and_expectations/testing_asynchronous_operations_with_expectations). XCTestExpectation allows us to monitor if an asynchronous task succeeds or fails. 
``` swift
let expectation = self.expectation(description: "Awaiting publisher")
_ = store.bikeRentalStationIds.sink { receivedValue in
    if receivedValue.contains("094") {
        expectation.fulfill() // The right value was found, we can fulfill expectations
    }
}
waitForExpectations(timeout: timeout) // Wait for expectation
```
### Testing the store
The store
### Test coverage
Currently only the business logic of application is tested and the test coverage is at 67.88% percent.
![TestCoverageReport](https://raw.githubusercontent.com/JuanitoSebastian/HelsinkiBikeBuddy/main/Documentation/graphics/TestCov.png)
