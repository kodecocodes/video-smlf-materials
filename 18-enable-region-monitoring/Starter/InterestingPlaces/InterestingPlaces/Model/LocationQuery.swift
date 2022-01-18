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
import Combine

final class LocationQuery: ObservableObject {

  @Published var searchQuery = ""
  @Published private(set) var searchResults: [String] = []
  
  private var subscriptions: Set<AnyCancellable> = []
  private let region: MKCoordinateRegion

  init(region: MKCoordinateRegion) {
    self.region = region
    $searchQuery
      .debounce(for: .milliseconds(700), scheduler: RunLoop.main)
      .removeDuplicates()
      .sink { [weak self] value in
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = value
        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
          guard let response = response else {
            if let error = error {
              print(error.localizedDescription)
            }
            return
          }
          self?.searchResults = response.mapItems.compactMap(\.name)
        }
      }
      .store(in: &subscriptions)
  }
}
