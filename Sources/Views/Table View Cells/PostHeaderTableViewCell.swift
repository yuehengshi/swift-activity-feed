//
//  PostHeaderTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 18/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//
import Foundation
import UIKit
import Nuke
import GetStream
var currentImageIndex : [String:Int] = [:]
extension Notification.Name {
    static let openPersonalFeed = Notification.Name("openPersonalFeed")
}
let POLL_HEIGHT_4 = CGFloat(175)
let POLL_HEIGHT_3 = CGFloat(132)
let POLL_HEIGHT_2 = CGFloat(94)
open class PostHeaderTableViewCell: BaseTableViewCell , UIScrollViewDelegate{

    @IBOutlet public weak var avatarButton: UIButton!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet weak var officalIcon: UIImageView!
    @IBOutlet weak var fosterwayIcon: UIImageView!
    @IBOutlet weak var suggestedIcon: UIButton!
    @IBOutlet private weak var repostInfoStackView: UIStackView!
    @IBOutlet private weak var repostInfoLabel: UILabel!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var messageLabel: UILabel!
    @IBOutlet private weak var messageBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var photoImageView: UIImageView!
    
    
    
    @IBOutlet weak var pollOption1Btn: UIButton!
    @IBOutlet weak var pollOption2Btn: UIButton!
    @IBOutlet weak var pollOption3Btn: UIButton!
    @IBOutlet weak var pollOption4Btn: UIButton!
    
    
    @IBOutlet weak var pollResultView: UIView!
    @IBOutlet weak var pollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pollViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pollResultOption1: UIProgressView!
    @IBOutlet weak var pollResultOption1Label: UILabel!
    @IBOutlet weak var pollResultOption1Percentage: UILabel!
    
    @IBOutlet weak var pollResultOption2: UIProgressView!
    @IBOutlet weak var pollResultOption2Label: UILabel!
    @IBOutlet weak var pollResultOption2Percentage: UILabel!
    
    @IBOutlet weak var pollResultOption3: UIProgressView!
    @IBOutlet weak var pollResultOption3Label: UILabel!
    @IBOutlet weak var pollResultOption3Percentage: UILabel!
    
    @IBOutlet weak var pollResultOption4: UIProgressView!
    @IBOutlet weak var pollResultOption4Label: UILabel!
    @IBOutlet weak var pollResultOption4Percentage: UILabel!
    
    
    @IBOutlet weak var pollInfoLabel: UILabel!
    
    
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet public weak var pageLabel: UILabel!
    @IBOutlet weak var photoPageControl: UIPageControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var activityID = ""
    var urls : [URL] = []
    var images : [UIImage] = []
    var photoGallerySetUp : [String:Bool] = [:]
    
    var eventID = ""
    var schoolID = ""
    var schoolUserID = ""
    
    var eventName = ""
    var eventDescription = ""
    var schoolName = ""
    var pollOptions: [String] = []
    var pollDuration: Int = 0
    var pollEndTimestamp: Int = 0
    public var repost: String? {
        get {
            return repostInfoLabel.text
        }
        set {
            if let reply = newValue {
                repostInfoStackView.isHidden = false
                repostInfoLabel.text = reply
            } else {
                repostInfoStackView.isHidden = true
            }
        }
    }
    
    open override func reset() {
        updateAvatar(with: nil)
        avatarButton.layer.cornerRadius = avatarButton.bounds.width / 2
        avatarButton.removeTap()
        avatarButton.isEnabled = true
        avatarButton.isUserInteractionEnabled = true
        nameLabel.text = nil
        dateLabel.text = nil
        repostInfoLabel.text = nil
        repostInfoStackView.isHidden = true
        messageLabel.text = nil
        messageBottomConstraint.priority = .defaultHigh + 1
        photoImageView.image = nil
        photoImageView.isHidden = true
        urls.removeAll()
        images.removeAll()
        suggestedIcon.layer.cornerRadius = 5
        suggestedIcon.layer.masksToBounds = true
        let subViews = photoScrollView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        photoScrollView.isHidden = true
        pageLabel.isHidden = true
        pageLabel.text = nil
        photoPageControl.isHidden = true
        pollResultView.isHidden = true
        pollViewHeightConstraint.constant = 0
        pollViewBottomConstraint.priority = .defaultLow
        stopActivityIndicator()
    }
    
    private func roundedPollOptionBtn(){
        let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10.0)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskLayerPath.cgPath
        pollResultOption1.layer.mask = maskLayer
        pollResultOption2.layer.mask = maskLayer
        pollResultOption3.layer.mask = maskLayer
        pollResultOption4.layer.mask = maskLayer
        
        pollOption1Btn.layer.borderWidth = 1
        pollOption1Btn.layer.borderColor = UIColor(red: 2, green: 74, blue: 158).cgColor
        pollOption1Btn.layer.cornerRadius = 10
        pollOption2Btn.layer.borderWidth = 1
        pollOption2Btn.layer.borderColor = UIColor(red: 2, green: 74, blue: 158).cgColor
        pollOption2Btn.layer.cornerRadius = 10
        pollOption3Btn.layer.borderWidth = 1
        pollOption3Btn.layer.borderColor = UIColor(red: 2, green: 74, blue: 158).cgColor
        pollOption3Btn.layer.cornerRadius = 10
        pollOption4Btn.layer.borderWidth = 1
        pollOption4Btn.layer.borderColor = UIColor(red: 2, green: 74, blue: 158).cgColor
        pollOption4Btn.layer.cornerRadius = 10
    }
    
    
    
    public func updateAvatar(with image: UIImage?) {
        if let image = image {
            avatarButton.setImage(image, for: .normal)
            avatarButton.contentHorizontalAlignment = .fill
            avatarButton.contentVerticalAlignment = .fill
        } else {
            avatarButton.setImage(.userIcon, for: .normal)
            avatarButton.contentHorizontalAlignment = .center
            avatarButton.contentVerticalAlignment = .center
        }
        
    }
    
    public func updateAvatarBorder(_ withBorder: Bool){
        if withBorder{
            avatarButton.layer.borderWidth = 2
            avatarButton.layer.borderColor = UIColor.red.cgColor
        }else{
            avatarButton.layer.borderWidth = 0
            avatarButton.layer.borderColor = UIColor.white.cgColor
        }
        
    }
    
    public func startActivityIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    public func stopActivityIndicator(){
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    public func updatePhoto(with url: URL) {
        messageBottomConstraint.priority = .defaultLow
        photoImageView.isHidden = false
        
//        ImagePipeline.shared.loadImage(with: url) { [weak self] result in
//            self?.photoImageView.image = try? result.get().image
//        }
    }
    

    public func loadPhoto(index: Int){
        guard urls.count > index else {
            return
        }
        startActivityIndicator()
        ImagePipeline.shared.loadImage(with: urls[index]) { [weak self] result in
            self?.stopActivityIndicator()
            if let response = try? result.get() {
                let image = response.image.resize(with: CGSize(width: UIScreen.main.bounds.size.width, height: 310), crop: .scaleAspectFit)
                if let subViews = self?.photoScrollView.subviews{
                    guard subViews.count > index else {
                        return
                    }
                    if let imageView = subViews[index] as? UIImageView{
                        imageView.image = image
                    }
                }
            }else {
                if let subViews = self?.photoScrollView.subviews{
                    guard subViews.count > index else {
                        return
                    }
                    if let imageView = subViews[index] as? UIImageView{
                        imageView.contentMode = .center
                        imageView.image = UIImage(named: "image_icon")
                    }
                }
            }
        }
    }
    
    public func congigPhotoGallery(){
        configurePageControl()
        configPageLabel()
        setupPhotoGallery()
    }

    public func setupPhotoGallery(){
        photoScrollView.isHidden = false
        photoScrollView.delegate = self
        
        let number = urls.count
        for index in 0..<number {
            var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
            frame.origin.x = photoScrollView.frame.size.width * CGFloat(index)
            frame.size = photoScrollView.frame.size

            let subView = EEZoomableImageView(frame: frame)
            
            photoScrollView.addSubview(subView)
        }
        photoScrollView.contentSize = CGSize(width:photoScrollView.frame.size.width * CGFloat(number),height: photoScrollView.frame.size.height)
        if let index = currentImageIndex[activityID]{
            photoScrollView.contentOffset.x = CGFloat(index) * photoScrollView.frame.size.width
        }
        photoPageControl.addTarget(self, action: #selector(self.changePage(sender:)), for: UIControl.Event.valueChanged)
        photoGallerySetUp[activityID] = true
    }
    
    public func configPageLabel(){
        pageLabel.isHidden = urls.count == 1
        pageLabel.layer.cornerRadius = 5
        pageLabel.layer.masksToBounds = true
        if let index = currentImageIndex[activityID]{
            refreshPageLabel(currentPage: index == 0 ? 1 : (index + 1))
        }
    }
    
    public func refreshPageLabel(currentPage: Int){
        pageLabel.text = String(currentPage) + "/" + String(urls.count)
    }
    
    public func configurePageControl(){
        photoPageControl.isHidden = urls.count == 1
        photoPageControl.layer.zPosition = 1
        photoPageControl.numberOfPages = urls.count
        if let index = currentImageIndex[activityID]{
            photoPageControl.currentPage = index
        }else{
            photoPageControl.currentPage = 0
        }
        photoPageControl.tintColor = UIColor.red
        photoPageControl.pageIndicatorTintColor = UIColor.black
        photoPageControl.currentPageIndicatorTintColor = UIColor(red: 141, green: 213, blue: 44)
    }
    
    @objc public func changePage(sender: AnyObject) -> () {
        let x = CGFloat(photoPageControl.currentPage) * photoScrollView.frame.size.width
        photoScrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
        refreshPageLabel(currentPage: Int(photoPageControl.currentPage)+1)
        loadPhoto(index: Int(photoPageControl.currentPage))
        currentImageIndex[activityID] = Int(photoPageControl.currentPage)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(photoScrollView.contentOffset.x / photoScrollView.frame.size.width)
        currentImageIndex[activityID] = Int(pageNumber)
        photoPageControl.currentPage = Int(pageNumber)
        refreshPageLabel(currentPage: Int(pageNumber)+1)
        loadPhoto(index: Int(pageNumber))
    }
    
    public func getPoll(schoolID: String, schoolUserID: String, eventID: String) {
        if !schoolID.isEmpty && !schoolUserID.isEmpty && !eventID.isEmpty{
            let data:[String: String] = ["eventID": eventID, "userID": schoolUserID, "schoolID": schoolID]
            NotificationCenter.default.post(name: Notification.Name("getPollData"), object: nil, userInfo: data)
        }
    }
    

    public func updatePoll(schoolID: String, schoolUserID: String, eventID: String, pollOptions: [String], isEnded: Bool){

        if pollList.keys.contains(eventID){
            var ownHasSelectedPollOption = false
            var ownSelectedPollOption = 0
            var pollOptions : [String] = []
            var pollResults : [Int] = []
            let poll = pollList[eventID]
       
            if let data = poll as? [String: Any]{
                if let ownHasSelectedPollOption_ = data["ownHasSelectedPollOption"] as? Bool{
                    ownHasSelectedPollOption = ownHasSelectedPollOption_
                }
                if let ownSelectedPollOption_ = data["ownSelectedPollOption"] as? Int{
                    ownSelectedPollOption = ownSelectedPollOption_
                }
                if let pollOptions_ = data["pollOptions"] as? [String]{
                    pollOptions = pollOptions_
                }
                if let pollResults_ = data["pollResults"] as? [Int]{
                    pollResults = pollResults_
                }
            }

            hideUnusedPollOptions(optionNum: pollOptions.count, ownHasSelectedPollOption: ownHasSelectedPollOption, isEnded: isEnded)
            updatePollContent(ownHasSelectedPollOption: ownHasSelectedPollOption, ownSelectedPollOption: ownSelectedPollOption, pollOptions: pollOptions, pollResults: pollResults, isEnded: isEnded)
        }else{
            getPoll(schoolID: schoolID, schoolUserID: schoolUserID, eventID: eventID)
        }
        
    }
    
    
    public func updatePollContent(ownHasSelectedPollOption: Bool, ownSelectedPollOption: Int, pollOptions: [String], pollResults: [Int], isEnded: Bool){
        var totalVotes = 0
        var percentageArr : [Float] = []
        var percentageStrArr : [String] = []
        for result in pollResults{
            totalVotes += result
        }
        var leaderOptions : [Int] = []
        var count = 0
        var maxPercentage = Float(0)
 
//        for result in pollResults{
//
//                let percentage = Float(result) / Float(totalVotes)
//
//                    percentageArr.append(percentage)
//                    if percentage != 0 && percentage >= maxPercentage{
//                        if percentage > maxPercentage{
//                            leaderOptions.removeAll()
//                        }
//                        maxPercentage = percentage
//                        leaderOptions.append(count)
//                    }
//            count += 1
//                    percentageStrArr.append(String(format:"%.1f", percentage * 100) + "%")
//
//
//
//
//
//        }
        
        for result in pollResults{
            if totalVotes == 0{
                percentageArr.append(0)
                percentageStrArr.append("0%")
            }else{
                let percentage = Float(result) / Float(totalVotes)
                if percentage == 0{
                    percentageArr.append(0)
                    percentageStrArr.append("0%")
                }else{
                    percentageArr.append(percentage)
                    if percentage != 0 && percentage >= maxPercentage{
                        if percentage > maxPercentage{
                            leaderOptions.removeAll()
                        }
                        maxPercentage = percentage
                        leaderOptions.append(count)
                    }
                    percentageStrArr.append(String(format:"%.1f", percentage * 100) + "%")
                }
            }

            count += 1

        }
//        for i in 0...3{
//            if percentageArr.count < (i + 1){
//                percentageArr.append(0)
//            }
//            if percentageStrArr.count < (i + 1){0.00997
        
//                percentageStrArr.append("0%")
//            }
//        }
        if ownHasSelectedPollOption || isEnded{
            for i in 0..<pollOptions.count {
                if let label = value(forKey: "pollResultOption"+String(i+1)+"Label") as? UILabel {
                    if leaderOptions.contains(i){
                        label.attributedText = NSMutableAttributedString().bold(pollOptions[i])
                    }else{
                        label.attributedText = NSMutableAttributedString().normal(pollOptions[i])
                    }
                }
            }

            if ownHasSelectedPollOption{
                if let label = value(forKey: "pollResultOption"+String(ownSelectedPollOption+1)+"Label") as? UILabel {
                    label.text = pollOptions[ownSelectedPollOption] + " ☑"
                }
            }
            
            
            for i in 0..<percentageStrArr.count {
                if let percentage = value(forKey: "pollResultOption"+String(i+1)+"Percentage") as? UILabel {
                    if leaderOptions.contains(i){
                        percentage.attributedText = NSMutableAttributedString().bold(percentageStrArr[i])
                    }else{
                        percentage.attributedText = NSMutableAttributedString().normal(percentageStrArr[i])
                    }
                }
            }
            
            for i in 0..<percentageArr.count {
                if let progress = value(forKey: "pollResultOption"+String(i+1)) as? UIProgressView {
                    if leaderOptions.contains(i){
                        progress.layer.cornerRadius = 4
                        progress.progressTintColor = UIColor(red: 141, green: 213, blue: 44)
                    }else{
                        progress.layer.cornerRadius = 4
                        progress.progressTintColor = UIColor(red: 211, green: 211, blue: 211)
                    }
                    progress.progress = percentageArr[i]
                }
            }
            

        }else{
            for i in 0..<pollOptions.count {
                if let btn = value(forKey: "pollOption"+String(i+1)+"Btn") as? UIButton {
                    btn.setAttributedTitle(NSAttributedString(string: pollOptions[i]), for: .normal)
                }
            }
            addPollOptionBtnClickEvent(pollOptions: pollOptions)
            
        }
        
        pollInfoLabel.text = String(totalVotes) + " votes" + " \u{2022} " + (pollInfoLabel.text ?? "")
        
    }
    
    public func addPollOptionBtnClickEvent(pollOptions: [String]){
        for i in 0..<pollOptions.count {
            if let btn = value(forKey: "pollOption"+String(i+1)+"Btn") as? UIButton {
                btn.tag = i
                btn.addTarget(self, action: #selector(pollOptionBtnClicked), for: .touchUpInside)
            }
        }
    }
    
    @objc func pollOptionBtnClicked(_ sender: UIButton) {
        let cTimestamp = Int(NSDate().timeIntervalSince1970)
        if cTimestamp < pollEndTimestamp{
            print(sender.tag, eventID, schoolID, schoolUserID)
            let data:[String: Any] = ["eventID": eventID,"schoolID": schoolID, "schoolUserID": schoolUserID, "selectedPollIndex": sender.tag]
            NotificationCenter.default.post(name: Notification.Name("saveSelectedPollData"), object: nil, userInfo: data)
            
            let data_record:[String: Any] = ["schoolName": schoolName,"eventName": eventName, "eventDescription": eventDescription, "selectedOption": pollOptions.count > (sender.tag) ? pollOptions[sender.tag] : ""]
            NotificationCenter.default.post(name: Notification.Name("recordPollVote"), object: nil, userInfo: data_record)
        }else{
            print("poll ended")
            NotificationCenter.default.post(name: Notification.Name("pollEndedAlert"), object: nil, userInfo: nil)
        }
        
        
    }

    
    public func hideUnusedPollOptions(optionNum: Int, ownHasSelectedPollOption: Bool, isEnded: Bool){
        for i in 1...4{
            if i <= optionNum{
                if let progress = value(forKey: "pollResultOption"+String(i)) as? UIProgressView {
                    if isEnded{
                        progress.isHidden = false
                    }else{
                        progress.isHidden = !ownHasSelectedPollOption
                    }
                    
                }
                if let label = value(forKey: "pollResultOption"+String(i)+"Label") as? UILabel {
                    if isEnded{
                        label.isHidden = false
                    }else{
                        label.isHidden = !ownHasSelectedPollOption
                    }
                    
                }
                if let percentage = value(forKey: "pollResultOption"+String(i)+"Percentage") as? UILabel {
                    if isEnded{
                        percentage.isHidden = false
                    }else{
                        percentage.isHidden = !ownHasSelectedPollOption
                    }
                }
                if let btn = value(forKey: "pollOption"+String(i)+"Btn") as? UIButton {
                    btn.isHidden = ownHasSelectedPollOption || isEnded
                }
            }else{
                if let progress = value(forKey: "pollResultOption"+String(i)) as? UIProgressView {
                    progress.isHidden = true
                }
                if let label = value(forKey: "pollResultOption"+String(i)+"Label") as? UILabel {
                    label.isHidden = true
                }
                if let percentage = value(forKey: "pollResultOption"+String(i)+"Percentage") as? UILabel {
                    percentage.isHidden = true
                }
                if let btn = value(forKey: "pollOption"+String(i)+"Btn") as? UIButton {
                    btn.isHidden = true
                }
            }
        }
    }
    
    public func initPollHeight(optionNum: Int) {
        switch optionNum{
            case 4:
                pollViewHeightConstraint.constant = POLL_HEIGHT_4
                break
            case 3:
                pollViewHeightConstraint.constant = POLL_HEIGHT_3
                break
            case 2:
                pollViewHeightConstraint.constant = POLL_HEIGHT_2
                break
            default:
                pollViewHeightConstraint.constant = POLL_HEIGHT_4
                break
        }
    }

}

extension PostHeaderTableViewCell {
    
    public func update<T: ActivityProtocol>(with activity: T, originalActivity: T? = nil) where T.ActorType: UserNameRepresentable {
        let originalActivity = originalActivity ?? activity
        eventID = originalActivity.eventID ?? ""
        schoolID = originalActivity.firebaseSchoolID ?? ""
        schoolUserID = originalActivity.firebaseUserID ?? ""
        var hasPhoto = false
        nameLabel.text = originalActivity.actor.name
        schoolName = originalActivity.actor.name
//        print("load "+nameLabel.text!)
        

        
        if let textRepresentable = originalActivity as? TextRepresentable {
            if !((activity.eventType ?? "").isEmpty) && !([.virtual, .physical, .news, .poll].contains(activity.eventType)){
                messageLabel.attributedText = formatAttributedEvent_UnsupportedEvent()
            }else{
                if activity.verb == .event || activity.verb == .event_r || originalActivity.verb == .event || originalActivity.verb == .event_r{
    //                messageLabel.text = formatEvent(jsonString: textRepresentable.text!)
                    messageLabel.attributedText = formatAttributedEvent(jsonString: textRepresentable.text!)
                }else{
    //                messageLabel.text = textRepresentable.text
                    if originalActivity.eventType == .poll{
                        messageLabel.attributedText = formatAttributedEvent_PollEvent(jsonString: textRepresentable.text!)
                    }else{
                        messageLabel.attributedText = formatAttributedEvent_NewsEvent(jsonString: textRepresentable.text!)
                    }
                    
                }
            }
        }

        if let object = originalActivity.object as? ActivityObject {
            switch object {
            case .text(let text):
                if activity.verb == .event || activity.verb == .event_r{
                    //messageLabel.text = formatEvent(jsonString: text)
                    //messageLabel.attributedText = formatAttributedEvent(jsonString: text)
                }else if activity.verb == .repost{
                    
                }else{
//                    messageLabel.text = text
                    //messageLabel.attributedText = formatAttributedEvent(jsonString: text)
                }
            case .image(let url):
                hasPhoto = true
                updatePhoto(with: url)
            case .following(let user):
                messageLabel.text = "Follow to \(user.name)"
            default:
                return
            }
        }
        
        if originalActivity.feedType == "topic"{
            if originalActivity.origin == nil{
                self.suggestedIcon.isHidden = true
            }else{
                if originalActivity.origin!.contains("FW") || originalActivity.origin!.contains("-Kx"){
                    self.suggestedIcon.isHidden = true
                }else{
                    self.suggestedIcon.isHidden = false
                }
            }
        }else{
            self.suggestedIcon.isHidden = true
        }
        
//        self.suggestedIcon.isHidden = !(originalActivity.feedType == "topic" && ((originalActivity.origin?.contains("FW")) || originalActivity.origin.contains("-Kx")))

        //if urls.count > 0{
//            updatePhotoGallery(with: urls)
        //}
//        setupPhotoGallery(with: urls)
//        photoScrollView.loadImages(with: urls)
        

            if let index = currentImageIndex[activityID]{
                loadPhoto(index: index)
                refreshPageLabel(currentPage: index + 1)
            }else{
                loadPhoto(index: 0)
                refreshPageLabel(currentPage: 1)
            }

        
        
        
        
        dateLabel.text = activity.time?.relative
        
        if activity.verb == .repost {
            repost = "reposted by \(activity.actor.name)"
        }
        
        
        if activity.eventType == .poll{
            if activity.pollOptions?.count ?? 0 > 0{
                pollOptions = activity.pollOptions ?? []
                initPollHeight(optionNum: activity.pollOptions!.count)
                
                var pollTimeLeftStr = ""
                var timeLeft = 0
                var isEnded = false
                let cTimestamp = Int(NSDate().timeIntervalSince1970)
                pollEndTimestamp = activity.pollEndTimestamp ?? 0
                if cTimestamp < pollEndTimestamp{
                    timeLeft = pollEndTimestamp - cTimestamp
                    if timeLeft <= 300{
                        pollTimeLeftStr = "Ending Soon"
                    }else{
                        let formatter = DateComponentsFormatter()
                        formatter.unitsStyle = .full
                        formatter.allowedUnits = [.day, .hour, .minute] // Units to display in the formatted string
                        formatter.zeroFormattingBehavior = [ .dropLeading ] // Pad with zeroes where appropriate for the locale
                        formatter.includesTimeRemainingPhrase = true
                        let formattedDuration = formatter.string(from: TimeInterval(timeLeft))
                        
                        if formattedDuration != nil{
                            pollTimeLeftStr = formattedDuration!.replacingOccurrences(of: ",", with: "")
                        }else{
                            isEnded = true
                            pollTimeLeftStr = "Final Results"
                        }
                    }
                }else{
                    isEnded = true
                    pollTimeLeftStr = "Final Results"
                }
                
                pollInfoLabel.text = pollTimeLeftStr
                
                hideUnusedPollOptions(optionNum: activity.pollOptions!.count, ownHasSelectedPollOption: false, isEnded: isEnded)
                updatePoll(schoolID: activity.firebaseSchoolID ?? "", schoolUserID: activity.firebaseUserID ?? "", eventID: activity.eventID ?? "", pollOptions: activity.pollOptions!, isEnded: isEnded)
                roundedPollOptionBtn()
                messageBottomConstraint.priority = .defaultLow
                pollViewBottomConstraint.priority = hasPhoto ? .defaultLow : .defaultHigh + 1
                pollResultView.isHidden = false
            }else{
                pollViewHeightConstraint.constant = 0
            }
        }
        
    }
    
    public func updateAvatar<T: AvatarRepresentable>(with avatar: T, action: UIControl.Action? = nil) {
        if let action = action {
            avatarButton.addTap(action)
        } else {
            avatarButton.addTarget(self, action: #selector(self.openUserAllFeeds), for: .touchUpInside)
            avatarButton.isUserInteractionEnabled = true
        }
        
        if let avatarURL = avatar.avatarURL {
            ImagePipeline.shared.loadImage(with: avatarURL.imageRequest(in: avatarButton), completion:  { [weak self] result in
                self?.updateAvatar(with: try? result.get().image)
            })
        }
        
        if avatar.id == "7YZSZNpYOMU2GyRcxS1x152loPW2"{
            fosterwayIcon.image = UIImage(named: "fosterway-logo-app-white")
            self.fosterwayIcon.isHidden = false
        }else{
            self.fosterwayIcon.isHidden = true
        }
        
    
    }
    
    @objc func openUserAllFeeds()
    {
//        let feed = Client.shared.flatFeed(feedSlug: "public", userId: "7YZSZNpYOMU2GyRcxS1x152loPW2")
//        feed.get() { result in
//            try? result.get().results
//        }
        NotificationCenter.default.post(name: .openPersonalFeed, object: nil)
    }
    
    public func formatEvent(jsonString:String) -> String{
        var str = ""
        if let jsonData = jsonString.data(using: .utf8)
        {
            let decoder = JSONDecoder()
            do {
                let event = try decoder.decode(Event.self, from: jsonData)
                str = event.title
                str += "\n"
                str += event.description
                str += "\n"
                str += "Start Time: " + event.startTime
                str += "\n"
                str += "End Time: " + event.endTime
                str += "\n"
                str += event.address
                str += "\n"
                str += event.website
                str += "\n"
                str += event.registerRequired ? "Registration Required(You can find registration button below)" : "Registration Not Required"
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return str
    }
    
    public func formatAttributedEvent_UnsupportedEvent() -> NSMutableAttributedString{
            return NSMutableAttributedString().bold("The app version you have does not support this type of posting. Please update to the current version now.")
    }
    
    public func formatAttributedEvent(jsonString:String) -> NSMutableAttributedString{
        var str = NSMutableAttributedString()
        if let jsonData = jsonString.data(using: .utf8)
        {
            let decoder = JSONDecoder()
            do {
                let event = try decoder.decode(Event.self, from: jsonData)
                
//                str = NSMutableAttributedString().bold(event.title + "\n\n").normal(event.description + "\n\n").mediumBold(converTime(timeStr: event.startTime) + (event.startTime.isEmpty ? "" :"\n")).mediumBold(converTime(timeStr: event.endTime) + (event.endTime.isEmpty ? "" :"\n\n")).normal(event.address + (event.address.isEmpty ? "" :"\n\n")).normal(event.website + (event.website.isEmpty ? "" :"\n\n")).italic(event.registerRequired ? "Register Below" : "Registration Not Required")
//                str = NSMutableAttributedString().bold(event.title + "\n\n").normal(event.description + "\n\n").mediumBold(converTime(timeStr: event.startTime) + (event.startTime.isEmpty ? "" :"\n")).mediumBold(converTime(timeStr: event.endTime) + (event.endTime.isEmpty ? "" :"\n\n")).normal(event.address + (event.address.isEmpty ? "" :"\n\n")).normal(event.website + (event.website.isEmpty ? "" :"\n\n"))
                
                str = NSMutableAttributedString().bold(event.title + "\n\n").normal(event.description + "\n\n").mediumBold(converTime(timeStr: event.startTime) + (event.startTime.isEmpty ? "" :"\n")).mediumBold(converTime(timeStr: event.endTime) + (event.endTime.isEmpty ? "" :"\n\n")).normal(event.address + (event.address.isEmpty ? "" :"\n\n"))
                let currentTime = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                if let eventEndTime = dateFormatter.date(from: convertTorontoTimeToLocalTime(torontoTime: event.endTime) ) {
                    if eventEndTime <= currentTime{
                        str = str.italic("Event date has passed")
                    }else{
                        if event.registerRequired{
                            if event.meetingID.isEmpty{
                                str = str.italic("Register in link below")
                            }else{
                                str = str.italic("Register by clicking Zoom button")
//                                if let status = zoomMeetingStatus[event.meetingID]{
//                                        updateAvatarBorder(status)
//                                }
                                
                            }
                        }
                        //str = event.registerRequired ? (event.meetingID.isEmpty ? str.italic("Register in link below") : str.italic("Register by clicking Zoom button")) : (str.italic(""))
                    }
                }else{
                    str = str.italic("Event date has passed")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return str
    }
    
    public func formatAttributedEvent_NewsEvent(jsonString:String) -> NSMutableAttributedString{
            var str = NSMutableAttributedString()
            if let jsonData = jsonString.data(using: .utf8)
            {
                let decoder = JSONDecoder()
                do {
                    let event = try decoder.decode(Event.self, from: jsonData)
                    
                    str = NSMutableAttributedString().bold(event.title + "\n\n").normal(event.description + "\n\n")
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            return str
    }
    
    public func formatAttributedEvent_PollEvent(jsonString:String) -> NSMutableAttributedString{
            var str = NSMutableAttributedString()
            if let jsonData = jsonString.data(using: .utf8)
            {
                let decoder = JSONDecoder()
                do {
                    let event = try decoder.decode(Event.self, from: jsonData)
                    eventName = event.title
                    eventDescription = event.description
                    str = NSMutableAttributedString().bold(event.title + "\n\n").normal(event.description + "\n\n")
                } catch {
                    print(error.localizedDescription)
                }
            }
            
            return str
    }
    
    public func converTime(timeStr: String) -> String{
        let ogTimeStr = convertTorontoTimeToLocalTime(torontoTime: timeStr)
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM dd, yyyy, h:mm a"
        if let date = dateFormatterGet.date(from: ogTimeStr) {
            return(dateFormatterPrint.string(from: date))
        } else {
           return timeStr
        }
        
    }
    
    func convertTorontoTimeToLocalTime(torontoTime: String) -> String{
        if !torontoTime.isEmpty{
            let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
             dateFormatter.timeZone = TimeZone(abbreviation: "EDT")
             let localTime = dateFormatter.date(from: torontoTime)
             dateFormatter.timeZone = TimeZone.current
             let timeStamp = dateFormatter.string(from: localTime!)
            return timeStamp
        }else{
            return ""
        }
    }
    

}


struct Event: Codable {
    var title:String
    var description:String
    var startTime:String
    var endTime:String
    var address:String
    var website:String
    var registerRequired:Bool
    var meetingID:String
}

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 15 }
    //var boldFont:UIFont { return UIFont(name: "AvenirNext-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var boldFont:UIFont { return UIFont.boldSystemFont(ofSize: fontSize) }
    var mediumFont:UIFont { return UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium) }
    //var normalFont:UIFont { return UIFont(name: "AvenirNext-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    var normalFont:UIFont { return UIFont.systemFont(ofSize: fontSize)}
    
    var italicFont:UIFont { return UIFont.italicSystemFont(ofSize: fontSize) }

    func bold(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func mediumBold(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : mediumFont
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func normal(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func blackHighlight(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func italic(_ value:String) -> NSMutableAttributedString {

       let attributes:[NSAttributedString.Key : Any] = [
            .font : italicFont
        ]


        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

    func underlined(_ value:String) -> NSMutableAttributedString {

        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue

        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

open class EEZoomableImageView: UIImageView {
    
    private var pinchZoomHandler: PinchZoomHandler!
    
    // Public Configurables
    
    var zoomDelegate: ZoomingDelegate? {
        get {
            return pinchZoomHandler.delegate
        } set {
            pinchZoomHandler.delegate = newValue
        }
    }
    
    // Minimum Scale of ImageView
    var minZoomScale: CGFloat {
        get {
            return pinchZoomHandler.minZoomScale
        } set {
            pinchZoomHandler.minZoomScale = abs(min(1.0, newValue))
        }
    }
    
    // Maximum Scale of ImageView
    var maxZoomScale: CGFloat {
        get {
            return pinchZoomHandler.maxZoomScale
        } set {
            pinchZoomHandler.maxZoomScale = abs(max(1.0, newValue))
        }
    }
    
    // Duration of finish animation
    var resetAnimationDuration: Double {
        get {
            return pinchZoomHandler.resetAnimationDuration
        } set {
            pinchZoomHandler.resetAnimationDuration = abs(newValue)
        }
    }
    
    // True when pinching active
    var isZoomingActive: Bool {
        get {
            return pinchZoomHandler.isZoomingActive
        } set { }
    }
    
    // MARK: Private Initializations
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        
        commonInit()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        pinchZoomHandler = PinchZoomHandler(usingSourceImageView: self)
    }
}

public protocol ZoomingDelegate: class {
    func pinchZoomHandlerStartPinching()
    func pinchZoomHandlerEndPinching()
}

private struct PinchZoomHandlerConstants {
    fileprivate static let kMinZoomScaleDefaultValue: CGFloat = 1.0
    fileprivate static let kMaxZoomScaleDefaultValue: CGFloat = 3.0
    fileprivate static let kResetAnimationDurationDefaultValue = 0.3
    fileprivate static let kIsZoomingActiveDefaultValue: Bool = false
}

fileprivate class PinchZoomHandler {
    
    // Configurable
    var minZoomScale: CGFloat = PinchZoomHandlerConstants.kMinZoomScaleDefaultValue
    var maxZoomScale: CGFloat = PinchZoomHandlerConstants.kMaxZoomScaleDefaultValue
    var resetAnimationDuration = PinchZoomHandlerConstants.kResetAnimationDurationDefaultValue
    var isZoomingActive: Bool = PinchZoomHandlerConstants.kIsZoomingActiveDefaultValue
    weak var delegate: ZoomingDelegate?
    weak var sourceImageView: UIImageView?
    
    private var zoomImageView: UIImageView = UIImageView()
    private var initialRect: CGRect = CGRect.zero
    private var zoomImageLastPosition: CGPoint = CGPoint.zero
    private var lastTouchPoint: CGPoint = CGPoint.zero
    private var lastNumberOfTouch: Int?
    
    // MARK: Initialization
    
    init(usingSourceImageView sourceImageView: UIImageView) {
        self.sourceImageView = sourceImageView
        
        setupPinchGesture(on: sourceImageView)
    }
    
    // MARK: Private Methods
    
    private func setupPinchGesture(on pinchContainer: UIView) {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(pinch:)))
        pinchGesture.cancelsTouchesInView = false
        pinchContainer.isUserInteractionEnabled = true
        pinchContainer.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinchGesture(pinch: UIPinchGestureRecognizer) {
        
        guard let pinchableImageView = sourceImageView else { return }
        handlePinchMovement(pinchGesture: pinch, sourceImageView: pinchableImageView)
    }
    
    private func handlePinchMovement(pinchGesture: UIPinchGestureRecognizer, sourceImageView: UIImageView) {
        
        switch pinchGesture.state {
        case .began:
        
            guard !isZoomingActive, pinchGesture.scale >= minZoomScale else { return }
            
            guard let point = sourceImageView.superview?.convert(sourceImageView.frame.origin, to: nil) else { return }
            initialRect = CGRect(x: point.x, y: point.y, width: sourceImageView.frame.size.width, height: sourceImageView.frame.size.height)
            
            lastTouchPoint = pinchGesture.location(in: sourceImageView)
            
            zoomImageView = UIImageView(image: sourceImageView.image)
            zoomImageView.contentMode = sourceImageView.contentMode
            zoomImageView.frame = initialRect

            let anchorPoint = CGPoint(x: lastTouchPoint.x/initialRect.size.width, y: lastTouchPoint.y/initialRect.size.height)
            zoomImageView.layer.anchorPoint = anchorPoint
            zoomImageView.center = lastTouchPoint
            zoomImageView.frame = initialRect
            
            sourceImageView.alpha = 0.0
            UIApplication.shared.keyWindow?.addSubview(zoomImageView)
            
            zoomImageLastPosition = zoomImageView.center
            
            self.delegate?.pinchZoomHandlerStartPinching()
            
            isZoomingActive = true
            lastNumberOfTouch = pinchGesture.numberOfTouches
            
        case .changed:
            let isNumberOfTouchChanged = pinchGesture.numberOfTouches != lastNumberOfTouch
            
            if isNumberOfTouchChanged {
                let newTouchPoint = pinchGesture.location(in: sourceImageView)
                lastTouchPoint = newTouchPoint
            }
            
            let scale = zoomImageView.frame.size.width / initialRect.size.width
            let newScale = scale * pinchGesture.scale
            
            if scale.isNaN || scale == CGFloat.infinity || CGFloat.nan == initialRect.size.width {
                return
            }

            zoomImageView.frame = CGRect(x: zoomImageView.frame.origin.x,
                                         y: zoomImageView.frame.origin.y,
                                         width: min(max(initialRect.size.width * newScale, initialRect.size.width * minZoomScale), initialRect.size.width * maxZoomScale),
                                         height: min(max(initialRect.size.height * newScale, initialRect.size.height * minZoomScale), initialRect.size.height * maxZoomScale))
            
            let centerXDif = lastTouchPoint.x - pinchGesture.location(in: sourceImageView).x
            let centerYDif = lastTouchPoint.y - pinchGesture.location(in: sourceImageView).y
            
            zoomImageView.center = CGPoint(x: zoomImageLastPosition.x - centerXDif, y: zoomImageLastPosition.y - centerYDif)
            pinchGesture.scale = 1.0
            
            // Store last values
            lastNumberOfTouch = pinchGesture.numberOfTouches
            zoomImageLastPosition = zoomImageView.center
            lastTouchPoint = pinchGesture.location(in: sourceImageView)
            
        case .ended, .cancelled, .failed:
            resetZoom()
        default:
            break
        }
    }
    
    private func resetZoom() {
        UIView.animate(withDuration: resetAnimationDuration, animations: {
            self.zoomImageView.frame = self.initialRect
        }) { _ in
            self.zoomImageView.removeFromSuperview()
            self.sourceImageView?.alpha = 1.0
            self.initialRect = .zero
            self.lastTouchPoint = .zero
            self.isZoomingActive = false
            self.delegate?.pinchZoomHandlerEndPinching()
        }
    }
}

class ViewEmbedder {

class func embed(
    parent:UIViewController,
    container:UIView,
    child:UIViewController,
    previous:UIViewController?){

    if let previous = previous {
        removeFromParent(vc: previous)
    }
    child.willMove(toParent: parent)
    parent.addChild(child)
    container.addSubview(child.view)
    child.didMove(toParent: parent)
    let w = container.frame.size.width;
    let h = container.frame.size.height;
    child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
}

class func removeFromParent(vc:UIViewController){
    vc.willMove(toParent: nil)
    vc.view.removeFromSuperview()
    vc.removeFromParent()
}

class func embed(withIdentifier id:String, parent:UIViewController, container:UIView, completion:((UIViewController)->Void)? = nil){
    let vc = parent.storyboard!.instantiateViewController(withIdentifier: id)
    embed(
        parent: parent,
        container: container,
        child: vc,
        previous: parent.children.first
    )
    completion?(vc)
}

}


