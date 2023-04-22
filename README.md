# toilet-detection
an iOS library that infers toilet existence probability from image.


## Toilet detection

This is an iOS library to check if there is a toilet in an image (`UIImage`).
You can get the existence probability of toilet via `ToiletDetection` actor.


<img src="https://user-images.githubusercontent.com/44002126/233438726-9dd2578a-776d-491f-815e-d4b07a791c7e.PNG" width=320px>

## Installation

Because I don't distribute coreml package, you need to build coreml package by yourself.

please follow the below.

1. clone git repository
```
// simple clone
git clone https://github.com/fummicc1/toilet-detection/

// use submodule
git submodule add https://github.com/fummicc1/toilet-detection/ toilet-detection
```

2. build `py/generate_model.py`

```sh
cd toilet-detection/py
python generate_model.py
```

3. place `mobilenetv3.mlpackage` at `Sources/ToiletDetection/Resources` folder.

```sh
mkdir -p ../Sources/ToiletDetection/Resources
cp mobilenetv3.mlpackage ../Sources/ToiletDetection/Resources
```

4. Install package as a local.

`ToiletDetection` is ready.

## Code example

```swift
import ToiletDetection
let toiletDetection = ToiletDetection()
let image = UIImage(named: "toilet.png")
// result is in [0...1]
let prob = await toiletDetection.perform(image: image)
print(prob)
```
