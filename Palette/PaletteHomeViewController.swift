//
//  ViewController.swift
//  Palette
//
//  Created by Patrick Cook on 8/1/18.
//  Copyright © 2018 Patrick Cook. All rights reserved.
//

import UIKit

class PaletteHomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedIndex = 0
    var palette: [UIColor] = [.black, .black, .black, .black, .black, .black]
    weak var circleLayer: CAShapeLayer?
    var circleCenter = CGPoint.zero
    var circleRadius: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(gesture:)))
        
        imageView.addGestureRecognizer(tap)
        imageView.addGestureRecognizer(pan)
        
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as! ColorCell
        
        cell.colorView.backgroundColor = palette[indexPath.row]
        
        return cell
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let location = sender?.location(in: imageView)

        palette[selectedIndex] = imageView.image!.getPixelColor(atLocation: location!, withFrameSize: imageView.frame.size)
        
        let overlayLocation: CGPoint? = sender?.location(in: sender?.view)
        // if there was a previous circle, get rid of it
        circleLayer?.removeFromSuperlayer()
        // create new CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = makeCircle(atLocation: overlayLocation!, radius: 50.0)?.cgPath
        shapeLayer.strokeColor = palette[selectedIndex].cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 3.0
        // Add CAShapeLayer to our view
        sender?.view?.layer.addSublayer(shapeLayer)
        // Save this shape layer in a class property for future reference,
        // namely so we can remove it later if we tap elsewhere on the screen.
        circleLayer = shapeLayer
        
        collectionView.reloadData()
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer? = nil) {
        let location = gesture?.location(in: imageView)
        
        palette[selectedIndex] = imageView.image!.getPixelColor(atLocation: location!, withFrameSize: imageView.frame.size)
        
        var oldCenter: CGPoint = CGPoint()
        if gesture?.state == .began {
            var location: CGPoint? = gesture?.location(in: gesture?.view)
            let translation: CGPoint? = gesture?.translation(in: gesture?.view)
//            location?.x -= translation?.x ?? 0.0
//            location?.y -= translation?.y ?? 0.0
            let x: CGFloat = (location?.x ?? 0.0) - circleCenter.x
            let y: CGFloat = (location?.y ?? 0.0) - circleCenter.y
            let distance = sqrtf(Float(x * x + y * y))
            if CGFloat(distance) < circleRadius {
                oldCenter = circleCenter
            }
        } else if gesture?.state == .changed {
            let translation: CGPoint? = gesture?.translation(in: gesture?.view)
            let newCenter = CGPoint(x: oldCenter.x + (translation?.x ?? 0.0), y: oldCenter.y + (translation?.y ?? 0.0))
            
            circleLayer?.path = makeCircle(atLocation: newCenter, radius: circleRadius)?.cgPath
        }
        
        collectionView.reloadData()
    }
    
    /*
     * Opens photo picker and handles setting of chosen images
     */
    
    func showPhotoSelectorView() {
        let camera = DSCameraHandler(delegate_: self)
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        optionMenu.popoverPresentationController?.sourceView = self.view
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (alert : UIAlertAction!) in
            camera.getCameraOn(self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (alert : UIAlertAction!) in
            camera.getPhotoLibraryOn(self, canEdit: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert : UIAlertAction!) in
        }
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func makeCircle(atLocation location: CGPoint, radius: CGFloat) -> UIBezierPath? {
        circleCenter = location
        circleRadius = radius
        let path = UIBezierPath()
        path.addArc(withCenter: circleCenter, radius: circleRadius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
        return path
    }
    
    @IBAction func openPhotoPickerTapped(_ sender: Any) {
        showPhotoSelectorView()
    }
}
