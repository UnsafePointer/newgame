# newgame

Small iOS app that helps you to populate your Simulator or Device with images from Google Custom Search

## Setup

Follow [this instructions](https://developers.google.com/custom-search/json-api/v1/introduction) to get an `engineId` and a `key`. Provide this infromation through the missing class `GoogleCustomSearchCredentials`.

Configure your query [here](https://github.com/Ruenzuo/newgame/blob/master/NewGame/Sources/ViewController.swift#L39), number of results [here](https://github.com/Ruenzuo/newgame/blob/master/NewGame/Sources/ViewController.swift#L7).

Note: Image Search isn't enabled by default for newly created search engines, so you'll have to enable it first.

## Building

This project doesn't use any dependency manager so just open the FanSabisu.xcodeproj and building should work as long as the Xcode version supports the Swift 3.0 and you provide the [missing sensitive information files](https://github.com/Ruenzuo/newgame/blob/master/.gitignore#L3).

## License

Please check [LICENSE](LICENSE)
