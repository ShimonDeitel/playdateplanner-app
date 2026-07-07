import Foundation

struct Playdate: Identifiable, Codable, Equatable {
    let id: UUID
    var childName: String
    var friendName: String
    var location: String
    var date: Date
    var notes: String

    init(id: UUID = UUID(), childName: String = "", friendName: String = "", location: String = "", date: Date = Date(), notes: String = "") {
        self.id = id
        self.childName = childName
        self.friendName = friendName
        self.location = location
        self.date = date
        self.notes = notes
    }
}
