//
//  PostActionsTableViewCell.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 31/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import Reusable
import GetStream

open class PostActionsTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet public weak var replyButton: UIButton!
    @IBOutlet public weak var repostButton: RepostButton!
    @IBOutlet public weak var likeButton: LikeButton!
    @IBOutlet public weak var eventRegisterButton: EventButton!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    open override func prepareForReuse() {
        reset()
        super.prepareForReuse()
    }
    
    open func reset() {
        replyButton.setTitle(nil, for: .normal)
        repostButton.setTitle(nil, for: .normal)
        likeButton.setTitle(nil, for: .normal)
        
        replyButton.isSelected = false
        likeButton.isSelected = false
        repostButton.isSelected = false
        //eventRegisterButton.isSelected = false
        
        replyButton.removeTap()
        repostButton.removeTap()
        likeButton.removeTap()
        //eventRegisterButton.removeTap()
        
        replyButton.isEnabled = true
        repostButton.isEnabled = true
        likeButton.isEnabled = true
        //eventRegisterButton.isEnabled = true
        
        replyButton.isHidden = true
        repostButton.isHidden = true
        likeButton.isHidden = true
        //eventRegisterButton.isHidden = true
    }
}

// MARK: - Update with Activity

extension PostActionsTableViewCell {
    
    public func updateReply(commentsCount: Int, action: UIControl.Action? = nil) {
        if let action = action {
            replyButton.addTap(action)
        }
        
        if commentsCount > 0 {
            replyButton.setTitle(String(commentsCount), for: .normal)
        }
        
        replyButton.isHidden = false
    }
    
    public func updateRepost(isReposted: Bool, repostsCount: Int, action: UIControl.Action? = nil) {
        if let action = action {
            repostButton.addTap(action)
        }
        
        if repostsCount > 0 {
            repostButton.setTitle(String(repostsCount), for: .normal)
        }
        
        repostButton.isSelected = isReposted
        repostButton.isHidden = false
    }
    
    public func updateLike(isLiked: Bool, likesCount: Int, action: UIControl.Action? = nil) {
        if let action = action {
            likeButton.addTap(action)
        }
        
        if likesCount > 0 {
            likeButton.setTitle(String(likesCount), for: .normal)
        }
        
        likeButton.isSelected = isLiked
        likeButton.isHidden = false
    }
    
    public func updateEvent<T: ActivityProtocol>(presenter: ActivityPresenter<T>, action: UIControl.Action? = nil) {
        if let action = action {
            eventRegisterButton.addTap(action)
        }
        

        if presenter.activity.verb == .event_r || presenter.activity.verb == .event{
            
            var zoomEvent = false
            
            if let textRepresentable = presenter.activity as? TextRepresentable {
                zoomEvent = isZoomEvent(jsonString: textRepresentable.text!)
                let currentTime = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let endTime = getEventEndTime(jsonString: textRepresentable.text!)
                if let eventEndTime = dateFormatter.date(from: convertTorontoTimeToLocalTime(torontoTime: endTime) ) {
                    if eventEndTime <= currentTime{
                        eventRegisterButton.isHidden = true
                    }else{
                        eventRegisterButton.isHidden = false
                    }
                }else{
                    eventRegisterButton.isHidden = true
                }
            }
            
            if registeredEventIDs.contains(presenter.activity.eventID!){
                eventRegisterButton.setImage(zoomEvent ? .zoomIcon : .registerIcon, for: .normal)
            }else{
                eventRegisterButton.setImage(zoomEvent ? .zoomInactiveIcon : .registerInactiveIcon, for: .normal)
            }
        }else if presenter.activity.verb == .repost{
            if presenter.originalActivity.verb == .event_r || presenter.originalActivity.verb == .event{
                var zoomEvent = false
                
                if let textRepresentable = presenter.originalActivity as? TextRepresentable {
                    zoomEvent = isZoomEvent(jsonString: textRepresentable.text!)
                    let currentTime = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let endTime = getEventEndTime(jsonString: textRepresentable.text!)
                    if let eventEndTime = dateFormatter.date(from: convertTorontoTimeToLocalTime(torontoTime: endTime) ) {
                        if eventEndTime <= currentTime{
                            eventRegisterButton.isHidden = true
                        }else{
                            eventRegisterButton.isHidden = false
                        }
                    }else{
                        eventRegisterButton.isHidden = true
                    }
                }
                
                if registeredEventIDs.contains(presenter.originalActivity.eventID!){
                    eventRegisterButton.setImage(zoomEvent ? .zoomIcon : .registerIcon, for: .normal)
                }else{
                    eventRegisterButton.setImage(zoomEvent ? .zoomInactiveIcon : .registerInactiveIcon, for: .normal)
                }
            }
            
        }else{
            eventRegisterButton.isHidden = true
        }

    }
    
    public func isZoomEvent(jsonString:String) -> Bool{
        if let jsonData = jsonString.data(using: .utf8)
        {
            let decoder = JSONDecoder()
            do {
                let event = try decoder.decode(Event.self, from: jsonData)
                return !event.meetingID.isEmpty
            } catch {
                print(error.localizedDescription)
            }
        }
        return false
    }
    
    public func getEventEndTime(jsonString:String) -> String{
            if let jsonData = jsonString.data(using: .utf8)
            {
                let decoder = JSONDecoder()
                do {
                    let event = try decoder.decode(Event.self, from: jsonData)
                    if !event.endTime.isEmpty{
                        return event.endTime
                    }else{
                        return ""
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        return ""
    }
    
    public func converTime(timeStr: String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM dd, yyyy, h:mm a"
        if let date = dateFormatterGet.date(from: timeStr) {
            return(dateFormatterPrint.string(from: date))
        } else {
           return timeStr
        }
        
    }
    func convertTorontoTimeToLocalTime(torontoTime: String) -> String{
        let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         dateFormatter.timeZone = TimeZone(abbreviation: "EDT")
         let localTime = dateFormatter.date(from: torontoTime)
         dateFormatter.timeZone = TimeZone.current
         let timeStamp = dateFormatter.string(from: localTime!)

         return timeStamp
    }
}

// MARK: - Update For ActivityPresenter

extension PostActionsTableViewCell {
    
    public func updateRepost<T: ActivityProtocol, U: UserProtocol>(presenter: ActivityPresenter<T>,
                                                                   targetFeedId feedId: FeedId,
                                                                   userTypeOf userType: U.Type,
                                                                   _ completion: @escaping ReactionButton.ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U> {
            updateRepost(isReposted: presenter.originalActivity.isUserReposted,
                         repostsCount: presenter.originalActivity.repostsCount) {
                            if let button = $0 as? RepostButton {
                                button.repost(presenter.originalActivity,
                                              presenter: presenter.reactionPresenter,
                                              userTypeOf: userType,
                                              targetsFeedIds: [feedId],
                                              completion)
                            }
            }
    }
    
    public func updateLike<T: ActivityProtocol, U: UserProtocol>(presenter: ActivityPresenter<T>,
                                                                 userTypeOf userType: U.Type,
                                                                 _ completion: @escaping ReactionButton.ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U>,
                T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable{
            updateLike(isLiked: presenter.originalActivity.isUserLiked,
                       likesCount: presenter.originalActivity.likesCount) {
                        if let button = $0 as? LikeButton {
                            button.like(presenter.originalActivity,
                                        presenter: presenter.reactionPresenter,
                                        userTypeOf: userType,
                                        completion)
                        }
            }
//       Client.shared.add(reactionTo: presenter.activity.id,
//                         kindOf: .comment_n,
//                         targetsFeedIds: [FeedId(feedSlug: "notifications", userId: presenter.activity.actor.)]) { result in /* ... */ }
    }
    
    public func updateEvent<T: ActivityProtocol, U: UserProtocol>(presenter: ActivityPresenter<T>,
                                                                userTypeOf userType: U.Type,
                                                                _ completion: @escaping ReactionButton.ErrorCompletion)
           where T.ReactionType == GetStream.Reaction<ReactionExtraData, U>,
                    T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable{
               updateEvent(presenter: presenter) {
                               if let button = $0 as? EventButton {
                                   button.register(presenter.originalActivity,
                                                   presenter: presenter.reactionPresenter,
                                                   userTypeOf: userType,
                                                   completion)
                               }
               }
    }
    
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
