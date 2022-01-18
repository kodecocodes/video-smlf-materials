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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct ContentView: View {
  let places: [Place]
  @State private var selectedPlace: Place

  init(places: [Place]) {
    self.places = places
    _selectedPlace = .init(initialValue: places.first!)
  }
  
  var body: some View {
    NavigationView {
      PlacesView(places: places, selectedPlace: $selectedPlace)
        .background(RoadView())
      .navigationBarHidden(true)
      
      Text("\(Image(systemName: "arrow.left")) Choose an Interesting Place!")
        .font(.largeTitle)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    let places = MapDirectory().places
    ContentView(places: places)
    ContentView(places: places)
      .previewDevice("iPhone 11 Pro Max")
  }
}

private struct PlacesView: View {
  let places: [Place]
  @Binding var selectedPlace: Place
  
  var body: some View {
    VStack {
      NavigationLink(destination: DetailView(location: selectedPlace)) {
        LocationPhoto(photoName: selectedPlace.image)
      }
      .padding(.horizontal)
      
      TitleView(locationName: selectedPlace.name)
        .padding([.top, .horizontal])
      Spacer()
      VStack(spacing: 16) {
        Text("Address Goes Here")
          .foregroundColor(.white)
          .font(.title3)
          .bold()
        LocationOptionsView(place: selectedPlace, places: places)
      }
      Spacer()
      OtherPlacesScrollView(selectedPlace: $selectedPlace, places: places)
        .padding(.vertical)
    }
  }
}

private struct LocationOptionsView: View {
  let place: Place
  let places: [Place]
  
  var body: some View {
    VStack(spacing: 10) {
      Label(
        title: { Text("Find on Map")
          .foregroundColor(.white)
          .fontWeight(.bold) },
        icon: {
          Image(systemName: "mappin.and.ellipse")
            .foregroundColor(.black)
        }
      )
      Button {
        print("Directions goes here")
      } label: {
        Label(
          title: { Text("Get Directions")
            .foregroundColor(.white)
            .fontWeight(.bold) },
          icon: {
            Image(systemName: "map.fill")
              .foregroundColor(.black)
          }
        )
      }
    }
  }
}

private struct OtherPlacesScrollView: View {
  @Binding var selectedPlace: Place
  let places: [Place]
  
  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(places.indices, id: \.self) { index in
          let place = places[index]
          Image(place.image)
            .resizable()
            .frame(width: 100, height: 100, alignment: .center)
            .aspectRatio(1, contentMode: .fill)
            .onTapGesture {
              selectedPlace = place
            }
        }
      }
      .padding(.leading)
    }
    
  }
}
