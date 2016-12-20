//
//  ViewController.swift
//  tp-product-finder
//
//  Created by Jefferson Bonnaire on 20/12/2016.
//  Copyright © 2016 com.jeffersonbonnaire.tp-product-finder. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices
import Alamofire
import SwiftyJSON

let WatsonAPIKey = ""

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    var safariVC: SFSafariViewController?
    var media: UIImage!
    var newMedia: Bool?
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCapturePhotoOutput()
    var error: NSError?
    
    @IBAction func useCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerControllerSourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.camera
            
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true,
                         completion: nil)
            newMedia = true
        }
    }
    
    func showPageResultWith(keyword: String) {
        let url = NSURL(string: "https://www.travisperkins.co.uk/search?text=\(keyword)")
        safariVC = SFSafariViewController(url: url as! URL)
        safariVC!.delegate = self
        self.present(safariVC!, animated: true, completion: nil)
    }
    
    func calltoIBM() {
        let URL = try! URLRequest(
            url: "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=\(WatsonAPIKey)&version=2016-05-20",
            method: .post,
            headers: ["Accept-Language":"en"]
        )

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            if let imageData = UIImageJPEGRepresentation(self.media, 0.5) {
                multipartFormData.append(imageData,
                                         withName: "images_file",
                                         fileName: "photo.jpeg",
                                         mimeType: "image/jpeg")
            }
        }, with: URL, encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let json = JSON(data: response.data!)
                    if let keyword = json["images"][0]["classifiers"][0]["classes"][0]["class"].string {
                        self.showPageResultWith(keyword: keyword)
                    }
                }

            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    // Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("imagePickerController")
        media = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.dismiss(animated: true, completion: {
            self.calltoIBM()
        })
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        guard error == nil else {
            let alert = UIAlertController(title: "Save Failed",
                                          message: "Failed to save image",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                         completion: nil)
            return
        }
    }
    
    // Safari Delegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

