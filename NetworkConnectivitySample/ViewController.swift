//
//  ViewController.swift
//  NetworkConnectivitySample
//
//  Created by Alvin George on 3/3/16.
//  Copyright © 2016 Alvin George. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
 @IBOutlet weak var hostNameLabel: UILabel!
 @IBOutlet weak var networkStatus: UILabel!

 var reachability: Reachability?

 override func viewDidLoad() {
  super.viewDidLoad()
  // Do any additional setup after loading the view, typically from a nib.
 }
 override func viewDidAppear(animated: Bool) {

  // Start reachability without a hostname intially
  setupReachability(hostName: nil, useClosures: true)
  startNotifier()

  // After 5 seconds, stop and re-start reachability, this time using a hostname
  let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(5) * NSEC_PER_SEC))
  dispatch_after(dispatchTime, dispatch_get_main_queue()) {
   self.stopNotifier()
   self.setupReachability(hostName: "google.com", useClosures: true)
   self.startNotifier()

   let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(5) * NSEC_PER_SEC))
   dispatch_after(dispatchTime, dispatch_get_main_queue()) {
    self.stopNotifier()
    self.setupReachability(hostName: "invalidhost", useClosures: true)
    self.startNotifier()
   }
  }
 }
  func setupReachability(hostName hostName: String?, useClosures: Bool) {
   hostNameLabel.text = hostName != nil ? hostName : "No host name"

   print("--- set up with host name: \(hostNameLabel.text!)")

   do {
    let reachability = try hostName == nil ? Reachability.reachabilityForInternetConnection() : Reachability(hostname: hostName!)
    self.reachability = reachability
   } catch ReachabilityError.FailedToCreateWithAddress(let address) {
    networkStatus.textColor = UIColor.redColor()
    networkStatus.text = "Unable to create\nReachability with address:\n\(address)"
    return
   } catch {}

   if (useClosures) {
    reachability?.whenReachable = { reachability in
     dispatch_async(dispatch_get_main_queue()) {
      self.updateLabelColourWhenReachable(reachability)
     }
    }
    reachability?.whenUnreachable = { reachability in
     dispatch_async(dispatch_get_main_queue()) {
      self.updateLabelColourWhenNotReachable(reachability)
     }
    }
   } else {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
   }
  }

  func startNotifier() {
   print("--- start notifier")
   do {
    try reachability?.startNotifier()
   } catch {
    networkStatus.textColor = UIColor.redColor()
    networkStatus.text = "Unable to start\nnotifier"
    return
   }
  }

  func stopNotifier() {
   print("--- stop notifier")
   reachability?.stopNotifier()
   NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
   reachability = nil
  }

  func updateLabelColourWhenReachable(reachability: Reachability) {
   print("\(reachability.description) - \(reachability.currentReachabilityString)")
   if reachability.isReachableViaWiFi() {
    self.networkStatus.textColor = UIColor.greenColor()
   } else {
    self.networkStatus.textColor = UIColor.blueColor()
   }

   self.networkStatus.text = reachability.currentReachabilityString
  }

  func updateLabelColourWhenNotReachable(reachability: Reachability) {
   print("\(reachability.description) - \(reachability.currentReachabilityString)")

   self.networkStatus.textColor = UIColor.redColor()

   self.networkStatus.text = reachability.currentReachabilityString
  }

  func reachabilityChanged(note: NSNotification) {
   let reachability = note.object as! Reachability

   if reachability.isReachable() {
    updateLabelColourWhenReachable(reachability)
   } else {
    updateLabelColourWhenNotReachable(reachability)
   }
  }
  deinit {
   stopNotifier()
  }
 override func didReceiveMemoryWarning() {
  super.didReceiveMemoryWarning()
 }
}

