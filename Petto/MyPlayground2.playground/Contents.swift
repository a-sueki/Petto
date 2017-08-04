import UIKit
import CoreLocation
import XCPlayground


var poppopo: String?

let geocoder = CLGeocoder()
geocoder.geocodeAddressString("〒100-0002", completionHandler: {(placemarks, error) -> Void in
    if((error) != nil){
        print("Error", error)
    }
    if let placemark = placemarks?.first {
        print("State:       \(placemark.administrativeArea!)")
        print("City:        \(placemark.locality!)")
        print("SubLocality: \(placemark.subLocality!)")
        poppopo = placemark.administrativeArea
    }
})

XCPSetExecutionShouldContinueIndefinitely()
print("----------")
print(poppopo)
