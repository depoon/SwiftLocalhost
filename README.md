# SwiftLocalhost
Simple framework that creates a mock localhost server primarily used for XCUITest.
### Installation

##### [CocoaPods](http://cocoapods.org)

SwiftLocalhost is available through CocoaPods. To install it, simply add the following line to your Podfile:
```ruby
pod 'SwiftLocalhost'
```

## How to use
Follow these 4 steps to setup
### 1. [Localhost] - pod install `SwiftLocalhost` to your XCUITest target.

There are 2 ways to create an instance of a Localhost.

Using a specific port number
```swift
LocalhostServer(portNumber: 9001)
```

Getting an instance with a random unused port number assigned to it
```swift
LocalhostServer.initializeUsingRandomPortNumber()
```

An example of how a XCTestCase class looks like
```swift
import SwiftLocalhost

class MovieListTest: XCTestCase {
    
    var localhostServer: LocalhostServer!
    
    override func setUp() {
        continueAfterFailure = false
        self.localhostServer = LocalhostServer.initializeUsingRandomPortNumber()
        self.localhostServer.startListening()
    }
    
    override func tearDown() {
        self.localhostServer.stopListening()
    }
}
```
