//
//  User.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 14/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation
import GetStream
import Nuke
import UIKit

fileprivate struct UserData: Codable {
    let name: String?
    let profileImage: URL?
}

/// An advanced Stream user with a name and avatar.
public final class User: GetStream.User, UserNameRepresentable, AvatarRepresentable {
    private enum CodingKeys: String, CodingKey {
        case name
        case avatarURL
        case avatarUrl
    }
    
    public var name: String
    public var avatarUrl: String
    
    public var avatarURL: URL? {
        didSet { avatarImage = nil }
    }
    
    private let dispatchQueue = DispatchQueue(label: "io.getstream.User")
    private(set) lazy var feed: FlatFeed = Client.shared.flatFeed(FeedId.user(with: id))
    
    public var avatarImage: UIImage?
    
    public init(name: String, avatarUrl: String, id: String) {
        self.name = name
        self.avatarUrl = avatarUrl
        super.init(id: id)
    }
    
    required init(id: String) {
        name = ""
        self.avatarUrl = ""
        super.init(id: id)
    }
    
    required init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let container = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        self.name = name ?? "NoName"
        let avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.avatarUrl = avatarUrl ?? ""
        if (avatarUrl != nil){
            self.avatarURL = URL(string: avatarUrl!)
        }else{
            self.avatarURL = try container.decodeIfPresent(URL.self, forKey: .avatarURL)
        }
        try super.init(from: decoder)
    }
    
 
    
    override public func encode(to encoder: Encoder) throws {
        var dataContainer = encoder.container(keyedBy: DataCodingKeys.self)
        var container = dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        try container.encode(name, forKey: .name)
        try container.encode(avatarURL, forKey: .avatarURL)
        try super.encode(to: encoder)
    }
}

// MARK: - Refresh

extension User {
    /// Reloads the user data and returns in a completion block.
    public func refresh(completion: @escaping (_ user: User?) -> Void) {
        Client.shared.get(typeOf: User.self, userId: id, withFollowCounts: true) { result in
            completion(try? result.get())
        }
    }
}

// MARK: - Following

extension User {
    /// Checks if the user feed is following to a target.
    public func isFollow(toTarget target: FeedId,
                         completion: @escaping (_ isFollow: Bool, _ following: Follower?, _ error: Error?) -> Void) {
        feed.following(filter: [target]) {
            if let response = try? $0.get() {
                completion(response.results.first != nil, response.results.first, nil)
            } else {
//                completion(false, nil, $0.error)
                completion(false, nil, nil)
            }
        }
    }
}
