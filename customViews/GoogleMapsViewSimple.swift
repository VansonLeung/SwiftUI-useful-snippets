import UIKit
import SwiftUI
import GoogleMaps



struct GoogleMapsRevampView: UIViewRepresentable {

    class MarkerObject : NSObject {
        var id: String
        var name: String
        var lat: CLLocationDegrees
        var long: CLLocationDegrees
        var type: String
        
        init(
            id: String,
            name: String,
            lat: CLLocationDegrees,
            long: CLLocationDegrees,
            type: String
        ) {
            self.id = id
            self.name = name
            self.lat = lat
            self.long = long
            self.type = type
        }
    }


    
    
    @ObservedObject var locationManager = LocationManager.shared

    @Binding var markers : [MarkerObject]
    @Binding var activeMarker : MarkerObject?
    
    var initialLat: CLLocationDegrees
    var initialLng: CLLocationDegrees
    var markerBottomOffset: CGFloat? = 0
    var initialZoom: Float? = 15
    var onChangeActiveMarker: ((MarkerObject?) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(
            withLatitude: initialLat,
            longitude: initialLng,
            zoom: initialZoom ?? 15
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
        }

        context.coordinator.mapView = mapView
        context.coordinator.mapView?.delegate = context.coordinator
        
        context.coordinator.onChangeActiveMarker = onChangeActiveMarker
        
//        context.coordinator.syncMapMarkers(parent: self, inputMarkers: markers)

        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {

        context.coordinator.onChangeActiveMarker = onChangeActiveMarker

        context.coordinator.mapView = mapView
        context.coordinator.mapView?.delegate = context.coordinator

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
        
        context.coordinator.syncMapMarkers(
            mapView: mapView,
            inputMarkers: markers,
            activeMarker: activeMarker
        )
        
//        context.coordinator.syncActiveMarker(parent: mapView, activeMarker: <#T##MarkerObject?#>)(parent: MapMarkerCustomView, inputMarkers: markers)
    }
    
}

extension GoogleMapsRevampView {

    class Coordinator: NSObject, GMSMapViewDelegate {
        var currentMarkers : [GoogleMapsRevampView.MarkerObject : GMSMarker?] = [:]
        var currentActiveMarker: GoogleMapsRevampView.MarkerObject?

        var mapView: GMSMapView?
        var onChangeActiveMarker: ((MarkerObject?) -> Void)?
        
        
        
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            print("You tapped : \(marker.position.latitude),\(marker.position.longitude)")

            for kv in currentMarkers
            {
                if marker == kv.value {
                    
                    if let onChangeActiveMarker = onChangeActiveMarker
                    {
                        onChangeActiveMarker(kv.key)
                    }
                    
                }
            }
//
//
//            for kv in currentMarkers
//            {
//                currentMarkers[kv.key] = renderMapMarker(
//                    inputMarker: kv.key,
//                    locationMarker: kv.value,
//                    mapView: mapView)
//            }
            
            
            return false

        }
        
//
//            var target_key : String? = nil
//            for m in mapMarkers.keys
//            {
//                if mapMarkers[m] == overlay
//                {
//                    target_key = m
//                    break
//                }
//            }
//
//            if let target_key = target_key {
//                if let i = mapViewGetMarkerIndexByKey(key: target_key)
//                {
//                    currentActiveMarker = i
//                }
//
//            }
//
//            for m in mapMarkers.keys
//            {
//                if let marker = mapMarkers[m],
//                   let currentMarker = currentMarkers[m]
//                {
//                    renderMapMarker(locationMarker: marker, isActive: currentActiveMarker == currentMarker.item_index)
//                }
//            }
//            renderMapMarker(locationMarker: locationmarker, isActive: currentActiveMarker == marker.item_index)
//
//        }
        
        
        
        
        
        
        func renderMapMarker(
            inputMarker: GoogleMapsRevampView.MarkerObject,
            locationMarker: GMSMarker?,
            mapView: GMSMapView
        ) -> GMSMarker?
        {
            var gmsMarker = locationMarker
            
            if locationMarker == nil {
                let position = CLLocationCoordinate2D(latitude: inputMarker.lat, longitude: inputMarker.long)
                gmsMarker = GMSMarker(position: position)
            }
            
            var icon = "ic_map_pin_n"
            if inputMarker == currentActiveMarker
            {
                icon = "ic_map_pin_o"
            }
            
            let pin = UIImage(named: icon)!.withRenderingMode(.alwaysOriginal)
            let markerView = UIImageView(image: pin)
            
            if let gmsMarker = gmsMarker {
                let v = gmsMarker.iconView ?? UIView(frame: CGRect(x: 0, y: 0, width: markerView.frame.size.width, height: markerView.frame.size.height))
                
                
                for k in gmsMarker.iconView?.subviews ?? []
                {
                    k.removeFromSuperview()
                }
                
                
                
                v.addSubview(markerView)
                
                v.sizeToFit()
                
                var c = markerView.frame
                c.origin.y = 2
                markerView.frame = c

                

                
                let label = UILabel(frame: .init(x: 0, y: 0, width: v.frame.width, height: v.frame.height))
                label.text = "\(inputMarker.name)"
                label.textAlignment = .center
                label.textColor = TP1ViewElementStyles.shared.activeColorTheme.color_content_negative.uiColor()
                label.font = TP1App_UIFontFile_NotoSans_SemiBold(size: 16, style: .body)
                v.addSubview(label)

                
                
                gmsMarker.iconView = v
                
                
                gmsMarker.map = mapView
            }

            return gmsMarker
        }
        
        
        
        
        
        func syncMapMarkers(
            mapView: GMSMapView,
            inputMarkers: [GoogleMapsRevampView.MarkerObject],
            activeMarker: GoogleMapsRevampView.MarkerObject?
        )
        {
            currentActiveMarker = activeMarker
            
            // remove / update
            for kv in currentMarkers {
                var is_remove = true
//                for it in inputMarkers {
//                    if it == kv.key {
//                        is_remove = false
//                        break
//                    }
//                }
                if is_remove {
                    if let marker = kv.value
                    {
                        marker.map = nil
                    }
                    currentMarkers.removeValue(forKey: kv.key)
                }
            }
            
            // insert
            for it in inputMarkers {
                var is_insert = true
//                if let marker = currentMarkers[it] {
//                    is_insert = false
//                    break
//                }
                if is_insert {
                    currentMarkers[it] = renderMapMarker(
                        inputMarker: it,
                        locationMarker: nil,
                        mapView: mapView
                    )
                }
            }
            
            
            for kv in currentMarkers
            {
                currentMarkers[kv.key] = renderMapMarker(
                    inputMarker: kv.key,
                    locationMarker: kv.value,
                    mapView: mapView)
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
        
        func mapViewGoToMarkerObject(markerObject: GoogleMapsRevampView.MarkerObject)
        {
            for kv in currentMarkers {
                if kv.key == markerObject {
                    mapViewGoToLatLng(latitude: markerObject.lat, longitude: markerObject.long)
                    break
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



struct GMSR_MyPreviewProvider_Demo: View {
    @State var markers : [GoogleMapsRevampView.MarkerObject] = []
    @State var activeMarker : GoogleMapsRevampView.MarkerObject? = nil
    
    var body : some View {
        ZStack {
            GoogleMapsRevampView(
                markers: $markers,
                activeMarker: $activeMarker,
                initialLat: 22.403,
                initialLng: 114.001,
                initialZoom: 15) { markerObject in
                    activeMarker = markerObject
                }
            
            Text(activeMarker?.id ?? "")
        }
        .onLoad {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                markers = [
                    GoogleMapsRevampView.MarkerObject(id: "1", name: "1", lat: 22.400, long: 114.000, type: "TP_POI_M"),
                    GoogleMapsRevampView.MarkerObject(id: "2", name: "2", lat: 22.402, long: 114.002, type: "TP_POI_M"),
                    GoogleMapsRevampView.MarkerObject(id: "3", name: "3", lat: 22.404, long: 114.004, type: "TP_POI_M"),
                ]
                activeMarker = markers[0]
            }
        }
    }
}


struct GMSR_MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        GMSR_MyPreviewProvider_Demo()
    }
}



