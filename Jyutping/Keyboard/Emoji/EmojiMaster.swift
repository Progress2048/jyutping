import UIKit
import CoreIME

struct EmojiMaster {

        private static let key: String = "emoji_frequent"
        private(set) static var frequent: [String] = {
                let history = UserDefaults.standard.string(forKey: key)
                guard let history else { return defaultFrequent }
                guard !(history.isEmpty) else { return defaultFrequent }
                guard history.contains(",") else { return [history] }
                return history.split(separator: ",").map({ $0.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .controlCharacters) })
        }()
        static func updateFrequent(latest emoji: String) {
                let combined: [String] = ([emoji] + frequent).uniqued()
                let updated: [String] = combined.count <= 30 ? combined : combined.dropLast(combined.count - 30)
                frequent = updated
                let frequentText: String = updated.joined(separator: ",")
                UserDefaults.standard.set(frequentText, forKey: key)
        }
        static func clearFrequent() {
                frequent = defaultFrequent
                let emptyText: String = ""
                UserDefaults.standard.set(emptyText, forKey: key)
        }

        static let emojis: [Emoji.Category: [String]] = {
                var dict: [Emoji.Category: [String]] = [:]
                let fetched = Engine.fetchEmoji()
                _ = Emoji.Category.allCases.map { category in
                        let matchedCategory = fetched.filter({ $0.category == category })
                        let filtered: [Emoji] = {
                                if #available(iOSApplicationExtension 16.4, *) {
                                        return matchedCategory
                                } else if #available(iOSApplicationExtension 15.4, *) {
                                        return matchedCategory.filter({ !new_in_iOS_16_4.contains($0.text) })
                                } else {
                                        return matchedCategory.filter({ !new_in_iOS_16_4.contains($0.text) && !new_in_iOS_15_4.contains($0.text) })
                                }
                        }()
                        dict[category] = filtered.map(\.text).uniqued()
                }
                return dict
        }()


        private static let defaultFrequent: [String] = ["👋", "👍", "👌", "✌️", "👏", "🤩", "😍", "😘", "🥰", "😋", "😎", "😇", "🤗", "😏", "🤔", "❤️", "💖", "💕", "💞", "🌹", "🌚", "👀", "🐶", "👻", "🤪", "🍻", "🔥", "✅", "💯", "🎉"]

        private static let new_in_iOS_16_4: Set<String> = ["🫨", "🩷", "🩵", "🩶", "🫷", "🫸", "🫎", "🫏", "🪽", "🐦‍⬛", "🪿", "🪼", "🪻", "🫚", "🫛", "🪭", "🪮", "🪇", "🪈", "🪯", "🛜"]

        private static let new_in_iOS_15_4: Set<String> = ["🥹", "🫣", "🫢", "🫡", "🫠", "🫥", "🫤", "🫶", "🤝", "🫰", "🫳", "🫴", "🫲", "🫱", "🫵", "🫦", "🫅", "🧌", "🫄", "🫃", "🪺", "🪹", "🪸", "🪷", "🫧", "🫙", "🫘", "🫗", "🛝", "🩼", "🛞", "🛟", "🪫", "🪪", "🪬", "🩻", "🪩", "🟰"]
}
