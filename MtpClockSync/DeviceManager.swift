//
//  DeviceManager.swift
//  MtpClockSync
//
//  Created by Felipe G Almeida on 12/28/15.
//  Copyright © 2015 galmeida. All rights reserved.
//

import Foundation
import ImageCaptureCore

class DeviceManager {
    private var devices = Array<Device>()
    private var devicesToSync = Set<Device>()
    private var deviceByCamera = Dictionary<ICCameraDevice, Device>()

    var count:Int {
        get {
            return devices.count
        }
    }

    func addDevice(camera: ICCameraDevice) {
        if (deviceByCamera[camera] == nil) {
            let device = Device(forCamera: camera)
            deviceByCamera[camera] = device
            devices.append(device)
            if (device.syncSupported) {
                devicesToSync.insert(device)
            }
        }
    }

    func removeDevice(camera: ICCameraDevice) {
        if let device = deviceByCamera[camera] {
            deviceByCamera.removeValueForKey(camera)
            devicesToSync.remove(device)
            for (index, value) in devices.enumerate() {
                if (value == device) {
                    devices.removeAtIndex(index)
                }
            }
        }
    }

    func refreshDeviceName(camera: ICCameraDevice) {
        if let device = deviceByCamera[camera] {
            if let name = camera.name {
                device.name = name
            }
        }
    }

    func deviceAt(index: Int) -> Device {
        return self.devices[index]
    }

    func syncClocks() {
        for device in devicesToSync {
            device.syncClock()
        }
    }

    func willSync(device: Device) -> Bool {
        return devicesToSync.contains(device)
    }

    func mustSync(deviceAtIndex index: Int) {
        self.mustSync(self.deviceAt(index))
    }

    func mustSync(device: Device) {
        if (devices.contains(device)) {
            self.devicesToSync.insert(device)
        }
    }

    func mustNotSync(deviceAtIndex index: Int) {
        self.mustNotSync(self.deviceAt(index))
    }

    func mustNotSync(device: Device) {
        self.devicesToSync.remove(device)
    }
}