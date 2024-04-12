import Foundation
import SQLite3
import CoreIME

struct UserLexicon {

        private static var database: OpaquePointer? = nil

        static func prepare() {
                guard database == nil else { return }
                guard let libraryDirectoryUrl: URL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else { return }
                let userLexiconUrl: URL = libraryDirectoryUrl.appendingPathComponent("userlexicon.sqlite3", isDirectory: false)
                if sqlite3_open_v2(userLexiconUrl.path, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK {
                        ensureTable()
                }
        }
        private static func ensureTable() {
                let command = "CREATE TABLE IF NOT EXISTS lexicon(id INTEGER NOT NULL PRIMARY KEY,input INTEGER NOT NULL,ping INTEGER NOT NULL,prefix INTEGER NOT NULL,shortcut INTEGER NOT NULL,frequency INTEGER NOT NULL,word TEXT NOT NULL,jyutping TEXT NOT NULL);"
                var statement: OpaquePointer? = nil
                if sqlite3_prepare_v2(database, command, -1, &statement, nil) == SQLITE_OK {
                        if sqlite3_step(statement) == SQLITE_DONE {}
                }
                sqlite3_finalize(statement)
        }


        // MARK: - Handle Candidate

        static func handle(_ candidate: Candidate) {
                let id: Int64 = Int64((candidate.lexiconText + candidate.romanization).hash)
                if let frequency: Int64 = find(by: id) {
                        update(id: id, frequency: frequency + 1)
                } else {
                        let jyutping: String = candidate.romanization
                        let newEntry: LexiconEntry = LexiconEntry(id: id,
                                                                  input: Int64(candidate.input.hash),
                                                                  ping: jyutping.ping,
                                                                  prefix: jyutping.shortcut,
                                                                  shortcut: jyutping.shortcut,
                                                                  frequency: 1,
                                                                  word: candidate.lexiconText,
                                                                  jyutping: jyutping)
                        insert(entry: newEntry)
                }
        }
        private static func find(by id: Int64) -> Int64? {
                let queryStatementString = "SELECT frequency FROM lexicon WHERE id = \(id) LIMIT 1;"
                var queryStatement: OpaquePointer? = nil
                var frequency: Int64?
                if sqlite3_prepare_v2(database, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                frequency = sqlite3_column_int64(queryStatement, 0)
                        }
                }
                sqlite3_finalize(queryStatement)
                return frequency
        }
        private static func update(id: Int64, frequency: Int64) {
                let updateStatementString = "UPDATE lexicon SET frequency = \(frequency) WHERE id = \(id);"
                var updateStatement: OpaquePointer?
                if sqlite3_prepare_v2(database, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
                        if sqlite3_step(updateStatement) == SQLITE_DONE {}
                }
                sqlite3_finalize(updateStatement)
        }
        private static func insert(entry: LexiconEntry) {
                let command: String = "INSERT INTO lexicon (id, input, ping, prefix, shortcut, frequency, word, jyutping) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
                var statement: OpaquePointer? = nil
                defer { sqlite3_finalize(statement) }
                guard sqlite3_prepare_v2(database, command, -1, &statement, nil) == SQLITE_OK else { return }

                sqlite3_bind_int64(statement, 1, entry.id)
                sqlite3_bind_int64(statement, 2, entry.input)
                sqlite3_bind_int64(statement, 3, entry.ping)
                sqlite3_bind_int64(statement, 4, entry.prefix)
                sqlite3_bind_int64(statement, 5, entry.shortcut)
                sqlite3_bind_int64(statement, 6, entry.frequency)
                sqlite3_bind_text(statement, 7, (entry.word as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 8, (entry.jyutping as NSString).utf8String, -1, nil)

                guard sqlite3_step(statement) == SQLITE_DONE else { return }
        }


        // MARK: - Suggestion

        static func suggest(text: String, segmentation: Segmentation) -> [Candidate] {
                let matches = match(text: text, input: text, isShortcut: false)
                let shortcuts = match(text: text, input: text, mark: text, isShortcut: true)
                let searches: [Candidate] = {
                        let textCount = text.count
                        let schemes = segmentation.filter({ $0.length == textCount })
                        guard !(schemes.isEmpty) else { return [] }
                        let matches = schemes.map({ scheme -> [Candidate] in
                                let pingText = scheme.map(\.origin).joined()
                                let matched = match(text: pingText, input: text, isShortcut: false)
                                let text2mark = scheme.map(\.text).joined(separator: " ")
                                let syllables = scheme.map(\.origin).joined(separator: " ")
                                return matched.filter({ $0.mark == syllables }).map({ Candidate(text: $0.text, romanization: $0.romanization, input: $0.input, mark: text2mark) })
                        })
                        return matches.flatMap({ $0 })
                }()
                return matches + shortcuts + searches
        }

        private static func match(text: String, input: String, mark: String? = nil, isShortcut: Bool) -> [Candidate] {
                var candidates: [Candidate] = []
                let code: Int = isShortcut ? text.replacingOccurrences(of: "y", with: "j").hash : text.hash
                let column: String = isShortcut ? "shortcut" : "ping"
                let query: String = "SELECT word, jyutping FROM lexicon WHERE \(column) = \(code) ORDER BY frequency DESC LIMIT 5;"
                var statement: OpaquePointer? = nil
                defer { sqlite3_finalize(statement) }
                guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else { return candidates }
                while sqlite3_step(statement) == SQLITE_ROW {
                        let word = String(cString: sqlite3_column_text(statement, 0))
                        let jyutping = String(cString: sqlite3_column_text(statement, 1))
                        let mark: String = mark ?? jyutping.removedTones()
                        let candidate: Candidate = Candidate(text: word, romanization: jyutping, input: input, mark: mark)
                        candidates.append(candidate)
                }
                return candidates
        }

        /// Delete one lexicon entry
        static func removeItem(candidate: Candidate) {
                let id: Int64 = Int64((candidate.lexiconText + candidate.romanization).hash)
                let command: String = "DELETE FROM lexicon WHERE id = \(id) LIMIT 1;"
                var statement: OpaquePointer? = nil
                defer { sqlite3_finalize(statement) }
                guard sqlite3_prepare_v2(database, command, -1, &statement, nil) == SQLITE_OK else { return }
                guard sqlite3_step(statement) == SQLITE_DONE else { return }
        }

        /// Clear User Lexicon
        static func deleteAll() {
                let command: String = "DELETE FROM lexicon;"
                var statement: OpaquePointer? = nil
                defer { sqlite3_finalize(statement) }
                guard sqlite3_prepare_v2(database, command, -1, &statement, nil) == SQLITE_OK else { return }
                guard sqlite3_step(statement) == SQLITE_DONE else { return }
        }
}

private struct LexiconEntry {

        /// (Candidate.lexiconText + Candidate.jyutping).hash
        let id: Int64

        /// input.hash
        let input: Int64

        /// jyutping.withoutTonesAndSpaces.hash
        let ping: Int64

        /// (deprecated)
        let prefix: Int64

        /// jyutping.anchors.hash
        let shortcut: Int64

        let frequency: Int64

        /// Candidate.lexiconText
        let word: String

        let jyutping: String
}
