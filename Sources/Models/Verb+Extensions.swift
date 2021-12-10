//
//  Verb+Extensions.swift
//  GetStreamActivityFeed
//
//  Created by Alexey Bukhtin on 22/01/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import GetStream

extension Verb {
    /// A post verb aliase.
    public static let post: Verb = "post"
    /// A follow verb aliase.
    public static let follow: Verb = "follow"
    /// A event verb aliase.
    public static let event: Verb = "event"
    /// A event (registration required) verb aliase.
    public static let event_r: Verb = "event_r"
    /// A event verb aliase.
    public static let repost: Verb = "repost"
}

extension FeedType {
    /// A zoom feed aliase.
    public static let virtual: FeedType = "virtual"
    /// A physical feed aliase.
    public static let physical: FeedType = "physical"
    /// A news feed aliase.
    public static let news: FeedType = "news"
    /// A poll feed aliase.
    public static let poll: FeedType = "poll"
    
    /// A supported feed type aliase.
    public static let supportedFeedType: [FeedType] = [virtual, physical, news, poll]

}


