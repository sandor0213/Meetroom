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
    
    var timerCount = 0 {
        didSet {
            //            YOURTEXTFIELD.text = "Remaining \(timerCount) minutes"
        }
    }
    
    @AvailableView(iOS 10.0, *)
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
    }
    
    
    
    func showMeeting(time: String) {
        //        if !isShown {
        //        Variables.actualCalendarEvent?.start?.dateTime?.date.timeIntervalSinceNow
        switch time {
        case Variables.actualCalendarEvent?.start?.dateTime?.date.getTime():
            if !isShown {
                self.addQRCodeView()
            }
            break
        case Variables.actualCalendarEvent?.start?.dateTime?.date.getTime():
            if isShown {
            }
            break
        default:
            break
            
        }
    }
    
    
    var timer: Timer?
    func showCurrentTime () {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        dateLbl.text = self.getCurrentDateTime().date
        timeLbl.text = self.getCurrentDateTime().time
        //        self.showMeeting(time: timeLbl.text!)
        self.showMeetingView()
    }
    
    func getCurrentDateTime () -> (date: String, time: String) {
        let date = Date()
        return (date.getTime(timeFormat: Constants.dateFormat), date.getTime())
    }
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.showCurrentTime()
        self.addObservers()
        //        self.getShortLink()
        //      print(Helper.getShortLink())
        Helper.getShortLink { (link, status) in
            if status {
                Variables.shortURL = link
                print(link)
            }
        }
        self.addRefreshControl()
        loginWithGPlus()
        self.initGoogle()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector : #selector(self.changeContainerView(notification:)), name : NSNotification.Name(rawValue : "containerView"), object : nil)
    }
    
    @objc func changeContainerView(notification:Notification) {
        let containerViewInfo = notification.userInfo!["containerView"] as! String
        
        switch containerViewInfo {
        case "AvailableView":
            self.addQRCodeView()
            break
        case "QRCode":
            self.addAvailableView()
            //            self.getEvents(for: self.calendarId)
            
            break
        case "Meeting":
            self.showExtendView()
            break
        case "Extend":
            if let extendMin = notification.userInfo!["extendMin"] as? Int {
                print(extendMin * 60)
                self.updateEvent(extendMin: extendMin * 60)
                self.showMeetingView()
            }
            break
        default:
            break
        }
        
        
    }
    
    @IBAction func bookAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "containerView"), object: nil, userInfo:["containerView": "QRCode"])
    }
    
    
    func addView() {
        
        let AvailableView = AvailableView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        self.containerView.addSubview(AvailableView)
        let qrCode = QRCode(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        //        qrCode.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height)
        qrCode.setUp(url: Variables.shortURL)
        //        self.containerView.addSubview(qrCode)
        let extend = Extend(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        
        //        self.containerView.addSubview(extend)
        
        let meeting = Meeting(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        let titleActual = Variables.actualCalendarEvent?.summary!
        print(titleActual)
        let timeRange = (Variables.actualCalendarEvent?.start?.dateTime?.date.getTime(timeFormat: Constants.starTimeFormat))! + "-" + (Variables.actualCalendarEvent?.end?.dateTime?.date.getTime())!
        let timer = "44"
        meeting.setUp(title: titleActual!, timeRange: timeRange, timer: timer)
        //        self.containerView.addSubview(meeting)
    }
    
    func addAvailableView(){
        let AvailableView = AvailableView(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        self.removeFromSuperView()
        self.containerView.addSubview(AvailableView)
        //        self.actualView = AvailableView
    }
    
    func removeFromSuperView() {
        //        for i in 0...3 {
        self.actualView.0.removeFromSuperview()
        self.actualView.1.removeFromSuperview()
        self.actualView.2.removeFromSuperview()
        self.actualView.3.removeFromSuperview()
        //        }
    }
    func addQRCodeView() {
        //        self.containerView.remove
        let qrCode = QRCode(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        qrCode.setUp(url: Variables.shortURL)
        
        self.removeFromSuperView()
        self.actualView.1 = qrCode
        self.containerView.addSubview(qrCode)
        //        for i in self.actualView {
        //
        //        }
        //        self.actualView.0.removeFromSuperview()
        //        qrCode.removeFromSuperview()
    }
    
    func showExtendView() {
        let extend = Extend(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
        
        self.removeFromSuperView()
        self.actualView.2 = extend
        self.containerView.addSubview(extend)
    }
    
    func showMeetingView() {
        //        if 2 == 3 {
        
        if Variables.actualCalendarEvent != nil {
            
            print(Variables.actualCalendarEvent?.summary)
            print(Variables.actualCalendarEvent?.identifier)
            print((Variables.actualCalendarEvent?.start?.dateTime?.date.timeIntervalSinceNow)!)
            print((Variables.actualCalendarEvent?.end?.dateTime?.date.timeIntervalSinceNow)!)
            
            if (Variables.actualCalendarEvent?.start?.dateTime?.date.timeIntervalSinceNow)! <= 0 && (Variables.actualCalendarEvent?.end?.dateTime?.date.timeIntervalSinceNow)! >= 0 && Variables.actualIdentifier != Variables.actualCalendarEvent!.identifier! {
                Variables.actualIdentifier = Variables.actualCalendarEvent!.identifier!
                let meeting = Meeting(frame: CGRect(x: 0, y: 0, width: self.containerView.frame.width, height: self.containerView.frame.height))
                
                let titleActual = Variables.actualCalendarEvent?.summary!
                let timeRange = (Variables.actualCalendarEvent?.start?.dateTime?.date.getTime(timeFormat: Constants.starTimeFormat))! + "-" + (Variables.actualCalendarEvent?.end?.dateTime?.date.getTime())!
                let timer = "44"
                meeting.setUp(title: titleActual!, timeRange: timeRange, timer: timer)
                
                
                self.removeFromSuperView()
                self.actualView.3 = meeting
                self.containerView.addSubview(meeting)
            }
        }
        //    }
    }
    
    @IBAction func readEvents(_ sender: Any) {
        self.getEvents(for: Configuration.calendarId)
    }
    
    @IBAction func updateEvent(_ sender: Any) {
        //        self.updateEvent()
    }
    
}

extension ViewController {
    
    // CRUD for Events
    func getEvents(for calendarId: String) {
        guard let service = self.calendarService else {
            return
        }
        
        // You can pass start and end dates with function parameters
        let startDateTime = GTLRDateTime(date: Calendar.current.startOfDay(for: Date()))
        let endDateTime = GTLRDateTime(date: Date().addingTimeInterval(60*60*24))
        let eventsListQuery = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
        eventsListQuery.timeMin = startDateTime
        eventsListQuery.timeMax = endDateTime
        
        _ = service.executeQuery(eventsListQuery, completionHandler: { (ticket, result, error) in
            print(result)
            guard error == nil, let items = (result as? GTLRCalendar_Events)?.items else {
                return
            }
            print(items.count)
            let itemsSorted = items.sorted( by: { Double( ($0.start?.dateTime!.date.timeIntervalSince1970)!) < Double (($1.start?.dateTime!.date.timeIntervalSince1970)!)})
            
            Variables.calendarEvents.removeAll()
            for item in itemsSorted {
                print(item.summary!)
                print(item.end?.dateTime!.date.timeIntervalSinceNow)
                print((item.end?.dateTime!.date.timeIntervalSinceNow)! > 0 )
                //                print(item.start?.dateTime!.date.timeIntervalSince1970)
                //                print(Date().timeIntervalSince1970)
                //                print(self.get)
                if item.start?.dateTime?.stringValue.components(separatedBy: "T")[0] == Helper.getCurrentDate() && (item.end?.dateTime!.date.timeIntervalSinceNow)! > 0 {
                    print((item.start?.dateTime!.date.timeIntervalSinceNow)!)
                    print(item.summary)
                    Variables.calendarEvents.append(item)
                }
                print(item.start?.dateTime?.stringValue.components(separatedBy: "T")[0] == Helper.getCurrentDate())
                print(item.start?.dateTime?.stringValue.components(separatedBy: "T")[0])
                print(Helper.getCurrentDate())
                //                if item.start?.dateTime?.stringValue.components(separatedBy: "T")[0] == self.getCurrentDate() {
                
                //                }
                
            }
            print(itemsSorted.count)
            print(Variables.calendarEvents.count)
            self.upNextEventsTV.reloadData()
            
            if itemsSorted.count > 0 {
                //                Variables.actualCalendarEvent = Variables.calendarEvents[0]
                //                self.showMeetingView()
                self.showExtendView()
                //                self.addView()
            }
            
        })
    }
    
    func updateEvent(extendMin: Int) {
        //         if self.firstEventIdForDeletingTest != "" {
        guard let service = self.calendarService else {
            return
        }
        
        print(Variables.calendarEvents)
        
        var newEvent = self.customEvent(extendMin: extendMin)
        print(Variables.actualCalendarEvent?.summary)
        //        print(newEvent.end.)
        let query = GTLRCalendarQuery_EventsUpdate.query(withObject: newEvent, calendarId: Configuration.calendarId, eventId: (Variables.actualCalendarEvent?.identifier!)!)
        service.executeQuery(query, completionHandler: nil)
        self.getEvents(for: Configuration.calendarId)
    }
    
    func customEvent (summary: String = "eee1", extendMin: Int) -> GTLRCalendar_Event {
        //Declares the new event
        var newEvent: GTLRCalendar_Event = GTLRCalendar_Event()
        
        //this is setting the parameters of the new event
        newEvent.summary = Variables.actualCalendarEvent!.summary!
        let startDateTime: GTLRDateTime = GTLRDateTime(date: (Variables.actualCalendarEvent!.start!.dateTime!.date), offsetMinutes: 0)
        let startEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
        startEventDateTime.dateTime = startDateTime
        newEvent.start = startEventDateTime
        //Same as start date, but for the end date
        let endDateTime: GTLRDateTime = GTLRDateTime(date: (Variables.actualCalendarEvent!.end!.dateTime!.date.addingTimeInterval(TimeInterval(extendMin))), offsetMinutes: 0)
        let endEventDateTime: GTLRCalendar_EventDateTime = GTLRCalendar_EventDateTime()
        endEventDateTime.dateTime = endDateTime
        newEvent.end = endEventDateTime
        return newEvent
    }
    
}


extension ViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    func initGoogle() {
        var configureError: NSError?
        if configureError != nil {
            print("Error")
            
        }
        GIDSignIn.sharedInstance().clientID = Configuration.clientID
        GIDSignIn.sharedInstance().scopes = [Configuration.scopes]
        GIDSignIn.sharedInstance().delegate = self
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        self.getEvents(for: Configuration.calendarId)
        self.addAvailableView()
    }
    
    fileprivate func loginWithGPlus() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Variables.calendarEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpNextEventsTableViewCell", for: indexPath) as! UpNextEventsTableViewCell
        
        let timeRange = (Variables.calendarEvents[indexPath.row].start?.dateTime?.date.getTime(timeFormat: Constants.starTimeFormat))! + "-" + (Variables.calendarEvents[indexPath.row].end?.dateTime?.date.getTime())!
        let title = Variables.calendarEvents[indexPath.row].summary!
        
        cell.setUp(timeRange: timeRange, title: title)
        return cell
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh(_ :)), for: UIControl.Event.valueChanged)
        self.upNextEventsTV.addSubview(refreshControl)
    }
    
    @objc func refresh(_ : Any) {
        print("refreshing")
        self.getEvents(for: Configuration.calendarId)
        refreshControl.endRefreshing()
    }
    
}

extension ViewController {
    struct Constants {
        static let cellHeight : CGFloat = 91
        static let starTimeFormat = "hh:mm"
        static let dateFormat = "MMMM d"
    }
    struct Variables {
        static var calendarEvents : [GTLRCalendar_Event] = []
        static var actualCalendarEvent : GTLRCalendar_Event?
        static var eventsInfo : [[String]] = []
        static var shortURL = ""
        static var actualIdentifier = ""
    }
}

