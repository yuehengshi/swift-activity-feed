//
//  FeedViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 17/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream
import Reusable
import SnapKit


// Register Event
var registeredEventIDs : [String] = []
var pollList : [String: Any] = [:]
//var pollList : [String: FeedEvent] = [:]

/// A flat feed view controller.
open class FlatFeedViewController<T: ActivityProtocol>: BaseFlatFeedViewController<T>, UITableViewDelegate
    where T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable,
    T.ReactionType == GetStream.Reaction<ReactionExtraData, T.ActorType> {
    
    /// A block type for the removing of an action.
    public typealias RemoveActivityAction = (_ activity: T) -> Void
    /// A banner view to show realtime updates. See `BannerView`.
    public var bannerView: UIView & BannerViewProtocol = BannerView.make()
    private var subscriptionId: SubscriptionId?
    /// A flat feed presenter for the presentation logic.
    public var presenter: FlatFeedPresenter<T>?
    /// A block for the removing of an action.
    public var removeActivityAction: RemoveActivityAction?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRegisteredEvents(_:)), name: Notification.Name("receiveRegisteredEvents"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("passRegisteredEvents"), object: nil, userInfo: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveOwnPollData(_:)), name: Notification.Name("receiveOwnPollData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateOwnPollData(_:)), name: Notification.Name("updateOwnPollData"), object: nil)
        
        
        // sync the latest poll data for updating UI later
        NotificationCenter.default.addObserver(self, selector: #selector(syncLatestPollData_feedProject(_:)), name: Notification.Name("syncLatestPollData_feedProject"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData(_:)), name: Notification.Name("reloadData"), object: nil)
        
        tableView.delegate = self
        //reloadData()
        
        bannerView.addTap { [weak self] in
            $0.hide()
            self?.reloadData()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
 
    }
    
    @objc func reloadData(_ notification: NSNotification){
        reloadData()
    }
    
    @objc func receiveRegisteredEvents(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let IDs = dict["registeredEventIDs"] as? [String]{
                registeredEventIDs = IDs
                reloadData()
            }
        }
    }
    
    @objc func receiveOwnPollData(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let pollData = dict["ownPollData"] as? [String: Any]{
                pollList = pollData
                reloadData()
            }
        }
    }
    
    @objc func updateOwnPollData(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let eventID = dict["eventID"] as? String, let selectedPollIndex = dict["selectedPollIndex"] as? Int{
                if pollList.keys.contains(eventID){
                    var newData : [String: Any] = [:]
                    if let oldData = pollList[eventID] as? [String: Any]{
                        newData["ownHasSelectedPollOption"] = true
                        newData["ownSelectedPollOption"] = selectedPollIndex
                        
                        if let pollOptions_ = oldData["pollOptions"] as? [String]{
                            newData["pollOptions"] = pollOptions_
                        }
                        if let pollResults_ = oldData["pollResults"] as? [Int]{
                            if pollResults_.count > selectedPollIndex{
                                var arr = pollResults_
                                arr[selectedPollIndex] += 1
                                newData["pollResults"] = arr
                            }else{
                                
                            }
                        }
                    }
                    pollList[eventID] = newData
                }
                reloadData()
            }
        }
    }
    
    @objc func syncLatestPollData_feedProject(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let pollData = dict["latestPollData"] as? [String: Any]{
                pollList = pollData
            }
        }
    }
    /// Returns the activity presenter by the table section.
    public func activityPresenter(in section: Int) -> ActivityPresenter<T>? {
        if let presenter = presenter, section < presenter.count {
            return presenter.items[section]
        }
        
        return nil
    }
    
    open override func reloadData() {
        presenter?.load(completion: dataLoaded)
    }
    
    open override func dataLoaded(_ error: Error?) {
        bannerView.hide()
//        tabBarItem.badgeValue = nil
        NotificationCenter.default.post(name: .removeNewsFeedBadge, object: nil)
        
        super.dataLoaded(error)
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        guard let presenter = presenter else {
            return 0
        }
        
        return presenter.count + (presenter.hasNext ? 1 : 0)
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activityPresenter(in: section)?.cellsCount ?? 1
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityPresenter = activityPresenter(in: indexPath.section),
            let cell = tableView.postCell(at: indexPath, presenter: activityPresenter) else {
                if let presenter = presenter, presenter.hasNext {
                    presenter.loadNext(completion: dataLoaded)
                    return tableView.dequeueReusableCell(for: indexPath) as PaginationTableViewCell
                }
                
                return .unused
        }
        
        if let cell = cell as? PostHeaderTableViewCell {
            updateAvatar(in: cell, activity: activityPresenter.originalActivity)
        } else if let cell = cell as? PostActionsTableViewCell {
            updateActions(in: cell, activityPresenter: activityPresenter)
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return removeActivityAction != nil && indexPath.row == 0
    }
    
    open override func tableView(_ tableView: UITableView,
                                 commit editingStyle: UITableViewCell.EditingStyle,
                                 forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
            let removeActivityAction = removeActivityAction,
            let activityPresenter = activityPresenter(in: indexPath.section) {
            removeActivityAction(activityPresenter.activity)
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellType = activityPresenter(in: indexPath.section)?.cellType(at: indexPath.row) else {
            return
        }
        
        if case .attachmentImages(let urls) = cellType {
            //showImageGallery(with: urls)
        } else if case .attachmentOpenGraphData(let ogData) = cellType {
            showOpenGraphData(with: ogData)
            if let activityPresenter = activityPresenter(in: indexPath.section) {
                let activity = activityPresenter.activity
                let data:[String: Any] = ["eventID": activity.eventID,"schoolUid": activity.firebaseUserID,"schoolID": activity.firebaseSchoolID, "hostName": activity.actor.name]

                NotificationCenter.default.post(name: Notification.Name("recordFeedUrlClick"), object: nil, userInfo: data)
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - Subscription for Updates

extension FlatFeedViewController {
    
    /// Subscribes for the realtime updates.
    open func subscribeForUpdates() {
        subscriptionId = presenter?.subscriptionPresenter.subscribe { [weak self] in
            if let self = self, let response = try? $0.get() {
                let newCount = response.newActivities.count
                let deletedCount = response.deletedActivitiesIds.count
                let text: String
                
                if newCount > 0 {
                    text = self.subscriptionNewItemsTitle(with: newCount)
                    //self.tabBarItem.badgeValue = String(newCount)
                    //NotificationCenter.default.post(name: .showNewsFeedBadge, object: nil)
//                    UIApplication.shared.applicationIconBadgeNumber = newCount
                    self.bannerView.show(text, in: self)
                } else if deletedCount > 0 {
                    //text = self.subscriptionDeletedItemsTitle(with: deletedCount)
                    //self.tabBarItem.badgeValue = String(deletedCount)
                } else {
                    return
                }
                
//                self.bannerView.show(text, in: self)
            }
        }
    }
    
    /// Unsubscribes from the realtime updates.
    public func unsubscribeFromUpdates() {
        subscriptionId = nil
    }
    
    /// Return a title of new activies for the banner view on updates.
    open func subscriptionNewItemsTitle(with count: Int) -> String {
        return "You have \(count) new activities"
    }
    
    /// Return a title of removed activities for the banner view on updates.
    open func subscriptionDeletedItemsTitle(with count: Int) -> String {
        return "You have \(count) deleted activities"
    }
}
