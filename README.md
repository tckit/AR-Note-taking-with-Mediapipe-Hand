# Augmented Reality For Note-taking On The Go
- Final project completed in Jan 2024 trimester for Bachelor of Computer Science at UTAR.

![Usage gif](./Usage.gif)

## Summary 
- Refer to [Mediapipe Unity Plugin](https://github.com/homuler/MediaPipeUnityPlugin). This project is built upon this plugin for hand-tracking purpose. 
- The above plugin is integrated with Augmented Reality (AR) and drawing tools. This allows writing on AR detected surface.
- Android is built with Flutter. Notes management can be done here.
- Flutter will communicate with Unity for simple data transfer, through native code (Kotlin).

## Features
- Import / Export images or pdf
- Overlay selected image on detected surface
- Gestures (not bona fide!)
- Drawing tools

### Detecting gestures
- Index finger straight and thumbs closed to start writing
- Index finger closed and thumbs opened to stop writing
- Pinch and swipe to go to prev/next image or prev/next page pdf (thumb and index finger close to each other, swipe up/right/bottom/left)
