//
//  MeetingView.swift
//  AZMeetroom
//
//  Created by Balogh Sandor on 5/27/19.
//  Copyright © 2019 AdlerBalogh. All rights reserved.
//

import UIKit

class MeetingView: UIView {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var weekLbl: UILabel!
    @IBOutlet weak var timeRangeLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    
    weak var view: UIView!
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib    = UINib(nibName: "MeetingView", bundle: bundle)
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
    
    func setUp (title: String, timeRange: String, timer: String) {
        self.titleLbl.text = title
        self.weekLbl.text = Constants.week + Helper.getWeekNumber()
        self.timeRangeLbl.text = timeRange
        if #available(iOS 10.0, *) {
            self.startTimer(difference: 10)
        } else {
        }
    }
    
    @IBAction func extendAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "containerView"), object: nil, userInfo:["containerView": "Meeting"])
    }
    
    @IBAction func btnAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "containerView"), object: nil, userInfo:["containerView": "QRCode"])
    }
    
    
    
    var timer: Timer?
    
    var timerCount = 10 {
        didSet {
            self.timerLbl.text = "Remaining \(timerCount) " + (timerCount > 1 ? "minutes" : "minute")
        }
    }
    
    @available(iOS 10.0, *)
    func startTimer(difference: Int) {
        self.timerCount = difference
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(1.0), repeats: true, block: { (timer) in
            self.timerCount -= 1
            if self.timerCount == 0 {
                self.stopTimer()
            }
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "containerView"), object: nil, userInfo:["containerView": "QRCode"])
    }
    
}

extension MeetingView {
    struct Constants {
        static let week = "Week "
    }
}


