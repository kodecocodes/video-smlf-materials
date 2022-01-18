/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {

  var locationManager = CLLocationManager()
  var previousLocation: CLLocation?
  lazy var geocoder = CLGeocoder()
  var regionName = ""

  @Published var locationString = ""
  @Published var currentAddress = ""
  @Published var inRegion = false

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.allowsBackgroundLocationUpdates = true
  }

  func startLocationServices() {
    if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
      locationManager.startUpdatingLocation()
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }

  func fetchAddress(for place: Place) {
    currentAddress = ""
    geocoder.reverseGeocodeLocation(place.location) { [weak self] placemarks, error in
      if let error = error {
        fatalError(error.localizedDescription)
      }
      guard let placemark = placemarks?.first else { return }
      if let streetNumber = placemark.subThoroughfare,
         let street = placemark.thoroughfare,
         let city = placemark.locality,
         let state = placemark.administrativeArea {
        DispatchQueue.main.async {
          self?.currentAddress = "\(streetNumber) \(street) \(city), \(state)"
        }
      } else if let city = placemark.locality, let state = placemark.administrativeArea {
        DispatchQueue.main.async {
          self?.currentAddress = "\(city), \(state)"
        }
      } else {
        DispatchQueue.main.async {
          self?.currentAddress = "Address Unknown"
        }
      }
    }
  }

  func setupMonitoring(for places: [Place]) {
    if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
      for place in places {
        let region = CLCircularRegion(center: place.location.coordinate, radius: 500, identifier: place.name)
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
      }
    }
  }

}

extension LocationManager: CLLocationManagerDelegate {

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
      locationManager.startUpdatingLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    inRegion = true
    regionName = region.identifier
    locationManager.stopMonitoring(for: region)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let latest = locations.first else { return }
    if previousLocation == nil {
      previousLocation = latest
    } else {
      let distanceInMeters = previousLocation?.distance(from: latest) ?? 0
      previousLocation = latest
      locationString = "You are \(Int(distanceInMeters)) meters from your start point."
    }
    print(latest)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    guard let clError = error as? CLError else { return }
    switch clError {
    case CLError.denied:
      print("Access denied")
    default:
      print("Catch all errors")
    }
  }

}
