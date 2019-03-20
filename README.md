# FaceDetection

Face Detection Using the Vision Framework for iOS

![alt text](Screenshots/fullface.png?raw=true "Full Face")
![alt text](Screenshots/laser.png?raw=true "Lasers")

## How to use the Vision framework to:

- Create requests for face detection and detecting face landmarks.
- Process these requests.
- Overlay the results on the camera feed to get real-time, visual feedback.

## Vision Framework Usage Patterns

All Vision framework APIs use three constructs:

1. Request: The request defines the type of thing you want to detect and a completion handler that will process the results. This is a subclass of VNRequest.
2. Request handler: The request handler performs the request on the provided pixel buffer (think: image). This will be either a VNImageRequestHandler for single, one-off detections or a VNSequenceRequestHandler to process a series of images.
3. Results: The results will be attached to the original request and passed to the completion handler defined when creating the request. They are subclasses of VNObservation

## What Else Can You Detect?

Aside from face detection, the Vision framework has APIs you can use to detect all sorts of things.

- Rectangles: With VNDetectRectanglesRequest, you can detect rectangles in the camera input, even if they are distorted due to perspective.
- Text: You can detect the bounding boxes around individual text characters by using VNDetectTextRectanglesRequest. Note, however, this doesn’t recognize what the characters are, it only detects them.
- Horizon: Using VNDetectHorizonRequest, you can determine the angle of the horizon in images.
- Barcodes: You can detect and recognize many kinds of barcodes with VNDetectBarcodesRequest.
- Objects: By combining the Vision framework with CoreML, you can detect and classify specific objects using VNCoreMLRequest.
- Image alignment: With VNTranslationalImageRegistrationRequest and VNHomographicImageRegistrationRequest you can align two images that have overlapping content.
