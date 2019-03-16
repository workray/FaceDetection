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
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
}
