//
//  QRCodeView.swift
//  AZMeetroom
//
//  Created by Balogh Sandor on 5/27/19.
//  Copyright © 2019 AdlerBalogh. All rights reserved.
//

import UIKit

class QRCodeView: UIView {
    
    @IBOutlet weak var urlLbl: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    weak var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib    = UINib(nibName: "QRCodeView", bundle: bundle)
        let view   = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func setUp (url: String) {
        if url != "" {
            self.urlLbl.text = url
            if let QRImg = url.createQRCodeImage() {
                self.qrCodeImageView.image = QRImg
            }
        }
    }
    
    @IBAction func btnAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "containerView"), object: nil, userInfo:["containerView": "QRCode"])
    }
}
