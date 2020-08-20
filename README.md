- Setup an account and receive your API key, this will be required for all API calls
- Download Cocoapod

   - Add reference in Podfile - `pod 'POD NAME'`
   
   - Run `pod install`
   
- Add the API call to your app as needed
   Add import PODeferredDeepLinks to any file where you need to utilize the API
   Call the API and handle the return values as needed. Below is the most basic call; remember to provide your API key.
```
DeepLinker.shared.fetchDeepLinkData("<YOUR_API_KEY_HERE>") { (data) in
    print("Success: \(data.success)")
    print("Message: \(data.message ?? "No message")")
    print("Payload: \(data.payload ?? "No payload")")
    if success {
        DispatchQueue.main.async {
            // do something...
        }
    } else {
        // handle failure...
    }
}
```
- The return data object has the following properties:
```

       - success: Boolean - a flag that denotes if the network call was successful
       
       - message: String - an optional string providing details about a failed network call
       
       - payload: String - the deep link schema returned by your account configuration
```       
       
- Note that this framework requires a deployment target of iOS 10.0 or greater
