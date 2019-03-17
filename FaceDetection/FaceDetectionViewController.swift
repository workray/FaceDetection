//
//  ViewController.swift
//  FaceDetection
//
//  Created by Mobdev125 on 3/16/19.
//  Copyright © 2019 Mobdev125. All rights reserved.
//

import AVFoundation
import UIKit
import Vision

class FaceDetectionViewController: UIViewController {
    @IBOutlet var faceView: FaceView!
    @IBOutlet var laserView: LaserView!
    @IBOutlet var faceLaserLabel: UILabel!
    
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    var faceViewHidden = false
    
    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0
    
    var sequenceHandler = VNSequenceRequestHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
        
        laserView.isHidden = true
        
        maxX = view.bounds.maxX
        midY = view.bounds.midY
        maxY = view.bounds.maxY
        
        session.startRunning()
    }
}

// MARK: - Gesture methods

extension FaceDetectionViewController {
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        faceView.isHidden.toggle()
        laserView.isHidden.toggle()
        faceViewHidden = faceView.isHidden
        
        if faceViewHidden {
            faceLaserLabel.text = "Lasers"
        } else {
            faceLaserLabel.text = "Face"
        }
    }
}

// MARK: - Video Processing methods

extension FaceDetectionViewController {
    func configureCaptureSession() {
        // Define the capture device we want to use
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
                                                    fatalError("No front video camera available")
        }
        
        // Connect the camera to the capture session input
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Create the video data output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Add the video output to the capture session
        session.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        // Configure the preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
        // Extract the first result from the array of face observation results.
        guard
            let results = request.results as? [VNFaceObservation],
            let result = results.first
            else {
                // Clear the FaceView if something goes wrong or no face is detected.
                faceView.clear()
                return
        }
        
        if faceViewHidden {
            updateLaserView(for: result)
        } else {
            updateFaceView(for: result)
        }
    }
    
    func convert(rect: CGRect) -> CGRect {
        // Use a handy method from AVCaptureVideoPreviewLayer to convert a normalized origin to the preview layer’s coordinate system.
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        
        // Then use the same handy method along with some nifty Core Graphics extensions to convert the normalized size to the preview layer’s coordinate system.
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        
        // Create a CGRect using the new origin and size.
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    // Define a method which converts a landmark point to something that can be drawn on the screen.
    func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
        // Calculate the absolute position of the normalized point by using a Core Graphics extension defined in CoreGraphicsExtensions.swift.
        let absolute = point.absolutePoint(in: rect)
        
        // Convert the point to the preview layer’s coordinate system.
        let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
        
        // Return the converted point.
        return converted
    }

    func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
        return points?.compactMap { landmark(point: $0, to: rect) }
    }
    
    func updateFaceView(for result: VNFaceObservation) {
        defer {
            DispatchQueue.main.async {
                self.faceView.setNeedsDisplay()
            }
        }
        
        let box = result.boundingBox
        faceView.boundingBox = convert(rect: box)
        
        guard let landmarks = result.landmarks else {
            return
        }
        
        if let leftEye = landmark(
            points: landmarks.leftEye?.normalizedPoints,
            to: result.boundingBox) {
            faceView.leftEye = leftEye
        }
        
        if let rightEye = landmark(
            points: landmarks.rightEye?.normalizedPoints,
            to: result.boundingBox) {
            faceView.rightEye = rightEye
        }
        
        if let leftEyebrow = landmark(
            points: landmarks.leftEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            faceView.leftEyebrow = leftEyebrow
        }
        
        if let rightEyebrow = landmark(
            points: landmarks.rightEyebrow?.normalizedPoints,
            to: result.boundingBox) {
            faceView.rightEyebrow = rightEyebrow
        }
        
        if let nose = landmark(
            points: landmarks.nose?.normalizedPoints,
            to: result.boundingBox) {
            faceView.nose = nose
        }
        
        if let outerLips = landmark(
            points: landmarks.outerLips?.normalizedPoints,
            to: result.boundingBox) {
            faceView.outerLips = outerLips
        }
        
        if let innerLips = landmark(
            points: landmarks.innerLips?.normalizedPoints,
            to: result.boundingBox) {
            faceView.innerLips = innerLips
        }
        
        if let faceContour = landmark(
            points: landmarks.faceContour?.normalizedPoints,
            to: result.boundingBox) {
            faceView.faceContour = faceContour
        }
    }
    
    // Define a new method that will update the LaserView. It’s a bit like updateFaceView(for:).
    func updateLaserView(for result: VNFaceObservation) {
        // Clear the LaserView.
        laserView.clear()
        
        // Get the yaw from the result. The yaw is a number that tells you how much your face is turned. If it’s negative, you’re looking to the left. If it’s positive, you’re looking to the right.
        let yaw = result.yaw ?? 0.0
        
        // Return if the yaw is 0.0. If you’re looking straight forward, no face lasers. 😞
        if yaw == 0.0 {
            return
        }
        
        // Create an array to store the origin points of the lasers.
        var origins: [CGPoint] = []
        
        // Add a laser origin based on the left pupil.
        if let point = result.landmarks?.leftPupil?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }
        
        // Add a laser origin based on the right pupil.
        if let point = result.landmarks?.rightPupil?.normalizedPoints.first {
            let origin = landmark(point: point, to: result.boundingBox)
            origins.append(origin)
        }
        
        // Calculate the average y coordinate of the laser origins.
        let avgY = origins.map { $0.y }.reduce(0.0, +) / CGFloat(origins.count)
        
        // Determine what the y coordinate of the laser focus point will be based on the average y of the origins.
        // If your pupils are above the middle of the screen, you'll shoot down.
        // Otherwise, you'll shoot up. You calculated midY in viewDidLoad().
        let focusY = (avgY < midY) ? 0.75 * maxY : 0.25 * maxY
        
        // Calculate the x coordinate of the laser focus based on the yaw. If you're looking left, you should shoot lasers to the left.
        let focusX = (yaw.doubleValue < 0.0) ? -100.0 : maxX + 100.0
        
        // Create a CGPoint from your two focus coordinates.
        let focus = CGPoint(x: focusX, y: focusY)
        
        // Generate some Lasers and add them to the LaserView.
        for origin in origins {
            let laser = Laser(origin: origin, focus: focus)
            laserView.add(laser: laser)
        }
        
        // Tell the iPhone that the LaserView should be redrawn.
        DispatchQueue.main.async {
            self.laserView.setNeedsDisplay()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Get the image buffer from the passed in sample buffer.
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Create a face detection request to detect face bounding boxes and pass the results to a completion handler.
        let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        
        // Use your previously defined sequence request handler to perform your face detection request on the image.
        // The orientation parameter tells the request handler what the orientation of the input image is.
        do {
            try sequenceHandler.perform(
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
    }
}
