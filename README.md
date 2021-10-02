# PopNetworking+Aggregation

⚠️⚠️⚠️Only use this framework if your project does not support iOS 13 and Combine. It is best to use PopNetworking's Combine support⚠️⚠️⚠️

Two routes can be aggregated together with the new `and()` function.

```swift
SomeRoute().and(run: AnotherRoute()) { aggregatedResult in
    switch aggregatedResult {
        case .success(let twoModels):
            print("SomeRoute response model: \(twoModels.0)")
            print("AnotherRoute response model: \(twoModels.1)")
        case .failure(let error):
            print(error)
    }
}
```

Two routes can be ran sequentially with the new `andThen()` function. The dependent route, `AnotherRoute`, is required to adhere to the new `DependentNetworkingRoute` protocol

```swift
SomeRoute().andThen(run: AnotherRoute.self) { anotherRouteResult in
    switch anotherRouteResult {
        case .success(let anotherRouteResponseModel):
            print(anotherRouteResponseModel)
        case .failure(let error):
            print(error)
    }
}
```
