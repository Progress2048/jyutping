import Foundation
import SQLite3
import KeyboardDataProvider

struct Engine {

        fileprivate typealias RowCandidate = (candidate: Candidate, row: Int)

        private let provider: KeyboardDataProvider = KeyboardDataProvider()
        func close() {
                provider.close()
        }

        func suggest(for text: String, schemes: [[String]]) -> [Candidate] {
                guard !text.hasPrefix("r") else {
                        let pinyin: String = String(text.dropFirst())
                        return pinyin.isEmpty ? [] : matchPinyin(for: pinyin)
                }
                guard !text.hasPrefix("v") else {
                        let cangjie: String = String(text.dropFirst())
                        return cangjie.isEmpty ? [] : matchCangjie(for: cangjie)
                }
                switch text.count {
                case 0:
                        return []
                case 1:
                        switch text {
                        case "y":
                                return shortcut(for: "j")
                        default:
                                return shortcut(for: text)
                        }
                case 2:
                        return fetchTwoChars(text)
                case 3:
                        return fetchThreeChars(text)
                default:
                        let filtered: String = text.replacingOccurrences(of: "'", with: "")
                        return fetch(for: filtered, origin: text, schemes: schemes)
                }
        }

        private func fetchTwoChars(_ text: String) -> [Candidate] {
                guard (text.last!) != "'" else {
                        return match(for: String(text.dropLast()))
                }
                let matched: [Candidate] = match(for: text)
                guard !(text.last!.isTone) else {
                        return matched
                }
                let shortcutTwo: [Candidate] = shortcut(for: text)
                let shortcutFirst: [Candidate] = shortcut(for: String(text.first!))
                return matched + shortcutTwo + shortcutFirst
        }
        private func fetchThreeChars(_ text: String) -> [Candidate] {
                guard (text.last!) != "'" else {
                        return match(for: String(text.dropLast()))
                }
                let exactlyMatched: [Candidate] = match(for: text)
                guard !(text.last!.isTone) else {
                        return exactlyMatched
                }
                let prefixMatches: [Candidate] = prefix(match: text)
                let shortcutThree: [Candidate] = shortcut(for: text)

                let firstTwoChars: String = String(text.dropLast())
                let matchTwoChars: [Candidate] = match(for:firstTwoChars)
                let shortcutTwo: [Candidate] = shortcut(for: firstTwoChars)
                guard let middleIsTone: Bool = firstTwoChars.last?.isTone, !middleIsTone else {
                        return exactlyMatched + matchTwoChars
                }

                let shortcutLast: [Candidate] = shortcut(for: String(text.last!), count: 1)
                var combine: [Candidate] = [Candidate]()
                if !matchTwoChars.isEmpty && !shortcutLast.isEmpty {
                        combine.append((matchTwoChars[0] + shortcutLast[0]))
                }
                if !shortcutTwo.isEmpty && !shortcutLast.isEmpty {
                        combine.append((shortcutTwo[0] + shortcutLast[0]))
                }
                let shortcutFirst: [Candidate] = shortcut(for: String(text.first!))

                let head: [Candidate] = exactlyMatched + prefixMatches + shortcutThree + combine
                let tail: [Candidate] = shortcutTwo + matchTwoChars + shortcutFirst
                return head + tail
        }

        private func fetch(for text: String, origin: String, schemes: [[String]]) -> [Candidate] {
                guard let bestScheme: [String] = schemes.first, !bestScheme.isEmpty else {
                        return processUnsplittable(text)
                }
                if bestScheme.reduce(0, {$0 + $1.count}) == text.count {
                        return process(text: text, origin: origin, sequences: schemes)
                } else {
                        return processPartial(text: text, sequences: schemes)
                }
        }
        
        private func processUnsplittable(_ text: String) -> [Candidate] {
                var combine: [Candidate] = match(for: text) + prefix(match: text) + shortcut(for: text)
                for number in 1..<text.count {
                        let leading: String = String(text.dropLast(number))
                        combine += shortcut(for: leading)
                }
                return combine
        }
        private func process(text: String, origin: String, sequences: [[String]]) -> [Candidate] {
                let candidates: [Candidate] = {
                        let matches = sequences.map({ matchWithRowID(for: $0.joined()) }).joined()
                        let sorted = matches.sorted { $0.candidate.text.count == $1.candidate.text.count && ($1.row - $0.row) > 30000 }
                        let candidates: [Candidate] = sorted.map({ $0.candidate })
                        let hasSeparators: Bool = text.count != origin.count
                        guard hasSeparators else { return candidates }
                        let firstSyllable: String = sequences.first?.first ?? "X"
                        let filtered: [Candidate] = candidates.filter { candidate in
                                let firstJyutping: String = candidate.jyutping.components(separatedBy: " ").first ?? "Y"
                                return firstSyllable == firstJyutping.removeTones()
                        }
                        return filtered
                }()
                guard candidates.count > 1 else {
                        return candidates
                }
                let firstCandidate: Candidate = candidates[0]
                let secondCandidate: Candidate = candidates[1]
                guard firstCandidate.input != text else {
                        return candidates
                }
                let tailText: String = String(text.dropFirst(firstCandidate.input.count))
                let tailJyutpings: [String] = Splitter.engineSplit(tailText)
                guard !tailJyutpings.isEmpty else { return candidates }
                var combine: [Candidate] = []
                for (index, _) in tailJyutpings.enumerated().reversed() {
                        let tail: String = tailJyutpings[0...index].joined()
                        if let one: Candidate = matchWithLimitCount(for: tail, count: 1).first {
                                let newFirstCandidate: Candidate = firstCandidate + one
                                combine.append(newFirstCandidate)
                                if firstCandidate.input.count == secondCandidate.input.count && firstCandidate.text.count == secondCandidate.text.count {
                                        let newSecondCandidate: Candidate = secondCandidate + one
                                        combine.append(newSecondCandidate)
                                }
                                break
                        }
                }
                return combine + candidates
        }
        private func processPartial(text: String, sequences: [[String]]) -> [Candidate] {
                let matches = sequences.map({ matchWithRowID(for: $0.joined()) }).joined()
                let sorted = matches.sorted { $0.candidate.text.count == $1.candidate.text.count && ($1.row - $0.row) > 30000 }
                let candidates: [Candidate] = sorted.map({ $0.candidate })
                guard !candidates.isEmpty else {
                        return match(for: text) + prefix(match: text, count: 5) + shortcut(for: text)
                }
                let firstCandidate: Candidate = candidates[0]
                guard firstCandidate.input != text else {
                        return match(for: text) + prefix(match: text, count: 5) + candidates + shortcut(for: text)
                }
                let tailText: String = String(text.dropFirst(firstCandidate.input.count))
                if let tailOne: Candidate = prefix(match: tailText, count: 1).first {
                        let newFirst: Candidate = firstCandidate + tailOne
                        return match(for: text) + prefix(match: text, count: 5) + [newFirst] + candidates + shortcut(for: text)
                } else {
                        let tailJyutpings: [String] = Splitter.engineSplit(tailText)
                        guard !tailJyutpings.isEmpty else {
                                return match(for: text) + prefix(match: text, count: 5) + candidates + shortcut(for: text)
                        }
                        var concatenated: [Candidate] = []
                        var hasTailCandidate: Bool = false
                        let rawTailJyutpings: String = tailJyutpings.joined()
                        if tailText.count - rawTailJyutpings.count > 1 {
                                let tailRawJPPlusOne: String = String(tailText.dropLast(tailText.count - rawTailJyutpings.count - 1))
                                if let one: Candidate = prefix(match: tailRawJPPlusOne, count: 1).first {
                                        let newFirst: Candidate = firstCandidate + one
                                        concatenated.append(newFirst)
                                        hasTailCandidate = true
                                }
                        }
                        if !hasTailCandidate {
                                for (index, _) in tailJyutpings.enumerated().reversed() {
                                        let someJPs: String = tailJyutpings[0...index].joined()
                                        if let one: Candidate = matchWithLimitCount(for: someJPs, count: 1).first {
                                                let newFirst: Candidate = firstCandidate + one
                                                concatenated.append(newFirst)
                                                break
                                        }
                                }
                        }
                        return match(for: text) + prefix(match: text, count: 5) + concatenated + candidates + shortcut(for: text)
                }
        }
}

private extension Engine {

        // CREATE TABLE jyutpingtable(ping INTEGER NOT NULL, shortcut INTEGER NOT NULL, prefix INTEGER NOT NULL, word TEXT NOT NULL, jyutping TEXT NOT NULL, pinyin INTEGER NOT NULL, cangjie INTEGER NOT NULL);

        func shortcut(for text: String, count: Int = 100) -> [Candidate] {
                guard !text.isEmpty else { return [] }
                var candidates: [Candidate] = []
                let queryString = "SELECT word, jyutping FROM jyutpingtable WHERE shortcut = \(text.hash) LIMIT \(count);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(provider.database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let word: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                                let jyutping: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                                let candidate: Candidate = Candidate(text: word, jyutping: jyutping, input: text, lexiconText: word)
                                candidates.append(candidate)
                        }
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }
        
        func match(for text: String) -> [Candidate] {
                guard !text.isEmpty else { return [] }
                var candidates: [Candidate] = []
                let digits: String = text.tones
                let isToneless: Bool = digits.isEmpty
                let ping: String = isToneless ? text : text.removeTones()
                let queryString = "SELECT word, jyutping FROM jyutpingtable WHERE ping = \(ping.hash);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(provider.database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let word: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                                let jyutping: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                                if isToneless || digits == jyutping.tones {
                                        let candidate: Candidate = Candidate(text: word, jyutping: jyutping, input: text, lexiconText: word)
                                        candidates.append(candidate)
                                }
                        }
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }
        func matchWithLimitCount(for text: String, count: Int) -> [Candidate] {
                guard !text.isEmpty else { return [] }
                var candidates: [Candidate] = []
                let digits: String = text.tones
                let isToneless: Bool = digits.isEmpty
                let ping: String = isToneless ? text : text.removeTones()
                let queryString = "SELECT word, jyutping FROM jyutpingtable WHERE ping = \(ping.hash) LIMIT \(count);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(provider.database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let word: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                                let jyutping: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                                if isToneless || digits == jyutping.tones {
                                        let candidate: Candidate = Candidate(text: word, jyutping: jyutping, input: text, lexiconText: word)
                                        candidates.append(candidate)
                                }
                        }
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }
        func matchWithRowID(for text: String) -> [RowCandidate] {
                guard !text.isEmpty else { return [] }
                var rowCandidates: [RowCandidate] = []
                let digits: String = text.tones
                let isToneless: Bool = digits.isEmpty
                let ping: String = isToneless ? text : text.removeTones()
                let queryString = "SELECT rowid, word, jyutping FROM jyutpingtable WHERE ping = \(ping.hash);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(provider.database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let rowid: Int = Int(sqlite3_column_int64(queryStatement, 0))
                                let word: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                                let jyutping: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                                if isToneless || digits == jyutping.tones {
                                        let candidate: Candidate = Candidate(text: word, jyutping: jyutping, input: text, lexiconText: word)
                                        let rowCandidate: RowCandidate = (candidate: candidate, row: rowid)
                                        rowCandidates.append(rowCandidate)
                                }
                        }
                }
                sqlite3_finalize(queryStatement)
                return rowCandidates
        }
        
        func prefix(match text: String, count: Int = 100) -> [Candidate] {
                guard !text.isEmpty else { return [] }
                var candidates: [Candidate] = []
                let queryString = "SELECT word, jyutping FROM jyutpingtable WHERE prefix = \(text.hash) LIMIT \(count);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(provider.database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let word: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                                let jyutping: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                                let candidate: Candidate = Candidate(text: word, jyutping: jyutping, input: text, lexiconText: word)
                                candidates.append(candidate)
                        }
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }

        func matchPinyin(for text: String) -> [Candidate] {
                var candidates: [Candidate] = []
                let queryString = "SELECT word, jyutping FROM jyutpingtable WHERE pinyin = \(text.hash);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(provider.database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let word: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                                let jyutping: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                                let candidate: Candidate = Candidate(text: word, jyutping: jyutping, input: text, lexiconText: word)
                                candidates.append(candidate)
                        }
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }
        func matchCangjie(for text: String) -> [Candidate] {
                var candidates: [Candidate] = []
                let queryString = "SELECT word, jyutping FROM jyutpingtable WHERE cangjie = \(text.hash);"
                var queryStatement: OpaquePointer? = nil
                if sqlite3_prepare_v2(provider.database, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                                let word: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                                let jyutping: String = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                                let candidate: Candidate = Candidate(text: word, jyutping: jyutping, input: text, lexiconText: word)
                                candidates.append(candidate)
                        }
                }
                sqlite3_finalize(queryStatement)
                return candidates
        }
}
