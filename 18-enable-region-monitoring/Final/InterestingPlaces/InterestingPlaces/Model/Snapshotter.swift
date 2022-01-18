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
import MapKit
import UIKit

final class Snapshotter: ObservableObject {

  let defaultMap: UIImage
  private(set) var mapSnapShot: UIImage?
  private let imageName: String
  private let region: MKCoordinateRegion
  private let fileLocation: URL
  private let options: MKMapSnapshotter.Options
  private var mapSnapshotter: MKMapSnapshotter?

  @Published private(set) var isOnDevice = false

  init(imageName: String, region: MKCoordinateRegion) {
    self.imageName = imageName
    self.region = region
    guard let map = UIImage(named: "map.png") else {
      fatalError("Missing default map")
    }
    self.defaultMap = map
    options = MKMapSnapshotter.Options()
    options.region = region
    options.size = CGSize(width: 200, height: 200)
    options.scale = UIScreen.main.scale
    let fileManager = FileManager.default
    guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
      fatalError("Unable to get file.")
    }
    fileLocation = url.appendingPathComponent("\(imageName).png")
    if fileManager.fileExists(atPath: fileLocation.path), let image = UIImage(contentsOfFile: fileLocation.path) {
      mapSnapShot = image
      isOnDevice = true
    }
  }

  func takeSnapshot() {
    mapSnapshotter = MKMapSnapshotter(options: options)
    mapSnapshotter?.start { snapshot, error in
      guard let snapshot = snapshot else {
        fatalError("Unable to take snapshot")
      }
      let imageData = snapshot.image.pngData()
      guard let data = imageData, let imageSnapshot = UIImage(data: data) else {
        fatalError("Unable to produce map image")
      }
      DispatchQueue.main.async { [weak self] in
        self?.isOnDevice = true
        self?.writeToDisk(imageData: data)
        self?.mapSnapShot = imageSnapshot
      }
    }
  }

  func writeToDisk(imageData: Data) {
    do {
      try imageData.write(to: fileLocation)
    } catch {
      fatalError("Unable to write file")
    }
  }
}
