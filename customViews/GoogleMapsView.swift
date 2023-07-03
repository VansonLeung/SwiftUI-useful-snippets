import UIKit
import SwiftUI
import GoogleMaps


struct GoogleMapsViewMarkerStruct : Identifiable {
    var id: String
    var departure_id: String
    var name: String
    var lat: CLLocationDegrees
    var long: CLLocationDegrees
    var item_index: Int
    var licence_plate: String?
    var type: String
    
    init(
        departure_id: String,
        name: String,
        lat: CLLocationDegrees,
        long: CLLocationDegrees,
        item_index: Int,
        type: String
    ) {
        self.departure_id = departure_id
        self.name = name
        self.lat = lat
        self.long = long
        self.item_index = item_index
        self.type = type
        self.id = self.departure_id
    }
    
    public static func ==(lhs: GoogleMapsViewMarkerStruct, rhs: GoogleMapsViewMarkerStruct) -> Bool {
        lhs.departure_id == rhs.departure_id
    }
}


struct GoogleMapsView: UIViewRepresentable {

    @ObservedObject var locationManager = LocationManager.shared

    @Binding var markers : [GoogleMapsViewMarkerStruct]
    
    var initialLat: CLLocationDegrees
    var initialLng: CLLocationDegrees
    var markerBottomOffset: CGFloat? = 0
    var initialZoom: Float?
    
    @Binding var activeMarker: Int
    @Binding var shouldForceActiveMarkerSync: Bool
    @Binding var shouldGoToMyLocation: Bool
    var shouldShowActiveMarkerOnly: Bool? = false
    
    var shouldRequestLocationAuthorization: Bool? = true
    var locationManagerRequestLocationAuthorizationAlertTitle: String? = nil
    var locationManagerRequestLocationAuthorizationAlertMessage: String? = nil

    func makeCoordinator() -> Coordinator {
        return Coordinator(latitude: initialLat, longitude: initialLng, zoom: initialZoom)
    }
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(
            withLatitude: context.coordinator.latitude,
            longitude: context.coordinator.longitude,
            zoom: context.coordinator.zoom
        )
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        if let markerBottomOffset = markerBottomOffset, markerBottomOffset > 40 {
            mapView.padding = .init(top: 0, left: 0, bottom: markerBottomOffset - 40, right: 0)
        }
        
        if locationManager.isAuthorized()
        {
            mapView.isMyLocationEnabled = true
        }
        else
        {
            mapView.isMyLocationEnabled = false
            if shouldRequestLocationAuthorization == true {
                locationManager.requestLocationAuthorization(
                    locationManagerRequestLocationAuthorizationAlertTitle: locationManagerRequestLocationAuthorizationAlertTitle,
                    locationManagerRequestLocationAuthorizationAlertMessage: locationManagerRequestLocationAuthorizationAlertMessage,
                    callback: nil
                )
            }
        }

        if let shouldShowActiveMarkerOnly = shouldShowActiveMarkerOnly {
            context.coordinator.showActiveMarkerOnly = shouldShowActiveMarkerOnly
        }

        context.coordinator.mapView = mapView

        context.coordinator.syncActiveMarker(parent: self, activeMarker: activeMarker)
        context.coordinator.syncMapMarkers(parent: self, markers: markers)
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        context.coordinator.syncActiveMarker(parent: self, activeMarker: activeMarker)
        context.coordinator.syncMapMarkers(parent: self, markers: markers)
        
        
        if locationManager.isAuthorized()
        {
            context.coordinator.mapView?.isMyLocationEnabled = true
        }
        else
        {
            context.coordinator.mapView?.isMyLocationEnabled = false
        }
        
        
        //        let camera = GMSCameraPosition.camera(withLatitude: locationManager.latitude, longitude: locationManager.longitude, zoom: zoom)
        //        mapView.camera = camera
    }
    
}

extension GoogleMapsView {

    class Coordinator: NSObject, GMSMapViewDelegate {
        var zoom: Float = 15.0
        var currentMarkers : [String : GoogleMapsViewMarkerStruct] = [:]
        var currentActiveMarker: Int = -1
        var mapMarkers : [String : GMSMarker] = [:]
        var latitude: CLLocationDegrees = 0
        var longitude: CLLocationDegrees = 0
        
        var mapView: GMSMapView?
        var showActiveMarkerOnly: Bool = false

        init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Float?) {
            super.init()
            self.latitude = latitude
            self.longitude = longitude
            if let zoom = zoom {
                self.zoom = zoom
            }
            mapView?.delegate = self
        }
        
        
        func syncMapMarkers(parent: GoogleMapsView, markers: [GoogleMapsViewMarkerStruct])
        {
            // remove / update
            for old_key in currentMarkers.keys {
                var is_remove = true
                for it in markers {
                    if it.id == old_key {
                        currentMarkers[old_key]!.name = it.name
                        currentMarkers[old_key]!.lat = it.lat
                        currentMarkers[old_key]!.long = it.long
                        currentMarkers[old_key]!.licence_plate = it.licence_plate
                        currentMarkers[old_key]!.item_index = it.item_index
                        is_remove = false
                        break
                    }
                }
                if is_remove {
                    currentMarkers.removeValue(forKey: old_key)
                }
            }
            
            // insert
            for it in markers {
                var is_insert = true
                if let marker = currentMarkers[it.id] {
                    is_insert = false
                    break
                }
                if is_insert {
                    currentMarkers[it.id] = it
                }
            }
            
            

            
            
            // remove / update map markers
            for old_key in mapMarkers.keys {
                var is_remove = true
                if let marker = currentMarkers[old_key] {
                    
                    if !showActiveMarkerOnly
                        ||
                        currentActiveMarker == marker.item_index
                    {
                        if let locationmarker = mapMarkers[old_key]
                        {
                            let position = CLLocationCoordinate2D(latitude: marker.lat, longitude: marker.long)
                            locationmarker.position = position
                            
                            if marker.type == "SP_BUS"
                            {
                                let revised_title = "Bus # \(marker.item_index+1)"
                                let revised_snippet = "\(marker.licence_plate ?? "sp_bus_unknown_licence_plate".i18n())"
                                
                                if mapMarkers[old_key]!.title != revised_title
                                    || mapMarkers[old_key]!.snippet != revised_snippet
                                {
                                    mapMarkers[old_key]!.title = revised_title
                                    mapMarkers[old_key]!.snippet = revised_snippet
                                    
                                    if Constants.getInstance().shouldGoogleMapUseCustomMarkerView_sp_bus() {
                                        mapMarkers[old_key]!.iconView = makeMapMarkerView_sp_bus(marker: mapMarkers[old_key]!)
                                    }
                                }
                            }
                            else
                            {
                                let revised_title = "\(marker.name )"
                                locationmarker.title = revised_title
                            }
                            
                            is_remove = false
                            break
                        }
                    }
                }
                if is_remove {
                    mapMarkers[old_key]!.map = nil
                    mapMarkers.removeValue(forKey: old_key)
                }
            }
            
            // insert map markers
            for new_key in currentMarkers.keys {
                var is_insert = true
                if let marker = mapMarkers[new_key] {
                    is_insert = false
                    break
                }
                if is_insert {
                    // make new map marker

                    
                    if let marker = currentMarkers[new_key] {
                        if !showActiveMarkerOnly
                            ||
                            currentActiveMarker == marker.item_index
                        {
                            let position = CLLocationCoordinate2D(latitude: marker.lat, longitude: marker.long)
                            let locationmarker = GMSMarker(position: position)
                            
                            if marker.type == "SP_BUS"
                            {
                                locationmarker.title = "Bus # \(marker.item_index+1)"
                                locationmarker.snippet = "\(marker.licence_plate ?? "sp_bus_unknown_licence_plate".i18n())"
                                
                                if Constants.getInstance().shouldGoogleMapUseCustomMarkerView_sp_bus() {
                                    locationmarker.iconView = makeMapMarkerView_sp_bus(marker: locationmarker)
                                }
                            }
                            else if marker.type == "TP_POI"
                            {
                                let pin = UIImage(named: "ic_map_pin")!.withRenderingMode(.alwaysOriginal)
                                let markerView = UIImageView(image: pin)
                                let v = UIView(frame: CGRect(x: 0, y: 0, width: markerView.frame.size.width, height: markerView.frame.size.height))
                                v.addSubview(markerView)
                                v.sizeToFit()
                                var c = markerView.frame
                                c.origin.y = 4
                                markerView.frame = c
                                locationmarker.iconView = v
                            }
                            else if marker.type == "TP_POI_M"
                            {
                                let pin = UIImage(named: "ic_map_pin_n")!.withRenderingMode(.alwaysOriginal)
                                let markerView = UIImageView(image: pin)
                                let v = UIView(frame: CGRect(x: 0, y: 0, width: markerView.frame.size.width, height: markerView.frame.size.height))
                                v.addSubview(markerView)
                                v.sizeToFit()
                                var c = markerView.frame
                                c.origin.y = 2
                                markerView.frame = c
                                locationmarker.iconView = v
                            }
                            else
                            {
                                locationmarker.title = "\(marker.name)"
                            }
                            
                            locationmarker.map = mapView
                            mapMarkers[new_key] = locationmarker
                        }
                    }
                    
                    
                }
            }

            
            
            
//            currentMarkers.removeAll()
//            currentMarkers.append(contentsOf: markers)
//
//            for m in (0 ..< mapMarkers.count).reversed()
//            {
//                mapMarkers[m].map = nil
//                mapMarkers.remove(at: m)
//            }
            
//            for k in 0 ..< currentMarkers.count
//            {
//                if !showActiveMarkerOnly
//                    ||
//                    currentActiveMarker == k
//                {
//                    let marker = currentMarkers[k]
//                    let position = CLLocationCoordinate2D(latitude: marker.lat, longitude: marker.long)
//                    let locationmarker = GMSMarker(position: position)
//                    locationmarker.title = "Bus # \(k+1)"
//                    locationmarker.snippet = "\(marker.licence_plate ?? "sp_bus_unknown_licence_plate".i18n())"
//                    locationmarker.map = mapView
//
//                    if Constants.getInstance().shouldGoogleMapUseCustomMarkerView_sp_bus() {
//                        locationmarker.iconView = makeMapMarkerView_sp_bus(marker: locationmarker)
//                    }
//
//                    mapMarkers.append(locationmarker)
                    
//                    if showActiveMarkerOnly
//                        ||
//                        currentActiveMarker == k
//                    {
//                        mapView?.selectedMarker = locationmarker
//                    }
//
//                }
//
//            }
            
//            var mapMarkersToRemove = []
//            var mapMarkersToAdd = []
//
//            for m in (0 ..< currentMarkers.count).reversed()
//            {
//                if !markers.contains(where: { it in
//                    currentMarkers[m] == it
//                }) {
//                    currentMarkers.remove(at: m)
//                }
//            }
//
//            for k in (0 ..< markers.count)
//            {
//                if !currentMarkers.contains(where: { it in
//                    markers[k] == it
//                }) {
//                    currentMarkers.
//                }
//            }
//
//            for k in markers
//            {
//                for m in currentMarkers
//                {
//                    if markers
//                }
//            }
        }
        
        
//        func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//
//            return MapMarkerCustomView(rootView: AnyView(
//                EmptyView()
//            ))
//        }
//
        
        
        func makeMapMarkerView_sp_bus(marker: GMSMarker) -> UIView {
            return MapMarkerCustomView(rootView: AnyView(
                VStack {
                    VStack {
                        if let title = marker.title {
                            Text(title)
                                .font(.footnote)
                                .bold()
                        }
                        if let snippet = marker.snippet {
                            Text(snippet)
                                .font(.footnote)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                }
                    .background(
                        Rectangle()
                            .fill(Color.white)
                            .cornerRadius(10)
                    )
            ))
        }
        
        
        
        
        func syncActiveMarker(parent: GoogleMapsView, activeMarker: Int)
        {
            if parent.shouldGoToMyLocation
            {
                parent.shouldGoToMyLocation = false
                parent.shouldForceActiveMarkerSync = false
                if let location = parent.locationManager.mostUpdateLocation {
                    mapViewGoToLatLng(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }
            }
            else
            {
                if currentActiveMarker != activeMarker
                    ||
                    parent.shouldForceActiveMarkerSync
                {
                    parent.shouldGoToMyLocation = false
                    parent.shouldForceActiveMarkerSync = false
                    currentActiveMarker = activeMarker
                    mapViewGoToMarkerIndex(index: currentActiveMarker)
                }
            }

        }
        

        func mapViewGoToLatLng(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
        {
            mapView?.animate(toLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        
        func mapViewGoToLatLng(latitude: CLLocationDegrees, longitude: CLLocationDegrees, zoom: Float)
        {
            mapView?.animate(toLocation: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        
        func mapViewGoToMarkerIndex(index : Int)
        {
            for key in currentMarkers.keys {
                if let marker = currentMarkers[key] {
                    if marker.item_index == index {
                        mapViewGoToLatLng(latitude: marker.lat, longitude: marker.long)
                        break
                    }
                }
            }
        }
    }
}



//extension GMSMarker {
//    func setIconSize(scaledToSize newSize: CGSize) {
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
//        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
//        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        icon = newImage
//    }
//}








class MapMarkerCustomView: UIView {

    var body:UIHostingController<AnyView>?

    init(rootView: AnyView) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 65))
        body = UIHostingController(rootView: AnyView(rootView) )
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        body = UIHostingController(rootView: AnyView(Text("Hello")) )
        setupView()
    }

    /**
    Ensures the callout bubble resizes according to the size of the SwiftUI view that's passed in.
    */
    private func setupView() {

        if let body = body {
            translatesAutoresizingMaskIntoConstraints = false

            //pass in your SwiftUI View as the rootView to the body UIHostingController
            //body.rootView = Text("Hello World * 2")
            body.view.translatesAutoresizingMaskIntoConstraints = false
            body.view.frame = bounds
            body.view.backgroundColor = nil
            //add the subview to the map callout
            addSubview(body.view)

            NSLayoutConstraint.activate([
                body.view.topAnchor.constraint(equalTo: topAnchor),
                body.view.bottomAnchor.constraint(equalTo: bottomAnchor),
                body.view.leftAnchor.constraint(equalTo: leftAnchor),
                body.view.rightAnchor.constraint(equalTo: rightAnchor)
            ])

            sizeToFit()

            body.view.invalidateIntrinsicContentSize()

        }

    }
}
