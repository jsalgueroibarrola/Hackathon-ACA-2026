import SwiftData

enum RailSchema {
    static var models: [any PersistentModel.Type] {
        [
            TransitNetwork.self,
            Timetable.self,
            FavoriteStation.self,
            SavedStation.self,
            ServiceAlertFeed.self,
            ServiceAlert.self,
            RealtimeFeed.self,
            LiveTrain.self,
        ]
    }
}
