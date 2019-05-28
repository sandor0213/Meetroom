//
//  ViewController.swift
//  AZMeetroom
//
//  Created by Balogh Sandor on 5/27/19.
//  Copyright © 2019 AdlerBalogh. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class ViewController: UIViewController {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var meetroomTitleLbl: UILabel!
    @IBOutlet weak var upNextEventsTV : UITableView!
    @IBOutlet weak var containerView: UIView!
    
    var refreshControl = UIRefreshControl()
    
    var actualView : (AvailableView, QRCodeView, ExtendView, MeetingView) = (AvailableView.init(frame: CGRect.zero), QRCodeView.init(frame: CGRect.zero), ExtendView.init(frame: CGRect.zero), MeetingView.init(frame: CGRect.zero))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    /// Creates calendar service with current authentication
    fileprivate lazy var calendarService: GTLRCalendarService? = {
        let service = GTLRCalendarService()
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them
        service.shouldFetchNextPages = true
        // Have the service object set tickets to retry temporary error conditions
        // automatically
        service.isRetryEnabled = true
        service.maxRetryInterval = 15
        
        guard let currentUser = GIDSignIn.sharedInstance().currentUser,
            let authentication = currentUser.authentication else {
                return nil
        }
        service.authorizer = authentication.fetcherAuthorizer()
        return service
    }()
    
    

}

