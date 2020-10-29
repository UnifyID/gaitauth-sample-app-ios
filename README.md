# iOS GaitAuth Sample App

## Getting Started

### Prerequisites

* Xcode 12.0+
* Ruby 2.6+ & Bundler 2.0.0+
* CocoaPods 1.10.0+
* A UnifyID SDK Key

### Project Setup

1. Install the locked CocoaPod dependencies.

    ```shell
    bundle exec pod install --repo-update
    ```

2. Open the workspace file `GaitAuthSample.xcworkspace`.

    ```shell
    open GaitAuthSample.xcworkspace
    ```

3. Build and run the `GaitAuthSample` scheme.

### Using the app

You will need a UnifyID SDK Key to run the app. See the [GaitAuth Getting Started Guide](https://developer.unify.id/docs/gaitauth/)
for additional details about developing with GaitAuth and to create an SDK Key through the developer portal.

## Project Structure

```
GaitAuthSample.xcodeproj/
GaitAuthSample.xcworkspace/
GaitAuthSample/
├── ...
├── Common              # Utility classes and extensions not specific to GaitAuth/UnifyID
│   └── ...
├── Notifications       # Notification payload structs for broadcast app events
│   └── ...
├── Protocols           # Custom protocols to break down manager behavior into smaller chunks
│   └── ...
├── Scenes              # View Controllers corresponding to the different UI scenes
│   └── ...
├── UnifyID             # Wrapper around the UnifyID SDK to integrate it with application state and view transitions
│   └── ...
├── Gemfile             # Ruby Gemfile to manage ruby dependencies with Bundler
├── Gemfile.lock        # Lock file for Bundler
├── Podfile             # Podfile to manage CocoaPod dependencies
├── Podfile.lock        # CocoaPod lock file that pins actively pulled dependency versions
└── ...
```

## Important Structures

The `UnifyIDManager` class is the component that directly interacts with the UnifyID SDK, so the code in the `UnifyID/` folder will likely
be the most helpful for understanding how the SDK integration works. Most of the logic for invoking and responding to UnifyID SDK calls
is decoupled from the UI responses through notification objects and protocols that `UnifyIDManager` implements.

## Background Collection of Training Data

In order to train a model for a user, it is important to try to collect a broad range of representative samples of that user's behavior.
With this goal in mind, it tends to be helpful to collect data in the background in order to ensure that the app collects data when the user is
conducting their normal activities, not just when they are actively using the app.

This sample application uses background location permissions to constantly stay alive in the background. This is the easiest way to get
started with an application that can continue working in the background, but is not the only option. Exploring other methods is out of the
scope of this sample, but some ideas might include using geofences to trigger collection only in particular places, or using bluetooth beacons
to activate the app when the phone is near them.

## License

MIT License, see [LICENSE](./LICENSE).

## Credits

* [danielgindi/Charts](https://github.com/danielgindi/Charts) (Apache 2.0)
* [airbnb/lottie-ios](https://github.com/airbnb/lottie-ios) (Apache 2.0)
* Loading Spinner courtesy of [MarcoHoo](https://lottiefiles.com/MarcoHoo) via [LottieFiles](https://lottiefiles.com/29208-loading)
* Error animation courtesy of [Lorena Villanueva García](https://lottiefiles.com/lorenavillanueva) via [LottieFiles](https://lottiefiles.com/4386-connection-error)
