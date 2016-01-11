//
//  CameraHolder.swift
//  MtpClockSync
//
//  Created by Felipe G Almeida on 12/23/15.
//  Copyright © 2015 galmeida. All rights reserved.
//

import AppKit
import Foundation
import ImageCaptureCore

class Device : Hashable {
    private let camera:ICCameraDevice
    let syncSupported:Bool
    let icon:NSImage?
    let hashValue:Int
    var name:String

    init(forCamera camera: ICCameraDevice) {
        self.camera = camera
        self.hashValue = camera.hashValue

        if let name = self.camera.name {
            self.name = name
        } else {
            self.name = "unknown"
        }

        if let image = self.camera.icon {
            self.icon = NSImage(CGImage: image, size: NSSize(width: 400, height: 400))
        } else {
            self.icon = nil
        }

        self.syncSupported = camera.capabilities.contains("ICCameraDeviceCanSyncClock")
    }

    func syncClock() {
        if (self.syncSupported) {
            self.camera.requestSyncClock()
        }
    }
}

func ==(lhs: Device, rhs: Device) -> Bool {
    return (lhs.camera == rhs.camera)
}