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
    func imageCropController(imageCropController: WDImageCropViewController, didFinishWithCroppedImage croppedImage: UIImage?)
}

internal class WDImageCropViewController: UIViewController {
    private var sourceImage: UIImage!
    private var delegate: WDImageCropControllerDelegate?
    private var cropSize: CGSize!
    private var resizableCropArea = false

    private var croppedImage: UIImage?

    private var imageCropView: WDImageCropView!
    private var toolbar: UIToolbar = UIToolbar(frame: CGRectZero)
    private var strings = (title:"Choose Photo", use:"Use", cancel:"Cancel", hint:"")

    func set(sourceImage:UIImage!, resizableCropArea:Bool, cropSize:CGSize, delegate:WDImageCropControllerDelegate, strings:(title:String, use:String, cancel:String, hint:String)?) {
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

        navigationController?.navigationBarHidden = true
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        imageCropView.frame = view.bounds
        toolbar.frame = CGRectMake(0, CGRectGetHeight(view.frame) - WDImagePicker.toolbarHeight, view.frame.size.width, WDImagePicker.toolbarHeight)
    }

    func actionCancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    func actionUse(sender: AnyObject) {
        delegate?.imageCropController(self, didFinishWithCroppedImage: imageCropView.croppedImage())
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(actionCancel))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: strings.use, style: .Plain, target: self, action: #selector(actionUse))
    }

    private func setupCropView() {
        imageCropView = WDImageCropView(frame: view.bounds,
                                        resizableCropArea: resizableCropArea,
                                        imageToCrop: sourceImage,
                                        cropSize: cropSize)
        view.addSubview(imageCropView)
    }

    private func toolbarBackgroundImage() -> UIImage {
        let components: [CGFloat] = [1, 1, 1, 1, 123.0 / 255.0, 125.0 / 255.0, 132.0 / 255.0, 1]

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(320, WDImagePicker.toolbarHeight), true, 0)

        let context = UIGraphicsGetCurrentContext()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, nil, 2)

        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, WDImagePicker.toolbarHeight), [])

        let viewImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return viewImage
    }

    private func setupToolbar() {
        toolbar.barStyle = .Black
        toolbar.tintColor = UIColor.whiteColor()
        view.addSubview(toolbar)

        let info = UILabel(frame: CGRectZero)
        info.text = strings.hint
        info.textColor = UIColor.whiteColor()
        info.sizeToFit()

        let cancel = UIBarButtonItem(title: strings.cancel, style: .Plain, target: self, action: #selector(actionCancel))
        let use = UIBarButtonItem(title: strings.use, style: .Plain, target: self, action: #selector(actionUse))
        let flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        let label = UIBarButtonItem(customView: info)
        
        toolbar.setItems([cancel, flex, label, flex, use], animated: false)
    }
}
