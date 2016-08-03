//
//  ViewController.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WDImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var imagePicker: WDImagePicker!
    private var imagePickerController: UIImagePickerController!

    private var customCropButton: UIButton!
    private var normalCropButton: UIButton!
    private var imageView: UIImageView!
    private var resizableButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        customCropButton = UIButton()
        customCropButton.frame = UIDevice.currentDevice().userInterfaceIdiom == .Pad ?
            CGRectMake(20, 20, 220, 44) :
            CGRectMake(20, CGRectGetMaxY(customCropButton.frame) + 20 , CGRectGetWidth(view.bounds) - 40, 44)
        customCropButton.setTitleColor(view.tintColor, forState: .Normal)
        customCropButton.setTitle("Custom Crop", forState: .Normal)
        customCropButton.addTarget(self, action: #selector(ViewController.showPicker(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(customCropButton)

        normalCropButton = UIButton()
        normalCropButton.setTitleColor(view.tintColor, forState: .Normal)
        normalCropButton.setTitle("Apple's Build In Crop", forState: .Normal)
        normalCropButton.addTarget(self, action: #selector(ViewController.showNormalPicker(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(normalCropButton)

        resizableButton = UIButton()
        resizableButton.setTitleColor(view.tintColor, forState: .Normal)
        resizableButton.setTitle("Resizable Custom Crop", forState: .Normal)
        resizableButton.addTarget(self, action: #selector(ViewController.showResizablePicker(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(resizableButton)

        imageView = UIImageView(frame: CGRectZero)
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = UIColor.grayColor()
        view.addSubview(imageView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        normalCropButton.frame = UIDevice.currentDevice().userInterfaceIdiom == .Pad ?
            CGRectMake(260, 20, 220, 44) :
            CGRectMake(20, CGRectGetMaxY(customCropButton.frame) + 20 , CGRectGetWidth(view.bounds) - 40, 44)

        resizableButton.frame = UIDevice.currentDevice().userInterfaceIdiom == .Pad ?
            CGRectMake(500, 20, 220, 44) :
            CGRectMake(20, CGRectGetMaxY(normalCropButton.frame) + 20 , CGRectGetWidth(view.bounds) - 40, 44)

        imageView.frame = UIDevice.currentDevice().userInterfaceIdiom == .Pad ?
            CGRectMake(20, 84, CGRectGetWidth(view.bounds) - 40, CGRectGetHeight(view.bounds) - 104) :
            CGRectMake(20, CGRectGetMaxY(resizableButton.frame) + 20, CGRectGetWidth(view.bounds) - 40, CGRectGetHeight(view.bounds) - 20 - (CGRectGetMaxY(resizableButton.frame) + 20))
    }

    func showPicker(button: UIButton) {
        imagePicker = WDImagePicker(sourceType: .PhotoLibrary)
        imagePicker.cropSize = CGSizeMake(280, 280)
        imagePicker.delegate = self

        imagePicker.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.Popover
        imagePicker.imagePickerController.popoverPresentationController?.sourceView = button
        imagePicker.imagePickerController.popoverPresentationController?.sourceRect = button.bounds
        
        presentViewController(imagePicker.imagePickerController, animated: true, completion: nil)
    }

    func showNormalPicker(button: UIButton) {
        imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.Popover
        imagePickerController.popoverPresentationController?.sourceView = button
        imagePickerController.popoverPresentationController?.sourceRect = button.bounds
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }

    func showResizablePicker(button: UIButton) {
        imagePicker = WDImagePicker(sourceType: .PhotoLibrary)
        imagePicker.cropSize = CGSizeMake(280, 280)
        imagePicker.delegate = self
        imagePicker.resizableCropArea = true

        imagePicker.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.Popover
        imagePicker.imagePickerController.popoverPresentationController?.sourceView = button
        imagePicker.imagePickerController.popoverPresentationController?.sourceRect = button.bounds
        
        presentViewController(imagePicker.imagePickerController, animated: true, completion: nil)
    }

    func imagePicker(imagePicker: WDImagePicker, pickedImage: UIImage?) {
        imageView.image = pickedImage
        hideImagePicker()
    }

    func hideImagePicker() {
        imagePicker.imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        imageView.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

