# SwiftLocalhost
A Simple framework that creates a mock localhost server, primarily used for XCUITest.

## Installation

### [CocoaPods](http://cocoapods.org)

SwiftLocalhost is available through CocoaPods: to install it, add the following line to your Podfile:
```ruby
pod 'SwiftLocalhost'
```

## Under the hood

`Swiftlocalhost` uses [Criollo](https://github.com/thecatalinstan/Criollo) library as the in-memory web server. 

## How to use
Follow these 4 steps to setup:

### 1. [Localhost] Launching a `LocalhostServer` instance.

There are 2 ways to create an instance of a Localhost.

1. Using a specific port number
  ```swift
  LocalhostServer(portNumber: 9001)
  ```

2. Getting an instance with a random unused port number assigned to it. This is important if you want to execute multiple tests in parallel.

  ```swift
  LocalhostServer.initializeUsingRandomPortNumber()
  ```

Here's an example of how a XCTestCase class might look like:

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

### 2. [API] Redirect your requests domain

If you are using a specific port for your localhost, you can simply change the domain to http://localhost:xxxx (where xxxx is port number).

```swift
class NetworkOperations {

    //private let baseUrl: String = "https://api.themoviedb.org/3/movie"
    
    private let baseUrl: String = "http://localhost:9001/3/movie"
}
```

If you are using random port numbers in your tests, then you will need to pass the port information into your app as launch arguments.

```swift
//In Test Runner, pass the port information using launchArguments
let app = XCUIApplication()
app.launchArguments = ["port:\(self.localhostServer.portNumber)"]
app.launch()

//In Application - Read the ProcessInfo Arguments
ProcessInfo.processInfo.arguments
```

If you need to redirect 3rd party libraries (eg. Firebase, Google Analytics) to the localhost server, you can use [NetworkInterceptor](https://github.com/depoon/NetworkInterceptor) pod created by Kenneth Poon.

### 3. [Info.plist] - Modify Your App Info.plist

Since we will be using `http` protocol to communicate with our localhost server, we will need to add an exception domain for `localhost` in your Info.plist file.

![picture alt](./Resources/Info-plist-add-exception-domain.png)

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

You will also need to disable SSL Pinning if needed.

### 4. [Mock Responses] - Setup localhost server mock responses

You can setup specific mock response according to your test case needs. Set the `Data` instance of the response file as a response to a specific path that your test cases will be covering.

```swift
//let portNumber: UInt = 9001

//Binary of Mock Response Json File
//let jsonFileData: Data! 

self.localhostServer.get("/3/movie/popular", routeBlock: { request in
    let requestURL: URL = URL(string: "http://localhost:\(portNumber)/3/movie/popular")!
    let httpUrlResponse = HTTPURLResponse(url: requestURL, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type":"application/json"])!
    return LocalhostServerResponse(httpUrlResponse: httpUrlResponse, data: jsonFileData)
})

```
