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
Once you've loaded the host map, you can set all environments to prerelease by doing this:
```swift
HostMapManager.sharedInstance.setPrereleaseConfigurations()
```
and to release by doing this:
```swift
HostMapManager.sharedInstance.setReleaseConfigurations()
```
Note that these methods set the environment to whatever is defined in your host map JSON file's "prerelease_key" and "release_key", respectively.
  
  
To show the configuration selection UI, add code to load SquidKit's HostConfigurationTableViewController:
```swift
let configurationViewController:HostConfigurationTableViewController = HostConfigurationTableViewController(style: .Grouped)

myNavigationController.pushViewController(configurationViewController, animated: true)
```
which will give you a table view that looks something like this:

![SquidKit: Host Environment Table](https://raw.githubusercontent.com/SquidKit/SquidKit/assets/host_env_table.png)

Host environment settings remain in effect after application restarts, since by default the results are cached to NSUserData. To clear the cache, you can do this:
```swift
HostMapManager.sharedInstance.hostMapCache?.removeAll()
```
You can provide your own caching mechanism - for example, if you want to store to SharedUserDefaults if you're working on an app and an extension - by setting the HostMapManager's hostMapCache to a class that implements the HostMapCache protocol (defined in EndpointMap.swift). If you want no caching at all, just set the hostMapCache to nil:
```swift
HostMapManager.sharedInstance.hostMapCache = MyHostMapCache()
// OR
HostMapManager.sharedInstance.hostMapCache = nil
```
  
  
In the SquidKitExample project, see EndpointExampleViewController.swift, TestEndpoint.swift and HostMap.json for examples of all of the above.

### JSON parsing
While not quite a full on parser, SquidKit offers a utility for working with JSON response data that abstracts away some of the ugliness of directly dealing with Dictionary objects and extracting values therein. SquidKit handles JSON data with one public class: JSONEntity. JSONEntity is effectively a wrapper for a JSON element's key and value. Unlike walking through a Dictionary checking to see if particular keys exist, a JSONEntity is guaranteed to be non-nil, thus always directly inspectable without checking for non-nil optional values.
  
A JSONEntity can be constructed with a key/value pair, a JSON resource file, or a JSON dictionary:
```swift
public init(_ key:String, _ value:AnyObject)
public init(resourceFilename:String)
public init(jsonDictionary:NSDictionary)
```
JSON elements are extracted using common subscript syntax:
```swift
let json = JSONEntity(resourceFilename: "MyJSONFile.json")
let someItem = json["some_item"]
```
at this point you can extract the value of the JSON "some_item" entity using one of the JSONEntity value extraction methods. All of the value extraction methods take a default value parameter with a default value of nil (so you can omit it); however, it is often quite useful and more succinct to just specify the default at extraction/assignment time, thus:
```swift
let address = entity["address"].string("Address N/A")
```
here are all of the value extraction methods of JSONEntity:
```swift
public func string(_ defaultValue:String? = nil) -> String?

public func array(_ defaultValue:NSArray? = nil) -> NSArray?

public func dictionary(_ defaultValue:NSDictionary? = nil) -> NSDictionary?

public func int(_ defaultValue:Int? = nil) -> Int?

public func float(_ defaultValue:Float? = nil) -> Float?

public func bool(_ defaultValue:Bool? = nil) -> Bool?
```
JSONEntity also supports two subscript operators: one that takes a String (for extracting key values) and one that takes an Int (for extracting array element values). The subscript operators return a non-nil JSONEntity that wraps the value. Of course, values don't always exist; this is way the value extraction methods all return optionals. One can also look at the "isValid" bool value of a JSONEntity to determine if it contains a valid value.
  
JSONEntity conforms to SequenceType, which means it supports iteration using for-in syntax:
```swift
let json = JSONEntity(myJSONDictionary)
let entities = json["entities_array"]
for entity in entities {
    let float = entity["float_item"].float()
    // etc...
}
```
  
JSONEntity is conceptually similar to the SwiftyJSON library - however, unlike SwiftyJSON, JSONEntity supports the quite useful default values and iteration mentioned above.
  
In the SquidKitExample project, see JSONEntityExampleViewController.swift for an example of using JSONEntity. Additionally, SquidKit itself uses JSONEntity to parse JSON theme files (ThemeLoader.swift in the SquidKit project).

### Themes
SquidKit themes are simply a mechanism for expressing pretty much any attribute in an external file, rather than internally in source code. This theme model borrows heavily from Brent Simmons' [DB5][2] theme work, however SquidKit themes use the more portable JSON format rather than plists for defining theme elements. Theme-able elements include colors (including alpha), strings, ints, floats, bools, or any Dictionary value.
  
Theme JSON looks like this:
```json
{
    "themes":
    [
        {
            "name": "ExampleTheme",
            "attributes":
            [
				{
					"type":		"color",
					"value":	"0000FF(blue)",
					"key":		"defaultBackgroundColor"
				},
				{
					"type":		"color",
					"value":	"FF0000(red)",
					"alpha":	0.5,
					"key":		"defaultLabelTextColor"
				},
				{
					"value":	"Theme view with theme label",
					"key":		"myThemeText"
				}
            ]
        }
    ]
}
```
You may include as many "attributes" as you like. The only explicitly "typed" attribute is color. A theme color's value is a hexadecimal string, of the format [0x]NNNNNN[any text]; values in [] are optional; N is a hexadecimal character. Anything after the first 6 hex characters is ignored. There are currently two special "key" values for a color: *defaultBackgroundColor* and *defaultLabelTextColor*. These are used by ThemeViews, ThemeTableViews and ThemeLabels, as discussed below.
  
To load a theme, do this:
```swift
ThemeLoader.loadThemesFromResourceFile("MyTheme.json")

// and to make the first loaded theme the default theme
ThemeManager.sharedInstance.setDefaultTheme()
```
##### ThemeLabel, ThemeView and ThemeTableView
These are views that, given a key name for a theme color, will automatically load and use that theme color for their background colors, or for it's text color (for ThemeLabel). You set the key name for these views via a string property that, by default, is set to *defaultBackgroundColor* or, for the label, *defaultLabelTextColor*. Thus to get default theme behavior for labels and views, you need do nothing other than provide the appropriate color attributes in your theme file.
  
See ThemedViewController.swift and ExampleTheme.json in the SquidKitExample project for an example of using themes.

### TableItem and TableSection

### Log

[1]: https://github.com/Alamofire/Alamofire       "Alamofire"
[2]: https://github.com/quartermaster/DB5       "DB5"