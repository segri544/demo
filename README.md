# Bus Tracking System
This project allows us to check current route setted by driver and check live location of the driver. To improve this project you need a basic knowladge about Firebase and Google map services.

![Resim1](https://github.com/segri544/demo/assets/111482228/0e2b6730-405a-4239-87e6-2d72c63028b2)

## Getting Started
### Requirements
* flutter installation
* Google Maps API key
* Firebase Authentication and Cloud Storerage App
### Starting Guide
1. Delete old key and enter your API key into \android\app\src\main\AndroidManifest.xml- -> android:value
2. Delete old key and enter your API key into ios\Runner\AppDelegate.swift --> GMSServices.provideAPIKey("API_KEY")
3. Delete old key and enter your API key into lib\resources\constants.dart --> const String google_api_key = "API_KEY";
4. Start Authentication and Cloud Store features on firebase and get google-services.json file and paste it android\app\google-services.json

### Features 
- Real-time Service Tracking: Users can view and track the live locations of service buses on a map.
- Up-to-Date Service Routes: The application provides the latest service routes and updates them in real-time.
- User-Friendly Interface: The app features an intuitive and user-friendly interface for easy navigation.
   
### what should be added
- Instant Notifications: Users receive timely notifications about service delays or cancellations.
- stop points selected by users: Users should select a point and drivers should see them on map.
- All routes should be seen on a single map with different colors

### Credit
- Berke Gürel
- Mehmet Enes Bilgin
- Sadık EĞRİ


