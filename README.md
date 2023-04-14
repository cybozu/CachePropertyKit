# CachePropertyKit

A Swift Package for easy in-memory caching of properties using Property Wrappers.

## Installation

### Swift Package Manager
To integrate using Apple's Swift Package Manager, add the following as a dependency to your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/cybozu/CachePropertyKit.git", from: "1.0.0")
]
```

## Usage

### @Cache
A property wrapper that caches the wrapped value at runtime.
```swift
import CachePropertyKit

struct Repository {
    func fetch() async throws -> Data {
        @Cache(key: "repository_data", lifetime: .duration(3600))
        var data: Data?

        if let data { // Cached data exists and has not expired.
            return data
        } else { // Cached data does not exist or has expired.
            let newData = try? await fetchNewData()
            data = newData

            return newData
        }
    }
}
```

### CacheContainer
A class for managing cached data from outside the property wrapper.
```swift
CacheContainer.clearAll() // Remove all cached data.

CacheContainer.clearAll(where: { key in key == "repository_data" }) // Remove the specified cached data.
```
