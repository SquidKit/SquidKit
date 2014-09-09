![SquidKit: Swift stuff](https://raw.githubusercontent.com/SquidKit/SquidKit/assets/squidkit_logo.png)

========

Moderately useful Swift code modules. Somewhat tested.

## And just what exactly is SquidKit?

SquidKit is a collection of classes, etc that would often be useful in new iOS development projects. It is intended to relieve the developer of the task of building out some of the boring infrastructure that often needs to be built out for modern apps, especially ones that communicate with a server and receive responses in JSON format.

## Major functional components

### Networking
SquidKit networking is built on top of the excellent [Alamofire][1] networking library written by Mattt Thompson. SquidKit takes networking abstraction a bit further by building upon the idea that most apps communicate to a set of endpoints, each with their own set of query or post parameters, and which return data as JSON. Thus, SquidKit introduces the Endpoint class, which is designed to be overridden by various endpoint configurations. SquidKit provides one such overriding class - JSONResponseEndpoint - which is an Endpoint that expects a JSON response format. Defining an endpoint is typically as simple as overriding 3 methods:
* override func host() -> String
* override func path() -> String
* override func params() -> ([String: AnyObject]?, SquidKit.Method)

*Example*
```swift
class TestEndpoint: JSONResponseEndpoint {
    
    override func host() -> String {
        return "httpbin.org"
    }
    
    override func path() -> String {
        return "get"
    }
        
    override func params() -> ([String: AnyObject]?, SquidKit.Method) {
        return (["foo": "bar"], .GET)
    }
   
}
```

Connecting to an endpoint is as simple as calling a connect function with a completion handler in the form of a closure. The JSONResponseEndpoint's connect function looks like this:

```swift
public func connect(completionHandler: ([String: AnyObject]?, ResponseStatus) -> Void)
```

*Example*
```swift
MyEndpoint.connect {(JSON, status) -> Void in
    switch status {
    case .OK:
        Log.print("JSON: \(JSON)")
    case .HTTPError(let code, let message):
        Log.print("\(code): \(message)")
    case .NotConnectedError:
        Log.message("maybe turn on the internets")
    case .HostConnectionError:
        Log.message("can't find that host")
    case .ResourceUnavailableError:
        Log.message("can't find what you're looking for")
    case .UnknownError(let error):
        Log.print(error)
    default:
        break
    }
```

In the SquidKitExample project that is included with SquidKit, take a look at TestEndpoint.swift and EndpointTestTableViewController.swift for further examples of working with SquidKit networking.

### Network host environments
Typically in a development project, one is working with a variety of service environments for a collection of endpoints - production, QA and dev are common examples. SquidKit offers an elegant and complete solution for putting environment switching capabilities into your iOS application *(note: you it is often useful to leave such capabilities in your production app as well, especially if you want to test your production app against planned service modifications. We'll leave it to you how you might wish to hide the service configuration UI from your users)*. In SquidKit, providing an environment switcher is as easy as providing a JSON file that describes your various environments, and including SquidKit's HostConfigurationTableViewController that provides the UI for switching among the environments described in your JSON file.

*JSON file example*
```json
{
    "configurations": [
       {
       "canonical_host": "httpbin.org",
       "canonical_protocol": "http",
       "prerelease_key": "DEV",
       "release_key": "PROD",
       "hosts":  [
                     {
                     "key": "PROD",
                     "host": "httpbin.org"
                     },
                     {
                     "key": "QA",
                     "host": "qa.httpbin.org",
                     "protocol": "https"
                     },
                     {
                     "key": "DEV",
                     "host": "dev.httpbin.org"
                     },
                     {
                     "key": "localhost",
                     "host": "localhost"
                     },
                     {
                     "key": "USER"
                     }
                 ]
       }
    ]
}

```

You can define as many configurations as you like. And note the "USER" key that lacks a "host" or "protocol" entry - this tells SquidKit to treat this key as a runtime defined environment field with a text entry field for inputting the host name.

SquidKit Endpoints automatically work with network host environments, no other or endpoint management is required.

To use host environment configuration, add a line in your app's startup code that looks like this:
```swift
HostMapManager.sharedInstance.loadConfigurationMapFromResourceFile("MyHostMap.json")
```
and then add code to load SquidKit's HostConfigurationTableViewController:
```swift
let configurationViewController:HostConfigurationTableViewController = HostConfigurationTableViewController(style: .Grouped)

myNavigationController.pushViewController(configurationViewController, animated: true)
```

[1]: https://github.com/Alamofire/Alamofire       "Alamofire"