//
//  UIImage.swift
//  SmartPaper
//
//  Created by Henrik Thoroe on 27.12.19.
//  Copyright © 2019 Henrik Thoroe. All rights reserved.
//

import UIKit

extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func ciImage() -> CIImage? {
        if let image = ciImage {
            return image
        }
        
        if let cgImage = cgImage {
            return CIImage(cgImage: cgImage)
        }
        
        return CIImage(image: self)
    }
    
    func adjustedBrightness(by offset: CGFloat) -> UIImage? {
        guard let image = ciImage() else {
            return nil
        }
        
        let context = CIContext()
        let filter = CIFilter(name: "CIColorControls")
        
        filter?.setValue(image, forKey: "inputImage")
        filter?.setValue(NSNumber(value: Double(offset)), forKey: "inputBrightness")
        
        return UIImage(cgImage: context.createCGImage(filter!.outputImage!, from: CGRect(origin: .zero, size: size))!)
    }
    
    func adjustedSaturation(by offset: CGFloat) -> UIImage? {
        guard let image = ciImage() else {
            return nil
        }
        
        let context = CIContext()
        let filter = CIFilter(name: "CIColorControls")
        
        filter?.setValue(image, forKey: "inputImage")
        filter?.setValue(NSNumber(value: Double(offset)), forKey: "inputBrightness")
        
        return UIImage(cgImage: context.createCGImage(filter!.outputImage!, from: CGRect(origin: .zero, size: size))!)
    }
    
}
