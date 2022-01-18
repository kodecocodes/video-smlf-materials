import UIKit
import CoreLocation

var location = "625 Noble Street, Anniston, Alabama"
let geocoder = CLGeocoder()

geocoder.geocodeAddressString(location) { placemarks, error in
  if let error = error {
    fatalError(error.localizedDescription)
  }
  guard let placemark = placemarks?.first else {
    return
  }
  print(placemark.location)
}

