# FaceDetection

Face Detection Using the Vision Framework for iOS

## How to use the Vision framework to:

- Create requests for face detection and detecting face landmarks.
- Process these requests.
- Overlay the results on the camera feed to get real-time, visual feedback.

## Vision Framework Usage Patterns

All Vision framework APIs use three constructs:

1. Request: The request defines the type of thing you want to detect and a completion handler that will process the results. This is a subclass of VNRequest.
2. Request handler: The request handler performs the request on the provided pixel buffer (think: image). This will be either a VNImageRequestHandler for single, one-off detections or a VNSequenceRequestHandler to process a series of images.
3. Results: The results will be attached to the original request and passed to the completion handler defined when creating the request. They are subclasses of VNObservation
