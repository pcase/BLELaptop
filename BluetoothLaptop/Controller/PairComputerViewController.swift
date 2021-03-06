//
//  PairComputerViewController.swift
//  BluetoothLaptop
//
//  Created by Patty Case on 3/26/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD
import VisualRecognition

class PairComputerViewController: UIViewController, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let apiKey = "41T3884Bc5ufPS3fwMi-PjP4WQA_I8ZF_tfn4WIaJ_Ls"
    let version = "2018-07-17"
    var imagePicker = UIImagePickerController()
    var useCamera : Bool = false
    var timer:Timer?
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        getImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ConfirmationViewController
        {
            let vc = segue.destination as? ConfirmationViewController
            vc?.image = self.imageView.image
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
    
    /**
     Pick image
     
     - Parameter picker:
     info:
     
     - Throws:
     
     - Returns:
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        SVProgressHUD.show()
        
        // Do image recognition
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            let imageData = image.jpegData(compressionQuality: 0.01)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            ((try? imageData?.write(to: fileURL, options: [])) as ()??)
            _ = {
                (error: Error) in print(error)
            }

           visualRecognition.classify(imagesFile: imageData) { response, error in
                
                if let error = error {
                    print(error)
                }
            
                guard let classifiedImages = response?.result else {
                    print("Failed to classify the image")
                    return
                }
            
                let classes = classifiedImages.images.first!.classifiers.first!.classes
            
                self.classificationResults = []

                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                
                print("****** Classified results: ", self.classificationResults)
            
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                     if self.isLaptop(guessList: Array(self.classificationResults.prefix(3))) {
                        self.performSegue(withIdentifier: "showConfirmationView", sender: self)
                    } else {
                        self.showNotLaptopAlert()
                    }
                }
            }
        }
    }
    
    func cropToCenter(image: UIImage) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = contextSize.width
        var cgheight: CGFloat = contextSize.height
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else if contextSize.width < contextSize.height {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        // crop image to square
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func isLaptop(guessList: [String]) -> Bool {
        for index in 0..<guessList.count {
            if isLaptop(guess: guessList[index]) {
                return true
            }
        }
        return false
    }
    
    func isLaptop(guess: String) -> Bool {
        let lowercasedGuess = guess.lowercased()
        if lowercasedGuess.contains(String.LAPTOP.lowercased()) || lowercasedGuess.contains(String.PORTABLE.lowercased()) {
            return true
        } else {
            return false
        }
    }
    
    /**
     Called after image source is specified. If camera is chosen, camera permission is checked, and if allowed, the camera
     is displayed. If photo library is chosen, the photo library is displayed.
     (
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func getImage() {
        
        if (self.useCamera) {
            self.checkCameraPermission()
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
        
        self.navigationItem.title = String.EMPTY
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     Checks camera permission, and displays alert if access is denied or restricted
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
            
        // The user has previously granted access to the camera.
        case .authorized:
            return
            
        // The user has not yet been asked for camera access.
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    return
                }
            }
            
            // denied - The user has previously denied access.
        // restricted - The user can't grant access due to restrictions.
        case .denied, .restricted:
            self.cameraAccessNeededAlert()
            return
            
        default:
            break
        }
    }
    
    /**
     Displays an alert saying that camera access is needed. Allows user to enable the camera.
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func cameraAccessNeededAlert() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: String.NEED_CAMERA,
            message: String.CAMERA_ACCESS_REQUIRED,
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: String.CANCEL, style: .default, handler: { (action) in
            self.noCameraAlert()
        }))
        alert.addAction(UIAlertAction(title: String.ALLOW_CAMERA, style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Displays an alert to say that the photo library will be used instead of the camera
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func noCameraAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.USING_PHOTO_LIBRARY, preferredStyle: .alert)
        alert.isModalInPopover = true
        alert.addAction(UIAlertAction(title: String.OK, style: .default, handler: { (action) in
            self.usePhotoLibrary()
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    /**
     Sets the image picker to use the photo libary as the source
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func usePhotoLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     Displays an alert to notify the image is not a laptop
     
     - Parameter guess: string representing the guess
     
     - Throws:
     
     - Returns:
     */
    func showNotLaptopAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.NOT_LAPTOP, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        alert.addAction(UIAlertAction(title: String.OK, style: .default, handler: { (UIAlertAction) in
            for controller in self.navigationController!.viewControllers as Array {
                if let vc = controller as? ComputerListViewController {
                    vc.currentComputer = nil
                    _ =  self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    /**
     Displays an alert to show the guess
     
     - Parameter guess: string representing the guess
     
     - Throws:
     
     - Returns:
     */
    func showGuessAlert(guess: String) {
        let alert = UIAlertController(title: String.EMPTY, message: String.IS_IT + String.SPACE + String.DOUBLE_QUOTE + guess + String.DOUBLE_QUOTE, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        alert.addAction(UIAlertAction(title: String.YES, style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "showConfirmationView", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: String.NO, style: .default, handler: { (UIAlertAction) in
            for controller in self.navigationController!.viewControllers as Array {
                if let vc = controller as? ComputerListViewController {
                    vc.currentComputer = nil
                    _ =  self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }))
        self.present(alert,animated: true, completion: nil )
    }
}

