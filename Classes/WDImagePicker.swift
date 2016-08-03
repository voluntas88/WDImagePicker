//
//  WDImagePicker.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit

@objc public protocol WDImagePickerDelegate {
    optional func imagePicker(imagePicker: WDImagePicker, pickedImage: UIImage?)
    optional func imagePickerDidCancel(imagePicker: WDImagePicker)
}

@objc public class WDImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WDImageCropControllerDelegate {
    public var delegate: WDImagePickerDelegate?
    public var cropSize = CGSizeMake(320, 320)
    public var resizableCropArea = false
    public var imagePickerController = UIImagePickerController()
    public static var toolbarHeight:CGFloat {
        return CGFloat(44.0)
    }
    public init(sourceType: UIImagePickerControllerSourceType) {
        super.init()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
    }

    private func hideController() {
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }

    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        if self.delegate?.imagePickerDidCancel != nil {
            self.delegate?.imagePickerDidCancel?(self)
        } else {
            self.hideController()
        }
    }

    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let cropController = WDImageCropViewController()
            cropController.set(image,
                               resizableCropArea: resizableCropArea,
                               cropSize: cropSize,
                               delegate: self,
                               strings: nil)
            picker.pushViewController(cropController, animated: true)
        }
        
    }

    func imageCropController(imageCropController: WDImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage?) {
        self.delegate?.imagePicker?(self, pickedImage: croppedImage)
    }
}
