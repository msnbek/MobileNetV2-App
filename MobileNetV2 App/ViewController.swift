//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Mahmut Şenbek on 16.11.2022.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var choosenImage = CIImage()
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func changeButton(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
      
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
          if let ciImage = CIImage(image: imageView.image!) {
             choosenImage = ciImage
    }
     recognizeImage(image: choosenImage)

    }
  
    
    func recognizeImage(image: CIImage) {
        
        resultLabel.text = "Finding.."
        //request
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                
                if let result = vnrequest.results as? [VNClassificationObservation] {
                    if result.count > 0 {
                        let topResult = result.first
                        
                        DispatchQueue.main.async {
                            
                            let percentLevel = String(format: "%.2f", (topResult?.confidence ?? 0) * 100)
                            
                            
                            self.resultLabel.text = "\(percentLevel)% it's \(topResult!.identifier)"
                            
                        }
                        
                    }
                    
                }
                
            }
            //Handler
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                }catch {
                    print(error)
                }
            }
        }
  
        
    }
   
}
     
