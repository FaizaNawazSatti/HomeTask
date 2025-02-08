# HomeTask


## Setup Steps
Follow these steps to set up and run the project:

 1.Clone the Repository
 
 2.Open the Project in Xcode
 
 3.Configure Permissions
  * NSLocationWhenInUseUsageDescription
  * NSLocationAlwaysAndWhenInUseUsageDescription
  * NSLocationAlwaysUsageDescription

 4.Enable Background Modes
   * Location updates
   * Background fetch

 5.Run the App
   * Select a physical device or iOS simulator and press Run (⌘R).
   * Grant location permissions when prompted.

  
 6.Test Geofencing
   * Set a geofence by tapping a location on the map.
   * Move inside/outside the geofence area to trigger a notification.
   


## Approach

This app follows the MVVM (Model-View-ViewModel) structure to make sure separation of concerns, making the code more modular and testable.

1.Fetching Locations (API Integration):
    The app uses URLSession to fetch factors of hobby (POIs) from the Overpass API.
    The reaction is parsed into a Location version and saved in the LocationViewModel.

2.Displaying Locations on the Map:
    Uses MapKit to expose fetched POIs as annotations at the map.
    Tapping an annotation allows users to set a geofence with a custom radius (through a custom UI control).
    
3.Geofencing & Notifications:
    When a geofence is ready, a CLCircularRegion is created and monitored using CLLocationManager.
    If the person enters or exits a geofenced region, a neighborhood notification is induced.

4.Data Persistence with Core Data:
    Geofences are stored in Core Data (GeofenceEntity) to make certain they persist across app launches.
    When the app starts offevolved, formerly saved geofences are retrieved and reactivated.

5.Handling Permissions & UI:
    The app requests location permissions and displays an activity indicator while loading statistics.
    Error handling guarantees users see appropriate alerts if permissions are denied or API calls fail.

6.Unit Testing:
    Includes unit exams for Core Data endurance and ViewModel common sense to verify API responses and facts control.
    

    

## Third-Party Libraries

This venture does not rely on any 0.33-celebration libraries. It completely uses Apple’s local frameworks, which include:

MapKit: To show maps and geofences.

CoreLocation: For managing geofencing and area monitoring.

CoreData: For storing geofences constantly.

UserNotifications: To cause geofence access/exit notifications.



## Trade-offs and Assumptions

1.Some allowances and compromises are made in the design of the software. Predefined geographic boundaries for the Overpass API query restrict the locations that can be fetched from the hard-coded Rawalpindi coordinates.

2.iOS limitations in background geofencing management suggest that alerts triggered by position changes may sometimes be delayed until the app is next launched or refreshed. 

3.Core Data is selected to store persistent local caches because it is more extensible than UserDefaults or Realm, which can face scalability issues with increasing usage and stored content, to which alternate approaches better suited).

4.UIKit, being more tightly integrated with the required MapKit and CoreLocation frameworks as opposed to relatively unfamiliar SwiftUI, made it simpler and more efficient for the location-abiding functionality to be plugged in under overall endeavour architecture. 
