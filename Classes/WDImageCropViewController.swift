//
//  WDImageCropViewController.swift
//  WDImagePicker
//
//  Created by Wu Di on 27/8/15.
//  Copyright (c) 2015 Wu Di. All rights reserved.
//

import UIKit
import CoreGraphics

internal protocol WDImageCropControllerDelegate {
    func imageCropController(_ imageCropController: WDImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage?)
}

internal class WDImageCropViewController: UIViewController {
    fileprivate var sourceImage: UIImage!
    fileprivate var delegate: WDImageCropControllerDelegate?
    fileprivate var cropSize: CGSize!
    fileprivate var resizableCropArea = false

    fileprivate var croppedImage: UIImage?

    fileprivate var imageCropView: WDImageCropView!
    fileprivate var toolbar: UIToolbar = UIToolbar(frame: CGRect.zero)
    fileprivate var strings = (title:"Choose Photo", use:"Use", cancel:"Cancel", hint:"")

    func set(_ sourceImage:UIImage!, resizableCropArea:Bool, cropSize:CGSize, delegate:WDImageCropControllerDelegate, strings:(title:String, use:String, cancel:String, hint:String)?) {
        self.sourceImage = sourceImage
        self.resizableCropArea = resizableCropArea
        self.cropSize = cropSize
        self.delegate = delegate
        if let strings = strings {
            self.strings = strings
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        title = strings.title

        setupNavigationBar()
        setupCropView()
        setupToolbar()

        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        imageCropView.frame = view.bounds
        toolbar.frame = CGRect(x: 0, y: view.frame.height - WDImagePicker.toolbarHeight, width: view.frame.size.width, height: WDImagePicker.toolbarHeight)
    }

    func actionCancel(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }

    func actionUse(_ sender: AnyObject) {
        delegate?.imageCropController(self, didFinishWithCroppedImage: imageCropView.croppedImage())
    }

    fileprivate func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: strings.use, style: .plain, target: self, action: #selector(actionUse))
    }

    fileprivate func setupCropView() {
        imageCropView = WDImageCropView(frame: view.bounds,
                                        resizableCropArea: resizableCropArea,
                                        imageToCrop: sourceImage,
                                        cropSize: cropSize)
        view.addSubview(imageCropView)
    }

    fileprivate func toolbarBackgroundImage() -> UIImage {
        let components: [CGFloat] = [1, 1, 1, 1, 123.0 / 255.0, 125.0 / 255.0, 132.0 / 255.0, 1]

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 320, height: WDImagePicker.toolbarHeight), true, 0)

        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 2)

        context?.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: WDImagePicker.toolbarHeight), options: [])

        let viewImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return viewImage!
    }

    fileprivate func setupToolbar() {
        toolbar.barStyle = .black
        toolbar.tintColor = UIColor.white
        view.addSubview(toolbar)

        let info = UILabel(frame: CGRect.zero)
        info.text = strings.hint
        info.textColor = UIColor.white
        info.sizeToFit()

        let cancel = UIBarButtonItem(title: strings.cancel, style: .plain, target: self, action: #selector(actionCancel))
        let use = UIBarButtonItem(title: strings.use, style: .plain, target: self, action: #selector(actionUse))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let label = UIBarButtonItem(customView: info)
        
        toolbar.setItems([cancel, flex, label, flex, use], animated: false)
    }
}
