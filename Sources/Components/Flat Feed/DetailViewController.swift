//
//  DetailViewController.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 01/02/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import SnapKit
import GetStream

/// Detail View Controller section types.
public struct DetailViewControllerSectionTypes: OptionSet, Equatable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// An activity section.
    public static let activity = DetailViewControllerSectionTypes(rawValue: 1 << 0)
    /// A likes section.
    public static let likes = DetailViewControllerSectionTypes(rawValue: 1 << 1)
    /// A reposts section.
    public static let reposts = DetailViewControllerSectionTypes(rawValue: 1 << 2)
    /// A comments section.
    public static let comments = DetailViewControllerSectionTypes(rawValue: 1 << 3)
}

/// Detail View Controller section data
public struct DetailViewControllerSection {
    /// A section type.
    public let section: DetailViewControllerSectionTypes
    /// A title of the section.
    public let title: String?
    /// A number of items in section.
    public let count: Int
}

/// Detail View Controller for an activity from `ActivityPresenter`.
///
/// It shows configurable sections of the activity details:
/// - activity content
/// - likes
/// - reposts
/// - comments
///
/// Contains `TextToolBar` for the adding of new comments.
open class DetailViewController<T: ActivityProtocol>: BaseFlatFeedViewController<T>, UITableViewDelegate, UITextViewDelegate
    where T.ActorType: UserProtocol & UserNameRepresentable & AvatarRepresentable,
          T.ReactionType == GetStream.Reaction<ReactionExtraData, T.ActorType> {
    
    /// An text view for new comments. See `TextToolBar`.
    public let textToolBar = TextToolBar.make()
    /// A comments paginator. See `ReactionPaginator`.
    public var reactionPaginator: ReactionPaginator<ReactionExtraData, T.ActorType>?
    private var replyToComment: T.ReactionType?
    /// Section types in the table view.
    public var sections: DetailViewControllerSectionTypes = .activity
    /// A list of section data for the table view.
    public private(set) var sectionsData: [DetailViewControllerSection] = []
    /// A number of reply comments for the top level comments.
    public var childCommentsCount = 0
    /// Show the text view for the adding new comments.
    public var canAddComment = true
    /// Show the section title even if it's empty.
    public var showZeroSectionTitle = true
    
    /// An activity presenter. See `ActivityPresenter`.
    public var activityPresenter: ActivityPresenter<T>? {
        didSet {
            if let activityPresenter = activityPresenter {
                reactionPaginator = activityPresenter.reactionPaginator(activityId: activityPresenter.originalActivity.id,
                                                                        reactionKind: .comment)
            }
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        updateSectionsIndex()
        self.view.backgroundColor = .white
        if sections.contains(.comments) {
            reactionPaginator?.load(.limit(100), completion: commentsLoaded)
            
            if canAddComment {
                User.current?.loadAvatar { [weak self] in self?.setupCommentTextField(avatarImage: $0) }
            }
        }

        reloadData()
        
        if isModal {
            setupNavigationBarForModallyPresented()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(eventAlert(_:)), name: Notification.Name("eventAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registrationAlert(_:)), name: Notification.Name("registrationAlert"), object: nil)
    }
    @objc func eventAlert(_ notification: NSNotification){
        var alertController = UIAlertController()
        if let dict = notification.userInfo as NSDictionary? {
            if let eventID = dict["eventID"] as? String, let userID = dict["userID"] as? String{
                let data:[String: String] = ["eventID": eventID,"userID": userID]
                if registeredEventIDs.contains(eventID){
                    alertController = UIAlertController(title: "Unregister Event", message: "Are you sure to unregister this event?", preferredStyle: .alert)
                }else{
                    alertController = UIAlertController(title: "Register Event", message: "Are you sure to register this event?", preferredStyle: .alert)
                }
                
                let OKAction = UIAlertAction(title: "Yes", style: .default, handler: { alert -> Void in
                    NotificationCenter.default.post(name: Notification.Name("registerEvent"), object: nil, userInfo: data)
                })
                let CancelAction = UIAlertAction(title: "No", style: .default, handler: { alert -> Void in
                    //NotificationCenter.default.post(name: Notification.Name("registerEvent"), object: nil, userInfo: data)
                })
                alertController.addAction(OKAction)
                alertController.addAction(CancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    @objc func registrationAlert(_ notification: NSNotification){
        var alertController = UIAlertController()
        if let dict = notification.userInfo as NSDictionary? {
            if let status = dict["status"] as? Bool, let isRegister = dict["isRegister"] as? Bool{
                if status{
                    //alertController = UIAlertController(title: "Congratulations!", message: "You have registered the event successfully!", preferredStyle: .alert)
                    //self.dismiss(animated: true)
                    if isRegister{
                        alertController = UIAlertController(title: "Congratulations!", message: "You have registered the event successfully!", preferredStyle: .alert)
                    }else{
                        alertController = UIAlertController(title: "", message: "You have unregistered the event.", preferredStyle: .alert)
                    }
                    
                }else{
                    alertController = UIAlertController(title: "Sorry!", message: "Something wrong happened, please register again!", preferredStyle: .alert)
                }
                
                let OKAction = UIAlertAction(title: "OK", style: .default, handler:{ alert -> Void in
                    self.tableView.reloadData()
                })
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    private func updateSectionsIndex() {
        guard let activityPresenter = activityPresenter else {
            self.sectionsData = []
            return
        }
        
        let originalActivity = activityPresenter.originalActivity
        var sectionsData: [DetailViewControllerSection] = []
        
        if sections.contains(.activity) {
            sectionsData.append(DetailViewControllerSection(section: .activity,
                                                            title: nil,
                                                            count: activityPresenter.cellsCount - 1))
        }
        
        if sections.contains(.likes), (originalActivity.likesCount > 0 || showZeroSectionTitle) {
            let title = sectionTitle(for: .likes)
            let count = originalActivity.likesCount > 0 ? 1 : 0
            sectionsData.append(DetailViewControllerSection(section: .likes, title: title, count: count))
        }
        
        if sections.contains(.reposts), (originalActivity.repostsCount > 0 || showZeroSectionTitle) {
            let title = sectionTitle(for: .reposts)
            sectionsData.append(DetailViewControllerSection(section: .reposts, title: title, count: originalActivity.repostsCount))
        }
        
        if sections.contains(.comments), let reactionPaginator = reactionPaginator {
            let title = sectionTitle(for: .comments)
            sectionsData.append(DetailViewControllerSection(section: .comments, title: title, count: reactionPaginator.count))
        }
        
        self.sectionsData = sectionsData
    }
    
    /// Return a title of the section by the section type.
    open func sectionTitle(for type: DetailViewControllerSectionTypes) -> String? {
        if type == .likes {
            return "Liked"
        }
        
        if type == .reposts {
            return "Reposts"
        }
        
        if type == .comments {
            return "Comments"
        }
        
        return nil
    }
    
    /// Return a title of in the section by the section index.
    public func sectionTitle(in section: Int) -> String? {
        return section < sectionsData.count ? sectionsData[section].title : nil
    }
    
    // MARK: - Table View Data Source
    
    open override func setupTableView() {
        tableView.delegate = self
        
        if canAddComment, sections.contains(.comments) {
            tableView.snp.makeConstraints { $0.left.top.right.equalToSuperview() }
        } else {
            tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    
    open override func setupRefreshControl() {
        if sections.contains(.comments) {
            tableView.refreshControl = refreshControl
            
            refreshControl.addValueChangedAction { [weak self] _ in
                if let activityPresenter = self?.activityPresenter {
                    self?.reactionPaginator = activityPresenter.reactionPaginator(activityId: activityPresenter.originalActivity.id,
                                                                            reactionKind: .comment)
                }
                if let self = self, let reactionPaginator = self.reactionPaginator {
                    reactionPaginator.load(.limit(100), completion: self.commentsLoaded)
                    
                }
            }
        }
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        guard sectionsData.count > 0 else {
            return 0
        }
        
        var count = sectionsData.count
        
        if sections.contains(.comments), let reactionPaginator = reactionPaginator {
            count -= 1 // remove the comments section from sectionsData, the rest of the sections are comments.
            let commentsCount = reactionPaginator.count + (reactionPaginator.hasNext ? 1 : 0)
            count += commentsCount
            
            if showZeroSectionTitle, commentsCount == 0 {
                count += 1
            }
        }
        
        return count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < sectionsData.count, sectionsData[section].section != .comments {
            return max(sectionsData[section].count, showZeroSectionTitle ? 1 : 0)
        }
        
        guard sections.contains(.comments), let reactionPaginator = reactionPaginator else {
            return 0
        }
        
        guard childCommentsCount > 0 else {
            return 1
        }
        
        let commentIndex = self.commentIndex(in: section)
        
        if commentIndex < reactionPaginator.items.count {
            let comment = reactionPaginator.items[commentIndex]
            let childCommentsCount = comment.childrenCounts[.comment] ?? 0
            
            return min(childCommentsCount, self.childCommentsCount) + 1
        }
        
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section < sectionsData.count && sectionsData.count != 1 ? sectionsData[section].title : nil
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let activityPresenter = activityPresenter, let reactionPaginator = reactionPaginator else {
            return .unused
        }
        
        if indexPath.section < sectionsData.count {
            let section = sectionsData[indexPath.section]
            
            if section.section == .activity, let cell = tableView.postCell(at: indexPath, presenter: activityPresenter) {
                if let cell = cell as? PostHeaderTableViewCell {
                    updateAvatar(in: cell, activity: activityPresenter.originalActivity)
                }
                
                if let cell = cell as? PostActionsTableViewCell {
                    updateActions(in: cell, activityPresenter: activityPresenter)
                }
                
                return cell
            }
            
            if section.section == .likes, section.count > 0 {
                let cell = tableView.dequeueReusableCell(for: indexPath) as ActionUsersTableViewCell
                cell.titleLabel.text = activityPresenter.reactionTitle(for: activityPresenter.originalActivity,
                                                                       kindOf: .like,
                                                                       suffix: "liked the post")
                
                cell.avatarsStackView.loadImages(with:
                    activityPresenter.reactionUserAvatarURLs(for: activityPresenter.originalActivity, kindOf: .like))
                
                return cell
            }
            
            if section.section == .reposts, section.count > 0 {
                let cell = tableView.dequeueReusableCell(for: indexPath) as ActionUsersTableViewCell
                
                cell.titleLabel.text = activityPresenter.reactionTitle(for: activityPresenter.originalActivity,
                                                                       kindOf: .repost,
                                                                       suffix: "reposted the post")
                
                cell.avatarsStackView.loadImages(with:
                    activityPresenter.reactionUserAvatarURLs(for: activityPresenter.originalActivity, kindOf: .repost))
                
                return cell
            }
            
            if section.section != .comments {
                return .unused
            }
        }
        
        guard let comment = comment(at: indexPath) else {
            if reactionPaginator.hasNext {
                reactionPaginator.loadNext(completion: commentsLoaded)
                return tableView.dequeueReusableCell(for: indexPath) as PaginationTableViewCell
            }
            
            return .unused
        }
        
        let cell = tableView.dequeueReusableCell(for: indexPath) as CommentTableViewCell
        update(cell: cell, with: comment)
        
        if indexPath.row > 0 {
            cell.withIndent = true
            
            if let parentComment = self.comment(at: IndexPath(row: 0, section: indexPath.section)),
                let count = parentComment.childrenCounts[.comment],
                count > childCommentsCount,
                indexPath.row == childCommentsCount {
                cell.moreReplies = moreCommentsTitle(with: count - childCommentsCount)
            }
        } else if childCommentsCount == 0, let childCount = comment.childrenCounts[.comment], childCount > 0 {
            cell.moreReplies = moreCommentsTitle(with: childCount)
        }
        
        return cell
    }
    
    /// A title for bottom comment note, that it has replies.
    open func moreCommentsTitle(with count: Int) -> String {
        return "\(count) more replies"
    }
    
    // MARK: - Table View - Select Cell
    
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let activityPresenter = activityPresenter,
            indexPath.section < sectionsData.count,
            sectionsData[indexPath.section].section == .activity,
            let cellType = activityPresenter.cellType(at: indexPath.row) else {
                return false
        }
        
        if case .attachmentImages = cellType {
            return true
        } else if case .attachmentOpenGraphData = cellType {
            return true
        }
        
        return false
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let activityPresenter = activityPresenter,
            let cellType = activityPresenter.cellType(at: indexPath.row) else {
                return
        }
        
        if case .attachmentImages(let urls) = cellType {
            showImageGallery(with: urls)
        } else if case .attachmentOpenGraphData(let ogData) = cellType {
            showOpenGraphData(with: ogData)
        }
    }
    
    // MARK: - Table View - Comments
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard sections.contains(.comments), let currentUser = User.current, let comment = comment(at: indexPath) else {
            return false
        }
        
        return comment.user.id == currentUser.id
    }
    
    open override func tableView(_ tableView: UITableView,
                                 commit editingStyle: UITableViewCell.EditingStyle,
                                 forRowAt indexPath: IndexPath) {
        if editingStyle == .delete,
            let activityPresenter = activityPresenter,
            let comment = comment(at: indexPath),
            let parentComment = self.comment(at: IndexPath(row: 0, section: indexPath.section)) {
            if comment == parentComment {
                activityPresenter.reactionPresenter.remove(reaction: comment, activity: activityPresenter.activity) { [weak self] in
                    if let error = $0.error {
                        self?.showErrorAlert(error)
                    } else if let self = self{
                        if let activityPresenter = self.activityPresenter {
                            self.reactionPaginator = activityPresenter.reactionPaginator(activityId: activityPresenter.originalActivity.id,reactionKind: .comment)
                        }
                        self.reactionPaginator?.load(.limit(100), completion: self.commentsLoaded)
                    }
                }
            } else {
                activityPresenter.reactionPresenter.remove(reaction: comment, parentReaction: parentComment) { [weak self] in
                    if let error = $0.error {
                        self?.showErrorAlert(error)
                    } else {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func commentIndex(in section: Int) -> Int {
        if section < sectionsData.count, sectionsData[section].section != .comments {
            return -1
        }
        
        return section - (sectionsData.count > 0 ? (sectionsData.count - 1) : 0)
    }
    
    private func comment(at indexPath: IndexPath) -> GetStream.Reaction<ReactionExtraData, T.ActorType>? {
        let commentIndex = self.commentIndex(in: indexPath.section)
        
        guard commentIndex >= 0, let reactionPaginator = reactionPaginator, commentIndex < reactionPaginator.count else {
            return nil
        }
        
        let comment = reactionPaginator.items[commentIndex]
        let childCommentIndex = indexPath.row - 1
        
        if childCommentIndex >= 0, let childComments = comment.latestChildren[.comment], childCommentIndex < childComments.count {
            return childComments[childCommentIndex]
        }
        
        return comment
    }
    
    private func update(cell: CommentTableViewCell, with comment: GetStream.Reaction<ReactionExtraData, T.ActorType>) {
        guard case .comment(let text) = comment.data else {
            return
        }
        
        cell.updateComment(name: comment.user.name, comment: text, date: comment.created)
        comment.user.loadAvatar { [weak cell] in cell?.avatarImageView?.image = $0 }
        
        // Reply button.
        cell.replyButton.addTap { [weak self] _ in
            if let self = self, case .comment(let text) = comment.data {
                self.replyToComment = comment
                self.textToolBar.replyText = "Reply to \(comment.user.name): \(text)"
                self.textToolBar.textView.becomeFirstResponder()
            }
        }
        
        // Like button.
        let countTitle = comment.childrenCounts[.like] ?? 0
        cell.likeButton.setTitle(countTitle == 0 ? "" : String(countTitle), for: .normal)
        cell.likeButton.isSelected = comment.hasUserOwnChildReaction(.like)
        
        cell.likeButton.addTap { [weak self] in
            if let activityPresenter = self?.activityPresenter, let button = $0 as? LikeButton {
                button.like(activityPresenter.originalActivity,
                            presenter: activityPresenter.reactionPresenter,
                            likedReaction: comment.userOwnChildReaction(.like),
                            parentReaction: comment,
                            userTypeOf: T.ActorType.self) { _ in }
            }
        }
    }
    
    private func commentsLoaded(_ error: Error?) {
        refreshControl.endRefreshing()
        
        if let error = error {
            showErrorAlert(error)
        } else {
            updateSectionsIndex()
            tableView.reloadData()
        }
    }
    
    // MARK: - Comment Text Field
    
    private func setupCommentTextField(avatarImage: UIImage?) {
        textToolBar.addToSuperview(view, placeholderText: "Leave reply")
        tableView.snp.makeConstraints { $0.bottom.equalTo(textToolBar.snp.top) }
        textToolBar.showAvatar = true
        textToolBar.avatarView.image = avatarImage
        textToolBar.sendButton.addTarget(self, action: #selector(send(_:)), for: .touchUpInside)
    }
    
    @objc func send(_ button: UIButton) {
        let parentReaction = textToolBar.replyText == nil ? nil : replyToComment
        view.endEditing(true)
        
        guard textToolBar.isValidContent, let activityPresenter = activityPresenter else {
            return
        }
        
        textToolBar.textView.isEditable = false
        
        Client.shared.add(reactionTo: activityPresenter.activity.id,
                          kindOf: .comment_n,
                          targetsFeedIds: [FeedId(feedSlug: "notification", userId: activityPresenter.activity.actor.id)]) { result in /* ... */ }
        
        activityPresenter.reactionPresenter.addComment(for: activityPresenter.activity,
                                                       parentReaction: parentReaction,
                                                       extraData: ReactionExtraData.comment(textToolBar.text),
                                                       userTypeOf: T.ActorType.self) { [weak self] in
                                                        if let self = self {
                                                            self.textToolBar.text = ""
                                                            self.textToolBar.textView.isEditable = true
                                                            
                                                            if let error = $0.error {
                                                                self.showErrorAlert(error)
                                                            } else {
                                                                if let activityPresenter = self.activityPresenter {
                                                                    self.reactionPaginator = activityPresenter.reactionPaginator(activityId: activityPresenter.originalActivity.id,reactionKind: .comment)
                                                                }
                                                                self.reactionPaginator?.load(.limit(100), completion: self.commentsLoaded)
                                                            }
                                                        }
        }
    }
}

// MARK: - Modally presented

extension DetailViewController {
    /// Setup the close button on the navigation bar, when the view controller modally presented.
    open func setupNavigationBarForModallyPresented() {
        guard navigationController != nil else {
            return
        }
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(.closeIcon, for: .normal)
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        closeButton.addTap { [weak self] _ in
            self?.dismiss(animated: true)
        }
    }
}
