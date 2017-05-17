//
//  ViewController.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WDImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    fileprivate var imagePicker: WDImagePicker!
    fileprivate var imagePickerController: UIImagePickerController!

    fileprivate var customCropButton: UIButton!
    fileprivate var normalCropButton: UIButton!
    fileprivate var imageView: UIImageView!
    fileprivate var resizableButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        customCropButton = UIButton()
        customCropButton.frame = UIDevice.current.userInterfaceIdiom == .pad ?
            CGRect(x: 20, y: 20, width: 220, height: 44) :
            CGRect(x: 20, y: customCropButton.frame.maxY + 20 , width: view.bounds.width - 40, height: 44)
        customCropButton.setTitleColor(view.tintColor, for: UIControlState())
        customCropButton.setTitle("Custom Crop", for: UIControlState())
        customCropButton.addTarget(self, action: #selector(ViewController.showPicker(_:)), for: .touchUpInside)
        view.addSubview(customCropButton)

        normalCropButton = UIButton()
        normalCropButton.setTitleColor(view.tintColor, for: UIControlState())
        normalCropButton.setTitle("Apple's Build In Crop", for: UIControlState())
        normalCropButton.addTarget(self, action: #selector(ViewController.showNormalPicker(_:)), for: .touchUpInside)
        view.addSubview(normalCropButton)

        resizableButton = UIButton()
        resizableButton.setTitleColor(view.tintColor, for: UIControlState())
        resizableButton.setTitle("Resizable Custom Crop", for: UIControlState())
        resizableButton.addTarget(self, action: #selector(ViewController.showResizablePicker(_:)), for: .touchUpInside)
        view.addSubview(resizableButton)

        imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.gray
        view.addSubview(imageView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        normalCropButton.frame = UIDevice.current.userInterfaceIdiom == .pad ?
            CGRect(x: 260, y: 20, width: 220, height: 44) :
            CGRect(x: 20, y: customCropButton.frame.maxY + 20 , width: view.bounds.width - 40, height: 44)

        resizableButton.frame = UIDevice.current.userInterfaceIdiom == .pad ?
            CGRect(x: 500, y: 20, width: 220, height: 44) :
            CGRect(x: 20, y: normalCropButton.frame.maxY + 20 , width: view.bounds.width - 40, height: 44)

        imageView.frame = UIDevice.current.userInterfaceIdiom == .pad ?
            CGRect(x: 20, y: 84, width: view.bounds.width - 40, height: view.bounds.height - 104) :
            CGRect(x: 20, y: resizableButton.frame.maxY + 20, width: view.bounds.width - 40, height: view.bounds.height - 20 - (resizableButton.frame.maxY + 20))
    }

    func showPicker(_ button: UIButton) {
        imagePicker = WDImagePicker(sourceType: .photoLibrary)
        imagePicker.cropSize = CGSize(width: 280, height: 280)
        imagePicker.delegate = self

        imagePicker.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePicker.imagePickerController.popoverPresentationController?.sourceView = button
        imagePicker.imagePickerController.popoverPresentationController?.sourceRect = button.bounds
        
        present(imagePicker.imagePickerController, animated: true, completion: nil)
    }

    func showNormalPicker(_ button: UIButton) {
        imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePickerController.popoverPresentationController?.sourceView = button
        imagePickerController.popoverPresentationController?.sourceRect = button.bounds
        
        present(imagePickerController, animated: true, completion: nil)
    }

    func showResizablePicker(_ button: UIButton) {
        imagePicker = WDImagePicker(sourceType: .photoLibrary)
        imagePicker.cropSize = CGSize(width: 280, height: 280)
        imagePicker.delegate = self
        imagePicker.resizableCropArea = true

        imagePicker.imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
        imagePicker.imagePickerController.popoverPresentationController?.sourceView = button
        imagePicker.imagePickerController.popoverPresentationController?.sourceRect = button.bounds
        
        present(imagePicker.imagePickerController, animated: true, completion: nil)
    }

    func imagePicker(_ imagePicker: WDImagePicker, pickedImage: UIImage?) {
        imageView.image = pickedImage
        hideImagePicker()
    }

    func hideImagePicker() {
        imagePicker.imagePickerController.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}

