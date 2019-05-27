//
//  Extension.swift
//  AZMeetroom
//
//  Created by Balogh Sandor on 5/27/19.
//  Copyright © 2019 AdlerBalogh. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func createQRCodeImage() -> UIImage? {
        if self != "" {
            var qrcodeImage: UIImage!
            let data = self.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter?.setValue(data, forKey: "inputMessage")
            if let filter = filter {
                filter.setValue("H", forKey: "inputCorrectionLevel")
                
                let transform = CGAffineTransform(scaleX: 9, y: 9)
                let img = UIImage(ciImage: (filter.outputImage?.transformed(by: transform))!)
                qrcodeImage = img.getImage()
                return qrcodeImage
            }
        }
        return nil
    }
    
}


extension UIImage {
    
    func getImage(backgroundColor: UIColor = UIColor.red) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        backgroundColor.setFill()
        let rect = CGRect(origin: .zero, size: self.size)
        let path = UIBezierPath(arcCenter: CGPoint(x:rect.midX, y:rect.midY), radius: rect.midX, startAngle: 0, endAngle: 6.28319, clockwise: true)
        path.fill()
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}

