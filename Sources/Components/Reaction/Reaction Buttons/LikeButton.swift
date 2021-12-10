//
//  LikeButton.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 24/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream
//import Firebase

/// A like button.
open class LikeButton: ReactionButton {
    
    /// Creates an instance of the like button.
    public static func make(frame: CGRect = CGRect(x: 0, y: 0, width: 44, height: 44)) -> LikeButton {
        let button = LikeButton(frame: frame)
        button.setImage(.likeInactiveIcon, for: .normal)
        button.setImage(.likeInactiveIcon, for: .disabled)
        button.setImage(.likeIcon, for: .highlighted)
        button.setImage(.likeIcon, for: .selected)
        return button
    }
    
    /// Likes an activity.
    open func like<T: ActivityProtocol, U: UserProtocol>(_ activity: T,
                                                         presenter: ReactionPresenterProtocol,
                                                         likedReaction: T.ReactionType? = nil,
                                                         parentReaction: T.ReactionType? = nil,
                                                         userTypeOf userType: U.Type,
                                                         _ completion: @escaping ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U>,
                T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable{
            react(with: presenter,
                  activity: activity.original,
                  reaction: likedReaction ?? activity.original.userLikedReaction,
                  parentReaction: parentReaction,
                  kindOf: .like,
                  userTypeOf: T.ReactionType.UserType.self) {
                    if let result = try? $0.get() {
                        let title: String
                        
                        if let parentReaction = parentReaction {
                            let count = parentReaction.childrenCounts[.like] ?? 0
                            title = count > 0 ? String(count) : ""
                        } else {
                            let count = result.activity.original.likesCount
                            title = count > 0 ? String(count) : ""
                        }
                        
                        result.button.setTitle(title, for: .normal)
                        completion(nil)
                    } else {
                        completion($0.error)
                    }
            }
            if !activity.isUserLiked{
                Client.shared.add(reactionTo: activity.id,
                                             parentReactionId: parentReaction?.id,
                                             kindOf: .like_n,
                                             targetsFeedIds: [FeedId(feedSlug: "notification", userId: activity.actor.id)]) {_ in
                                               completion(nil)
                           }
                var data:[String: Any] = ["feedID": activity.id,"schoolName": activity.actor.name]
                var isEvent = false
                if activity.verb == .event_r || activity.verb == .event{
                    data["isEvent"] = true
                    isEvent = true
                }else{
                    data["isEvent"] = false
                }
                if let textRepresentable = activity as? TextRepresentable {
                    if let jsonData = textRepresentable.text!.data(using: .utf8)
                    {
                        if isEvent{
                            let decoder = JSONDecoder()
                            do {
                                let event = try decoder.decode(EventDecode.self, from: jsonData)
                                data["content"] = event.title
                            } catch {
                                print(error.localizedDescription)
                            }
                        }else{
                            data["content"] = textRepresentable.text!
                        }
                        
                    }
                }
                NotificationCenter.default.post(name: Notification.Name("recordFeedLike"), object: nil, userInfo: data)
                
            }
           
    }
}

/// An event button.
open class EventButton: ReactionButton {
    
    /// Creates an instance of the event button.
    public static func make(frame: CGRect = CGRect(x: 0, y: 0, width: 44, height: 44)) -> EventButton {
        let button = EventButton(frame: frame)
        button.setImage(.registerInactiveIcon, for: .normal)
        button.setImage(.registerInactiveIcon, for: .disabled)
        button.setImage(.registerIcon, for: .highlighted)
        button.setImage(.registerIcon, for: .selected)
        return button
    }
    

    
    /// Register an event.
    open func register<T: ActivityProtocol, U: UserProtocol>(_ activity: T,
                                                            presenter: ReactionPresenterProtocol,
                                                            likedReaction: T.ReactionType? = nil,
                                                            parentReaction: T.ReactionType? = nil,
                                                            userTypeOf userType: U.Type,
                                                            _ completion: @escaping ErrorCompletion)
        where T.ReactionType == GetStream.Reaction<ReactionExtraData, U>,
        T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable{
            
            if (activity.verb == .event_r || activity.verb == .event) && !activity.eventID!.isEmpty && !activity.firebaseUserID!.isEmpty{
                var eventName = ""
                if let textRepresentable = activity as? TextRepresentable {
                    if let jsonData = textRepresentable.text!.data(using: .utf8)
                    {
                        let decoder = JSONDecoder()
                        do {
                            let event = try decoder.decode(EventDecode.self, from: jsonData)
                            eventName = event.title
                        } catch {
                            print(error.localizedDescription)
                        } 
                    }
                }
                let data:[String: String] = ["eventID": activity.eventID!,"userID": activity.firebaseUserID!,"schoolID": activity.firebaseSchoolID!, "eventName": eventName, "hostName": activity.actor.name, "registerRequired": (activity.verb == .event_r ? "true" : "false")]
                NotificationCenter.default.post(name: Notification.Name("eventAlert"), object: nil, userInfo: data)
                /*if registeredEventIDs.contains(activity.eventID!){
                    self.setTitle("Unregistering...", for: .normal)
                }else{
                    self.setTitle("Registering...", for: .normal)
                }*/
                completion(nil)
            }
    }
}

struct EventDecode: Codable {
    var title:String
    var description:String
    var startTime:String
    var endTime:String
    var address:String
    var website:String
    var registerRequired:Bool
}




