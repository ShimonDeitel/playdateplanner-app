import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Playdate] = []
    @Published var isPro: Bool = false

    static let freeLimit = 200

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("playdateplanner_items.json")
        load()
    }

    var isAtFreeLimit: Bool {
        !isPro && items.count >= Store.freeLimit
    }

    func add(_ item: Playdate) -> Bool {
        guard !isAtFreeLimit else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: Playdate) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Playdate) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Playdate].self, from: data) else {
            items = [
        Playdate(childName: "Sample Childname 1", friendName: "Sample Friendname 1", location: "Sample Location 1", date: Calendar.current.date(byAdding: .day, value: -0, to: Date()) ?? Date(), notes: "Sample Notes 1"),
        Playdate(childName: "Sample Childname 2", friendName: "Sample Friendname 2", location: "Sample Location 2", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), notes: "Sample Notes 2"),
        Playdate(childName: "Sample Childname 3", friendName: "Sample Friendname 3", location: "Sample Location 3", date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), notes: "Sample Notes 3")
            ]
            save()
            return
        }
        items = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
