//
//  AddImageViewController.swift
//  BluetoothLaptop
//
//  Created by Patty Case on 3/26/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit
import AVFoundation

class AddImageViewController: UIViewController, UINavigationControllerDelegate {
    
    var useCamera : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickImageSourceAlert()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is PairComputerViewController
        {
            let vc = segue.destination as? PairComputerViewController
            vc?.useCamera = self.useCamera
            if (self.useCamera) {
                vc?.imagePicker.sourceType = .camera
            } else {
                vc?.imagePicker.sourceType = .photoLibrary
            }
            vc?.navigationItem.title = String.TAKE_A_PICTURE
        }
    }
    
    /**
     Displays an alert to choose either the camera or the photo library as the image source
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func pickImageSourceAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.CAMERA_OR_PHOTO, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        alert.addAction(UIAlertAction(title: String.CAMERA, style: .default, handler: { (UIAlertAction) in
            self.useCamera = true
            self.navigationItem.title = String.TAKE_A_PICTURE
            self.performSegue(withIdentifier: "showPairComputerView", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: String.PHOTO_LIBRARY, style: .default, handler: { (UIAlertAction) in
            self.useCamera = false
            self.navigationItem.title = String.SELECT_A_PICTURE
            self.performSegue(withIdentifier: "showPairComputerView", sender: self)
        }))
        self.present(alert,animated: true, completion: nil )
    }
}
