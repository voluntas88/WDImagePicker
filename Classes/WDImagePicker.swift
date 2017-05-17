//
//  WDImagePicker.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit

@objc public protocol WDImagePickerDelegate {
    @objc optional func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage?)
    @objc optional func imagePickerDidCancel(_ imagePicker: WDImagePicker)
}

@objc open class WDImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WDImageCropControllerDelegate {
    open var delegate: WDImagePickerDelegate?
    open var cropSize = CGSize(width: 320, height: 320)
    open var resizableCropArea = false
    open var imagePickerController = UIImagePickerController()
    fileprivate var strings:(title:String, use:String, cancel:String, hint:String)?
    open static var toolbarHeight:CGFloat {
        return CGFloat(44.0)
    }
    public init(sourceType: UIImagePickerControllerSourceType, strings:(title:String, use:String, cancel:String, hint:String) = ("title", "use", "cancel", "hint")) {
        super.init()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        self.strings = strings
    }

    fileprivate func hideController() {
        imagePickerController.dismiss(animated: true, completion: nil)
    }

    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if self.delegate?.imagePickerDidCancel != nil {
            self.delegate?.imagePickerDidCancel?(self)
        } else {
            self.hideController()
        }
    }

    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let cropController = WDImageCropViewController()
            cropController.set(image,
                               resizableCropArea: resizableCropArea,
                               cropSize: cropSize,
                               delegate: self,
                               strings: strings)
            picker.pushViewController(cropController, animated: true)
        }
        
    }

    func imageCropController(_ imageCropController: WDImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage?) {
        self.delegate?.imagePicker?(self, pickedImage: croppedImage)
    }
}
