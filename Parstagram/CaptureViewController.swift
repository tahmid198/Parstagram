//
//  CaptureViewController.swift
//  Parstagram
//
//  Created by Tahmid Zaman on 3/12/21.
//

import UIKit
import AlamofireImage
import Parse

//UIImagePickerControllerDelegate will give camera events
class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //Saves a post/parse
    @IBAction func onSubmitButton(_ sender: Any) {
        let post = PFObject(className: "Posts") //Objects works just like dictionaries in this case
        
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground{(success,error) in //Saves in parse, reads dictionary and creates the table for you
            if success{
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            }else {
                    print("error!")
                }
            }
        }
        
        
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self //When user is done taking a photo it gets called back
        picker.allowsEditing = true //Allows user to edit after photo is taken
        
        //If camera is available use it else use photo library.
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        imageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}
