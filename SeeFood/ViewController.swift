//
//  ViewController.swift
//  SeeFood
//
//  Created by Adam Nogradi on 07/04/2019.
//  Copyright © 2019 Adam Nogradi. All rights reserved.
//

import UIKit
import VisualRecognition
import SVProgressHUD

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topBarImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let apiKey = "jVsWWWOYQb2y4Nhu9o4sr20Zvth2-l7gkwp4PeQUNpZX"
    let version = "2019-04-09"
    var classificationResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            cameraButton.isEnabled = false
            SVProgressHUD.show()
            
            imageView.image = userPickedImage
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apiKey)
            let imageData = userPickedImage.jpegData(compressionQuality: 0.01)
            visualRecognition.classify(image: UIImage(data: imageData!)!) { (response, error) in
                if let error = error {
                    print(error)
                }
                guard let classes = response?.result?.images.first!.classifiers.first!.classes
                    else {
                        fatalError("Response did not contain classifications!")
                }
                self.classificationResults = []
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].className)
                }
                print (self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                }
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "hotdog")
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "not-hotdog")
                    }
                }
            }
        } else {
            fatalError("Could not pick image")
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

