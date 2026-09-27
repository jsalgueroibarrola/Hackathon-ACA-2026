import SwiftUI

extension EnvironmentValues {
    @Entry var liveFeeds: any LiveFeedService = DisabledLiveFeedService()
}
