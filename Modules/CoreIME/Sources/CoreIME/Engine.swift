import Foundation
import SQLite3

public struct Engine {

        private static var dbPath: String? {
                guard let cacheUrl = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }
                let url = cacheUrl.appendingPathComponent("imedb.sqlite3", isDirectory: false)
                return url.path
        }

        private(set) static var database: OpaquePointer? = nil
        private(set) static var cachedDatabase: OpaquePointer? = nil
        private(set) static var isDatabaseReady: Bool = false

        public static func prepare(appVersion: String) {
                guard !isDatabaseReady else { return }
                guard !verifiedCachedDatabase(appVersion: appVersion) else {
                        #if os(macOS)
                        loadCachedDatabaseIntoMemory()
                        #endif
                        isDatabaseReady = true
                        return
                }
                sqlite3_close_v2(database)
                sqlite3_close_v2(cachedDatabase)
                #if os(macOS)
                guard sqlite3_open_v2(":memory:", &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK else { return }
                #else
                guard let path: String = dbPath else { return }
                try? FileManager.default.removeItem(atPath: path)
                guard sqlite3_open_v2(path, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK else { return }
                #endif
                createLexiconTable()
                createT2STable()
                createComposeTable()
                createPinyinTable()
                createShapeTable()
                createSymbolTable()
                createMetaTable(appVersion: appVersion)
                isDatabaseReady = true
                createIndies()
                #if os(macOS)
                backupInMemoryDatabaseToCaches()
                #endif
        }
        private static func verifiedCachedDatabase(appVersion: String) -> Bool {
                guard let path = dbPath else { return false }
                guard FileManager.default.fileExists(atPath: path) else { return false }
                #if os(macOS)
                guard sqlite3_open_v2(path, &cachedDatabase, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else { return false }
                #else
                guard sqlite3_open_v2(path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else { return false }
                #endif
                let query: String = "SELECT valuetext FROM metatable WHERE keynumber = 1;"
                var statement: OpaquePointer? = nil
                defer { sqlite3_finalize(statement) }
                #if os(macOS)
                guard sqlite3_prepare_v2(cachedDatabase, query, -1, &statement, nil) == SQLITE_OK else { return false }
                #else
                guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK else { return false }
                #endif
                guard sqlite3_step(statement) == SQLITE_ROW else { return false }
                let savedAppVersion: String = String(cString: sqlite3_column_text(statement, 0))
                return appVersion == savedAppVersion
        }
        private static func backupInMemoryDatabaseToCaches() {
                guard let path = dbPath else { return }
                try? FileManager.default.removeItem(atPath: path)
                var destination: OpaquePointer? = nil
                defer { sqlite3_close_v2(destination) }
                guard sqlite3_open_v2(path, &destination, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK else { return }
                let backup = sqlite3_backup_init(destination, "main", database, "main")
                guard sqlite3_backup_step(backup, -1) == SQLITE_DONE else { return }
                guard sqlite3_backup_finish(backup) == SQLITE_OK else { return }
        }
        private static func loadCachedDatabaseIntoMemory() {
                guard sqlite3_open_v2(":memory:", &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK else { return }
                let backup = sqlite3_backup_init(database, "main", cachedDatabase, "main")
                guard sqlite3_backup_step(backup, -1) == SQLITE_DONE else { return }
                guard sqlite3_backup_finish(backup) == SQLITE_OK else { return }
                sqlite3_close_v2(cachedDatabase)
        }
}

private extension Engine {
        static func createMetaTable(appVersion: String) {
                let createTable: String = "CREATE TABLE metatable(keynumber INTEGER NOT NULL PRIMARY KEY, valuetext TEXT NOT NULL);"
                var createStatement: OpaquePointer? = nil
                guard sqlite3_prepare_v2(database, createTable, -1, &createStatement, nil) == SQLITE_OK else { sqlite3_finalize(createStatement); return }
                guard sqlite3_step(createStatement) == SQLITE_DONE else { sqlite3_finalize(createStatement); return }
                sqlite3_finalize(createStatement)
                let values: String = "(1, '\(appVersion)')"
                let insert: String = "INSERT INTO metatable (keynumber, valuetext) VALUES \(values);"
                var insertStatement: OpaquePointer? = nil
                defer { sqlite3_finalize(insertStatement) }
                guard sqlite3_prepare_v2(database, insert, -1, &insertStatement, nil) == SQLITE_OK else { return }
                guard sqlite3_step(insertStatement) == SQLITE_DONE else { return }
        }
        static func createLexiconTable() {
                let createTable: String = "CREATE TABLE lexicontable(word TEXT NOT NULL, romanization TEXT NOT NULL, shortcut INTEGER NOT NULL, ping INTEGER NOT NULL);"
                var createStatement: OpaquePointer? = nil
                guard sqlite3_prepare_v2(database, createTable, -1, &createStatement, nil) == SQLITE_OK else { sqlite3_finalize(createStatement); return }
                guard sqlite3_step(createStatement) == SQLITE_DONE else { sqlite3_finalize(createStatement); return }
                sqlite3_finalize(createStatement)
                guard let url = Bundle.module.url(forResource: "lexicon", withExtension: "txt") else { return }
                guard let content = try? String(contentsOf: url) else { return }
                let sourceLines: [String] = content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                func insert(values: String) {
                        let insert: String = "INSERT INTO lexicontable (word, romanization, shortcut, ping) VALUES \(values);"
                        var insertStatement: OpaquePointer? = nil
                        defer { sqlite3_finalize(insertStatement) }
                        guard sqlite3_prepare_v2(database, insert, -1, &insertStatement, nil) == SQLITE_OK else { return }
                        guard sqlite3_step(insertStatement) == SQLITE_DONE else { return }
                }
                let range: Range<Int> = 0..<2000
                let distance: Int = sourceLines.count / 2000
                for number in range {
                        let bound: Int = number == 1999 ? sourceLines.count : ((number + 1) * distance)
                        let part = sourceLines[(number * distance)..<bound]
                        let entries = part.map { line -> String? in
                                let parts = line.split(separator: "\t")
                                guard parts.count == 4 else { return nil }
                                let word = parts[0]
                                let romanization = parts[1]
                                let shortcut = parts[2]
                                let ping = parts[3]
                                return "('\(word)', '\(romanization)', \(shortcut), \(ping))"
                        }
                        let values: String = entries.compactMap({ $0 }).joined(separator: ", ")
                        insert(values: values)
                }
        }
        static func createIndies() {
                let commands: [String] = [
                        "CREATE INDEX lexiconpingindex ON lexicontable(ping);",
                        "CREATE INDEX lexiconshortcutindex ON lexicontable(shortcut);",
                        "CREATE INDEX lexiconwordindex ON lexicontable(word);",
                        "CREATE INDEX composepingindex ON composetable(ping);",
                        "CREATE INDEX pinyinshortcutindex ON pinyintable(shortcut);",
                        "CREATE INDEX pinyinpinindex ON pinyintable(pin);",
                        "CREATE INDEX shapecangjieindex ON shapetable(cangjie);",
                        "CREATE INDEX shapestrokeindex ON shapetable(stroke);",
                        "CREATE INDEX symbolshortcutindex ON symboltable(shortcut);",
                        "CREATE INDEX symbolpingindex ON symboltable(ping);"
                ]
                for command in commands {
                        var statement: OpaquePointer? = nil
                        guard sqlite3_prepare_v2(database, command, -1, &statement, nil) == SQLITE_OK else { sqlite3_finalize(statement); return }
                        guard sqlite3_step(statement) == SQLITE_DONE else { sqlite3_finalize(statement); return }
                        sqlite3_finalize(statement)
                }
        }
}

private extension Engine {
        static func createT2STable() {
                let createTable: String = "CREATE TABLE t2stable(traditional INTEGER NOT NULL PRIMARY KEY, simplified TEXT NOT NULL);"
                var createStatement: OpaquePointer? = nil
                guard sqlite3_prepare_v2(database, createTable, -1, &createStatement, nil) == SQLITE_OK else { sqlite3_finalize(createStatement); return }
                guard sqlite3_step(createStatement) == SQLITE_DONE else { sqlite3_finalize(createStatement); return }
                sqlite3_finalize(createStatement)
                guard let url = Bundle.module.url(forResource: "t2s", withExtension: "txt") else { return }
                guard let content = try? String(contentsOf: url) else { return }
                let sourceLines: [String] = content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                let entries = sourceLines.map { sourceLine -> String? in
                        let parts = sourceLine.split(separator: "\t")
                        guard parts.count == 2 else { return nil }
                        let traditionalCode = parts[0]
                        let simplified = parts[1]
                        return "(\(traditionalCode), '\(simplified)')"
                }
                let values: String = entries.compactMap({ $0 }).joined(separator: ", ")
                let insert: String = "INSERT INTO t2stable (traditional, simplified) VALUES \(values);"
                var insertStatement: OpaquePointer? = nil
                defer { sqlite3_finalize(insertStatement) }
                guard sqlite3_prepare_v2(database, insert, -1, &insertStatement, nil) == SQLITE_OK else { return }
                guard sqlite3_step(insertStatement) == SQLITE_DONE else { return }
        }
        static func createComposeTable() {
                let createTable: String = "CREATE TABLE composetable(word TEXT NOT NULL, romanization TEXT NOT NULL, ping INTEGER NOT NULL);"
                var createStatement: OpaquePointer? = nil
                guard sqlite3_prepare_v2(database, createTable, -1, &createStatement, nil) == SQLITE_OK else { sqlite3_finalize(createStatement); return }
                guard sqlite3_step(createStatement) == SQLITE_DONE else { sqlite3_finalize(createStatement); return }
                sqlite3_finalize(createStatement)
                guard let url = Bundle.module.url(forResource: "compose", withExtension: "txt") else { return }
                guard let content = try? String(contentsOf: url) else { return }
                let sourceLines: [String] = content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                let entries = sourceLines.map { sourceLine -> String? in
                        let parts = sourceLine.split(separator: "\t")
                        guard parts.count == 3 else { return nil }
                        let word = parts[0]
                        let romanization = parts[1]
                        let ping = parts[2]
                        return "('\(word)', '\(romanization)', \(ping))"
                }
                let values: String = entries.compactMap({ $0 }).joined(separator: ", ")
                let insert: String = "INSERT INTO composetable (word, romanization, ping) VALUES \(values);"
                var insertStatement: OpaquePointer? = nil
                defer { sqlite3_finalize(insertStatement) }
                guard sqlite3_prepare_v2(database, insert, -1, &insertStatement, nil) == SQLITE_OK else { return }
                guard sqlite3_step(insertStatement) == SQLITE_DONE else { return }
        }
        static func createPinyinTable() {
                let createTable: String = "CREATE TABLE pinyintable(word TEXT NOT NULL, shortcut INTEGER NOT NULL, pin INTEGER NOT NULL);"
                var createStatement: OpaquePointer? = nil
                guard sqlite3_prepare_v2(database, createTable, -1, &createStatement, nil) == SQLITE_OK else { sqlite3_finalize(createStatement); return }
                guard sqlite3_step(createStatement) == SQLITE_DONE else { sqlite3_finalize(createStatement); return }
                sqlite3_finalize(createStatement)
                guard let url = Bundle.module.url(forResource: "pinyin", withExtension: "txt") else { return }
                guard let content = try? String(contentsOf: url) else { return }
                let sourceLines: [String] = content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                func insert(values: String) {
                        let insert: String = "INSERT INTO pinyintable (word, shortcut, pin) VALUES \(values);"
                        var insertStatement: OpaquePointer? = nil
                        defer { sqlite3_finalize(insertStatement) }
                        guard sqlite3_prepare_v2(database, insert, -1, &insertStatement, nil) == SQLITE_OK else { return }
                        guard sqlite3_step(insertStatement) == SQLITE_DONE else { return }
                }
                let range: Range<Int> = 0..<2000
                let distance: Int = sourceLines.count / 2000
                for number in range {
                        let bound: Int = number == 1999 ? sourceLines.count : ((number + 1) * distance)
                        let part = sourceLines[(number * distance)..<bound]
                        let entries = part.map { line -> String? in
                                // TODO: replace , with tab
                                let parts = line.split(separator: ",")
                                guard parts.count == 4 else { return nil }
                                let word = parts[0]
                                let pin = parts[1]
                                let shortcut = parts[2]
                                return "('\(word)', \(shortcut), \(pin))"
                        }
                        let values: String = entries.compactMap({ $0 }).joined(separator: ", ")
                        insert(values: values)
                }
        }
        static func createShapeTable() {
                let createTable: String = "CREATE TABLE shapetable(word TEXT NOT NULL, cangjie TEXT NOT NULL, stroke TEXT NOT NULL);"
                var createStatement: OpaquePointer? = nil
                guard sqlite3_prepare_v2(database, createTable, -1, &createStatement, nil) == SQLITE_OK else { sqlite3_finalize(createStatement); return }
                guard sqlite3_step(createStatement) == SQLITE_DONE else { sqlite3_finalize(createStatement); return }
                sqlite3_finalize(createStatement)
                guard let url = Bundle.module.url(forResource: "shape", withExtension: "txt") else { return }
                guard let content = try? String(contentsOf: url) else { return }
                let sourceLines: [String] = content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                let entries = sourceLines.map { sourceLine -> String? in
                        let parts = sourceLine.split(separator: "\t")
                        guard parts.count == 3 else { return nil }
                        let word = parts[0]
                        let cangjie = parts[1]
                        let stroke = parts[2]
                        return "('\(word)', '\(cangjie)', '\(stroke)')"
                }
                let values: String = entries.compactMap({ $0 }).joined(separator: ", ")
                let insert: String = "INSERT INTO shapetable (word, cangjie, stroke) VALUES \(values);"
                var insertStatement: OpaquePointer? = nil
                defer { sqlite3_finalize(insertStatement) }
                guard sqlite3_prepare_v2(database, insert, -1, &insertStatement, nil) == SQLITE_OK else { return }
                guard sqlite3_step(insertStatement) == SQLITE_DONE else { return }
        }
        static func createSymbolTable() {
                let createTable: String = "CREATE TABLE symboltable(category INTEGER NOT NULL, codepoint TEXT NOT NULL, cantonese TEXT NOT NULL, romanization TEXT NOT NULL, shortcut INTEGER NOT NULL, ping INTEGER NOT NULL);"
                var createStatement: OpaquePointer? = nil
                guard sqlite3_prepare_v2(database, createTable, -1, &createStatement, nil) == SQLITE_OK else { sqlite3_finalize(createStatement); return }
                guard sqlite3_step(createStatement) == SQLITE_DONE else { sqlite3_finalize(createStatement); return }
                sqlite3_finalize(createStatement)
                guard let url = Bundle.module.url(forResource: "symbol", withExtension: "txt") else { return }
                guard let content = try? String(contentsOf: url) else { return }
                let sourceLines: [String] = content.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
                let entries = sourceLines.map { sourceLine -> String? in
                        let parts = sourceLine.split(separator: "\t")
                        guard parts.count == 6 else { return nil }
                        let category = parts[0]
                        let codepoint = parts[1]
                        let cantonese = parts[2]
                        let romanization = parts[3]
                        let shortcut = parts[4]
                        let ping = parts[5]
                        return "(\(category), '\(codepoint)', '\(cantonese)', '\(romanization)', \(shortcut), \(ping))"
                }
                let values: String = entries.compactMap({ $0 }).joined(separator: ", ")
                let insert: String = "INSERT INTO symboltable (category, codepoint, cantonese, romanization, shortcut, ping) VALUES \(values);"
                var insertStatement: OpaquePointer? = nil
                defer { sqlite3_finalize(insertStatement) }
                guard sqlite3_prepare_v2(database, insert, -1, &insertStatement, nil) == SQLITE_OK else { return }
                guard sqlite3_step(insertStatement) == SQLITE_DONE else { return }
        }
}
