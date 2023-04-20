# toilet-detection
an iOS library that infers toilet existence probability from image.


## Toilet detection

This is an iOS library to check if there is a toilet in an image (`UIImage`).
You can get the existence probability of toilet via `ToiletDetection` actor.


<img src="https://user-images.githubusercontent.com/44002126/233438726-9dd2578a-776d-491f-815e-d4b07a791c7e.PNG" width=320px>

## Installation

You can install this library via Swift Package Manager.


## Code example

```swift
import ToiletDetection
let toiletDetection = ToiletDetection()
let image = UIImage(named: "toilet.png")
// result is in [0...1]
let prob = await toiletDetection.perform(image: image)
print(prob)
```
