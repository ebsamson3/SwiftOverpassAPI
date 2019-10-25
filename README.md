# SwiftOverpassAPI

[![CI Status](https://img.shields.io/travis/ebsamson3/SwiftOverpassAPI.svg?style=flat)](https://travis-ci.org/ebsamson3/SwiftOverpassAPI)
[![Version](https://img.shields.io/cocoapods/v/SwiftOverpassAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOverpassAPI)
[![License](https://img.shields.io/cocoapods/l/SwiftOverpassAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOverpassAPI)
[![Platform](https://img.shields.io/cocoapods/p/SwiftOverpassAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOverpassAPI)

<p align="center">
    <img src="Screenshots/busch_stadium_screenshot.png?raw=true" alt="Busch Stadium"> 
</p>

A Swift module for querying, decoding, and visualizing Overpass API data. 

### **What is Overpass API?**

Overpass API is a read only database for querying open source mapping information provided by the OpenStreetMap project. For more information visit the [Overpass API Wiki](https://wiki.openstreetmap.org/wiki/Overpass_API) and the [OpenStreetMap Wiki](https://wiki.openstreetmap.org/wiki/Main_Page). 

## **Usage**

### **Creating a bounding box**

Create a boxed region that will confine your query

```swift
// Option 1: Initialize with an MKCoordinateRegion
let sanFranciscoCoordinate = CLLocationCoordinate2D(
	latitude: 37.7749,
	longitude: -122.4194)

let queryRegion = MKCoordinateRegion(
	center: sanFranciscoCoordinate,
	latitudinalMeters: 50000,
	longitudinalMeters: 50000)

let boundingBox = OPBoundingBox(region: region)

//Option 2: Initialize with latitudes and longitudes
let boundingBox = OPBoundingBox(
	minLatitude: 38.62661651293796,
	minLongitude: -90.1998908782745,
	maxLatitude: 38.627383487062005,
	maxLongitude: -90.1989091217254)
```

### **Building a Query**

For simple queries generation, you can use `OPQueryBuilder` class:

```swift
do {
	let query = try OPQueryBuilder()
		.setTimeOut(180) //1
		.setElementTypes([.relation]) //2
		.addTagFilter(key: "network", value: "BART", exactMatchOnly: false) //3
		.addTagFilter(key: "type", value: "route") //4
		.addTagFilter(key: "name") //5
		.setBoundingBox(boundingBox) //6
		.setOutputType(.geometry) //7
		.buildQueryString() //8
} catch {
	print(error.localizedDescription)
}
```

1) Set a timeout for the server request
2) Set one or more element types that you wish to query (Any combination of `.node`, `.way` and/or `.relation`)
3) Filter for elements whose "network" tag's value contains "BART" (case insensitive)
4) Filter for elements whose "type" tag's value is exacly "route"
5) Filter for all elements with a "name" tag. Can have any assocaited value.
6) Query within the specified bounding box
7) Specify the output type of the query (See output types section)
8) Build a query string that you pass to the overpass client when making requests to an Overpass API endpoint

The Overpass Query language enables diverse and powerful queries. This makes building a catch-all query builder quite difficult. For more complicated queries, you may need to create the query string yourself:

```swift
let boundingBox = OPBoundingBox(region: region)

let query = """
data=[out:json];
node["network"="BART"]
	["railway"="stop"]
	\(boundingBox.toString())
	->.bartStops;
(
	way(around.bartStops:200)["amenity"="cinema"];
	node(around.bartStops:200)["amenity"="cinema"];
);
(._;>;);
out center;
"""
```

This query finds all theatres within 200 meters of a BART (Bay Area Rapid Transit) stop. You can see just how flexible queries can be. Unfortunately, you can also see how complex the query language is. I recommend checking out out the [Overpass Language Guide](https://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide#Recursing_up_and_down:_Completed_ways_and_relations), the [Overpass Query Language Wiki](https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_QL), and [Overpass API by Example](https://wiki.openstreetmap.org/wiki/Overpass_API/Overpass_API_by_Example).

### **Making an Overpass request**

## **Example App**
<p align="center">
    <img src="Screenshots/buildings_screenshot.png?raw=true" alt="Chicago Buildings" width="250"> 
    <img src="Screenshots/tourism_screenshot.png?raw=true" alt="Chicago Tourism" width="250"> 
    <img src="Screenshots/bart_lines_screenshot.png?raw=true" alt="Bart Subway Lines" width="250"> 
</p>

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## **Installation**

SwiftOverpassAPI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftOverpassAPI'
```

## **Author**

ebsamson3, ebsamson3@gmail.com

## **License**

SwiftOverpassAPI is available under the MIT license. See the LICENSE file for more info.
