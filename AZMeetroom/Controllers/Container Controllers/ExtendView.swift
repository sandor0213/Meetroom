//
//  ExtendView.swift
//  AZMeetroom
//
//  Created by Balogh Sandor on 5/27/19.
//  Copyright © 2019 AdlerBalogh. All rights reserved.
//

import UIKit

class ExtendView: UIView {
    
    @IBOutlet weak var m5: UIButton!
    @IBOutlet weak var m10: UIButton!
    @IBOutlet weak var m15: UIButton!
    @IBOutlet weak var m30: UIButton!
    @IBOutlet weak var m45: UIButton!
    @IBOutlet weak var m60: UIButton!
    
    weak var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib    = UINib(nibName: "ExtendView", bundle: bundle)
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
    
    @IBAction func extendTime(_ sender: UIButton) {
        Variables.extendMin = sender.tag
    }
    
    
    @IBAction func btnAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "containerView"), object: nil, userInfo:["containerView": "Extend", "extendMin" : Variables.extendMin])
    }
}

extension ExtendView {
    struct Variables {
        static var extendMin = 0
    }
}


