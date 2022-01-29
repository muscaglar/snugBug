//
//  viewController.swift
//  SnugBug
//
//  Created by Mustafa Caglar on 25/01/2020.
//  Copyright © 2020 ajar.dev. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

extension Array where Element: Equatable {
    func all(where predicate: (Element) -> Bool) -> [Element]  {
        return self.compactMap { predicate($0) ? $0 : nil }
    }
}

class ViewController: UIViewController{
    
    
    @IBOutlet weak var grad: UIButton!
    
    @IBOutlet weak var light: UIButton!

    @IBOutlet weak var slider: UISlider!
    
    
    @IBAction func slideLight(_ sender: Any) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
               guard device.hasTorch else { return }
               do{try device.lockForConfiguration()}
               catch{print("I errored here 1")}

               do{
                   try device.setTorchModeOn(level: Float(slider.value))
                   device.unlockForConfiguration()
               }
                catch { print("Could not set torch level") }
    }

    
    @IBAction func gradDim(_ sender: Any) {
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        
        guard device.hasTorch else { print("I am here2")
            return }
        
        do{try device.lockForConfiguration()}catch{print("I errored here 1")}
 
        do{
            try device.setTorchModeOn(level: 0.01)
            try device.setTorchModeOn(level: 0.1)
            device.unlockForConfiguration()
        }
        catch
        {
            print("I errored here 2")
        }
        

       /* let group = DispatchGroup()
        group.enter()

        DispatchQueue.main.async {
            print("Task 1 started")
            let brighten = self.beginBrighten(device: device, totalTime: 4.0)
            print("Task 1 finished")
            group.leave()
        }
        
        group.notify(queue: .main) {
            print("Task 2 started")
            let dim = self.beginDim(device: device, totalTime: 4.0)
            print("Task 2 finished")
        }*/
       self.begin(device: device)

    }
    
    
    //// 6 breathes per minute
    
     func getBrightenArray() -> [Float]
     {
        var i : Double = 0
        var x = [Float]()
        //x.append(1)
        while (i<=4)
        {   x.append(-0.01306 + 0.01306 * pow(Float(M_E), Float( i) )) 
            i = i + 0.001
        }
        let xNorm = Array(x.sorted())
        return xNorm
    }
    
     func getDecayArray() -> [Float]
     {
        var i : Double = 4
        var x = [Float]()
        //x.append(1)
        while (i<=10)
        {   x.append(0.742 - 0.005 * pow(Float(M_E), Float(0.5*i) )) // 1 -  pow(Float(M_E), Float(-0.5 * i) ) )
            i = i + 0.001
        }
        let xRev = Array(x.sorted().reversed())
        return xRev
    }
 
    
    func begin(device: AVCaptureDevice)
    {
        let xNor = self.getBrightenArray()  // 4 inhale
        let xRev = self.getDecayArray() // 6 exhale
        let z3 = xNor + xRev
        let z2 = z3 + z3
        let z = z2.all(where: { $0 > 0 })

        var i = 0
        let seconds = 0.001
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(seconds), repeats: true)
        {timer in
        
        if(i<z.count-1)
        {
            self.setLight(device: device,lightLevel: z[i])
            i = i + 1
        }
        else
        {
            timer.invalidate()
        }
    }
    }
    
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func setLight(device: AVCaptureDevice, lightLevel: Float)
    {
        do{try device.lockForConfiguration()} catch{print("I errored here 1")}
        do{try device.setTorchModeOn(level: lightLevel)} catch{print("I errored here 2")}
        device.unlockForConfiguration()
    }
    /*
    var flaslightOn = false
    func toggleFlashlight() {
           let device = AVCaptureDevice.default(for: AVMediaType.video)
           
           if let dev = device, dev.hasTorch {
               do {
                   try dev.lockForConfiguration()
                   
                   if (dev.torchMode == AVCaptureDevice.TorchMode.on) {
                       dev.torchMode = AVCaptureDevice.TorchMode.off
                       flaslightOn = false
                       print("Flashlight is disabled.")
                   } else {
                       do {
                        try dev.setTorchModeOn(level: 1.0)
                           flaslightOn = true
                           print("Flashligh is enabled.")
                       } catch {
                           print(error)
                       }
                   }
                   
                   dev.unlockForConfiguration()
               } catch {
                   print(error)
               }
           }
       }*/
    
    private let session = AVCaptureSession()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

  
    
    
}

