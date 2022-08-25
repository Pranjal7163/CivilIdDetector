# Civil ID Detector
This library for flutter provides easy means to scan a kuwait civil id card.
It uses OCR to acheive the same , OCR relies on goole ml kit

## Implementation

### Step 1 : Add Firebase to Flutter
Go through the firebase offical website to add firebase to your project.
https://firebase.google.com/docs/flutter/setup

Add the Google Service plist and json file in IOS and android project respectively.

### Step 2 : Add the dependencies
```
camera: 0.9.8
civil_id_detector: 0.0.1
```

### Step 3 : Adding bits for android and IOS
For IOS add this in info.plist file
```
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
```


For android :
Add the following in the manifest file
```
<uses-permission android:name="android.permission.CAMERA"/>
```

Add the following in the application tag of manifest file
```
<meta-data
android:name="com.google.mlkit.vision.DEPENDENCIES"
android:value="ica,ocr" />
```


### Step 4 : Code integration

```
CameraController? _camController;
CivilIdDetector.detect(_camController!, (IDTYPE idType, CivilIdMrzModel? mrzModel) => {
    handleResponse(idType, mrzModel)
});
```

## Properties
IDTYPE | String enum
--- | ---
Possible Values | CIVIL_ID_FRONT , CIVIL_ID_BACK

## CivilIdMrzModel  : Class Object
Attributes | Description
--- | ---
ID Type | Type of document , it returns ID for kuwait civil id
Country | County of origin of the document scanned
Gender | Gender of the document holder
Nationality | Nationality of the document holder
Name | Name of the document holder



## License

MIT
