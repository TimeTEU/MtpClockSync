//
//  ViewController.swift
//  MtpClockSync
//
//  Created by Felipe G Almeida on 12/23/15.
//  Copyright © 2015 galmeida. All rights reserved.
//

import Cocoa
import ImageCaptureCore

class ViewController: NSViewController, ICDeviceBrowserDelegate, NSTableViewDataSource, NSTableViewDelegate  {

    @IBOutlet
    var tableView: NSTableView!
    let deviceManager = DeviceManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setDelegate(self)
        self.tableView.setDataSource(self)

        let browseMask = ICDeviceTypeMask(rawValue:
            ICDeviceTypeMask.Camera.rawValue |
                ICDeviceLocationTypeMask.Local.rawValue |
                ICDeviceLocationTypeMask.Shared.rawValue |
                ICDeviceLocationTypeMask.Bonjour.rawValue |
                ICDeviceLocationTypeMask.Bluetooth.rawValue)!;

        let deviceBrowser = ICDeviceBrowser()
        deviceBrowser.delegate = self
        deviceBrowser.browsedDeviceTypeMask = browseMask
        deviceBrowser.start()
    }

    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBAction func click(sender : AnyObject){
        self.deviceManager.syncClocks()
    }

    //NSTableViewDataSource ----------------------------------------------
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return self.deviceManager.count
    }

    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject?
    {
        if let column = tableColumn {
            let device = self.deviceManager.deviceAt(row)
            let cell = column.dataCellForRow(row) as! NSCell
            cell.enabled = device.syncSupported

            switch column.identifier {
            case "Device":
                return device.name

            case "Icon":
                return device.icon

            case "Sync":
                return self.deviceManager.willSync(device)

            default:
                return nil
            }
        }
        return nil
    }

    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        if tableColumn?.identifier == "Sync" {
            if (object as? Int == 1) {
                self.deviceManager.mustSync(deviceAtIndex: row)
            } else {
                self.deviceManager.mustNotSync(deviceAtIndex: row)
            }
        }
    }

    //ICDeviceBrowser ----------------------------------------------------
    @objc internal func deviceBrowser(browser: ICDeviceBrowser, didAddDevice device: ICDevice, moreComing: Bool) {
        if let cameraDevice =  device as? ICCameraDevice {
            self.deviceManager.addDevice(cameraDevice)
            self.tableView.reloadData()
        }
    }

    @objc internal func deviceBrowser(browser: ICDeviceBrowser, didRemoveDevice device: ICDevice, moreGoing: Bool) {
        if let cameraDevice = device as? ICCameraDevice {
            self.deviceManager.removeDevice(cameraDevice)
            self.tableView.reloadData()
        }
    }

    func deviceBrowser(browser: ICDeviceBrowser, deviceDidChangeName device: ICDevice) {
        if let cameraDevice = device as? ICCameraDevice {
            self.deviceManager.refreshDeviceName(cameraDevice)
            self.tableView.reloadData()
        }
    }
}

