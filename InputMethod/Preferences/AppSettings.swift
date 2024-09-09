import SwiftUI
import CommonExtensions
import CoreIME

struct SettingsKey {
        static let CandidatePageSize: String = "CandidatePageSize"
        static let CandidateLineSpacing: String = "CandidateLineSpacing"
        static let CandidatePageOrientation: String = "CandidatePageOrientation"
        static let CommentDisplayStyle: String = "CommentDisplayStyle"
        static let ToneDisplayStyle: String = "ToneDisplayStyle"
        static let ToneDisplayColor: String = "ToneDisplayColor"
        static let CangjieVariant: String = "CangjieVariant"
        static let UserLexiconInputMemory: String = "UserLexiconInputMemory"


        static let CandidateFontSize: String = "CandidateFontSize"
        static let CommentFontSize: String = "CommentFontSize"
        static let LabelFontSize: String = "LabelFontSize"

        static let CandidateFontMode: String = "CandidateFontMode"
        static let CommentFontMode: String = "CommentFontMode"
        static let LabelFontMode: String = "LabelFontMode"

        static let CustomCandidateFontList: String = "CustomCandidateFontList"
        static let CustomCommentFontList: String = "CustomCommentFontList"
        static let CustomLabelFontList: String = "CustomLabelFontList"


        static let PressShiftOnce: String = "PressShiftOnce"
        static let ShiftSpaceCombination: String = "ShiftSpaceCombination"
}

enum CandidatePageOrientation: Int {
        case horizontal = 1
        case vertical = 2
        static func orientation(of value: Int) -> CandidatePageOrientation {
                switch value {
                case Self.horizontal.rawValue:
                        return .horizontal
                case Self.vertical.rawValue:
                        return .vertical
                default:
                        return .horizontal
                }
        }
}

enum CommentDisplayStyle: Int {

        case top = 1
        case bottom = 2
        // case left = 3 // Unwanted
        case right = 4
        case noComments = 5

        static func style(of value: Int) -> CommentDisplayStyle {
                switch value {
                case Self.top.rawValue:
                        return .top
                case Self.bottom.rawValue:
                        return .bottom
                case Self.right.rawValue:
                        return .right
                case Self.noComments.rawValue:
                        return .noComments
                default:
                        return .top
                }
        }
        var isVertical: Bool {
                switch self {
                case .top, .bottom:
                        return true
                default:
                        return false
                }
        }
}

enum ToneDisplayStyle: Int {

        case normal = 1
        case noTones = 2
        case superscript = 3
        case `subscript` = 4

        static func style(of value: Int) -> ToneDisplayStyle {
                switch value {
                case Self.normal.rawValue:
                        return .normal
                case Self.noTones.rawValue:
                        return .noTones
                case Self.superscript.rawValue:
                        return .superscript
                case Self.subscript.rawValue:
                        return .subscript
                default:
                        return .normal
                }
        }
}
enum ToneDisplayColor: Int {

        case normal = 1

        /// 相對更淺
        case shallow = 2

        static func color(of value: Int) -> ToneDisplayColor {
                switch value {
                case Self.normal.rawValue:
                        return .normal
                case Self.shallow.rawValue:
                        return .shallow
                default:
                        return .normal
                }
        }
}

enum FontMode: Int {

        case `default` = 1
        case system = 2
        case custom = 3

        var isCustom: Bool {
                return self == .custom
        }

        static func mode(of value: Int) -> FontMode {
                switch value {
                case Self.default.rawValue:
                        return .default
                case Self.system.rawValue:
                        return .system
                case Self.custom.rawValue:
                        return .custom
                default:
                        return .default
                }
        }
}

enum PressShiftOnce: Int {
        case doNothing = 1
        case switchInputMethodMode = 2
}

enum ShiftSpaceCombination: Int {
        case inputFullWidthSpace = 1
        case switchInputMethodMode = 2
}

struct AppSettings {

        /// Preferences Window
        private(set) static var selectedPreferencesSidebarRow: PreferencesSidebarRow = .general
        static func updateSelectedPreferencesSidebarRow(to row: PreferencesSidebarRow) {
                selectedPreferencesSidebarRow = row
        }


        // MARK: - Page Size

        private(set) static var displayCandidatePageSize: Int = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CandidatePageSize)
                let isSavedValueValid: Bool = pageSizeValidity(of: savedValue)
                guard isSavedValueValid else { return defaultCandidatePageSize }
                return savedValue
        }()
        static func updateDisplayCandidatePageSize(to newPageSize: Int) {
                let isNewPageSizeValid: Bool = pageSizeValidity(of: newPageSize)
                guard isNewPageSizeValid else { return }
                displayCandidatePageSize = newPageSize
                UserDefaults.standard.set(newPageSize, forKey: SettingsKey.CandidatePageSize)
        }
        private static func pageSizeValidity(of value: Int) -> Bool {
                return candidatePageSizeRange.contains(value)
        }
        private static let defaultCandidatePageSize: Int = 7
        static let candidatePageSizeRange: Range<Int> = 1..<11


        // MARK: - Line Spacing

        private(set) static var candidateLineSpacing: Int = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CandidateLineSpacing)
                let isSavedValueValid: Bool = lineSpacingValidity(of: savedValue)
                guard isSavedValueValid else { return defaultCandidateLineSpacing }
                return savedValue
        }()
        static func updateCandidateLineSpacing(to newLineSpacing: Int) {
                let isNewLineSpacingValid: Bool = lineSpacingValidity(of: newLineSpacing)
                guard isNewLineSpacingValid else { return }
                candidateLineSpacing = newLineSpacing
                UserDefaults.standard.set(newLineSpacing, forKey: SettingsKey.CandidateLineSpacing)
        }
        private static func lineSpacingValidity(of value: Int) -> Bool {
                return candidateLineSpacingRange.contains(value)
        }
        private static let defaultCandidateLineSpacing: Int = 6
        static let candidateLineSpacingRange: Range<Int> = 0..<13


        // MARK: - Orientation

        private(set) static var candidatePageOrientation: CandidatePageOrientation = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CandidatePageOrientation)
                return CandidatePageOrientation.orientation(of: savedValue)
        }()
        static func updateCandidatePageOrientation(to orientation: CandidatePageOrientation) {
                candidatePageOrientation = orientation
                let value: Int = orientation.rawValue
                UserDefaults.standard.set(value, forKey: SettingsKey.CandidatePageOrientation)
        }


        // MARK: - Comment Display Style

        private(set) static var commentDisplayStyle: CommentDisplayStyle = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CommentDisplayStyle)
                return CommentDisplayStyle.style(of: savedValue)
        }()
        static func updateCommentDisplayStyle(to style: CommentDisplayStyle) {
                commentDisplayStyle = style
                let value: Int = style.rawValue
                UserDefaults.standard.set(value, forKey: SettingsKey.CommentDisplayStyle)
        }


        // MARK: - Tone Display Style

        private(set) static var toneDisplayStyle: ToneDisplayStyle = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.ToneDisplayStyle)
                return ToneDisplayStyle.style(of: savedValue)
        }()
        static func updateToneDisplayStyle(to style: ToneDisplayStyle) {
                toneDisplayStyle = style
                let value: Int = style.rawValue
                UserDefaults.standard.set(value, forKey: SettingsKey.ToneDisplayStyle)
        }

        private(set) static var toneDisplayColor: ToneDisplayColor = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.ToneDisplayColor)
                return ToneDisplayColor.color(of: savedValue)
        }()
        static func updateToneDisplayColor(to colorOption: ToneDisplayColor) {
                toneDisplayColor = colorOption
                let value: Int = colorOption.rawValue
                UserDefaults.standard.set(value, forKey: SettingsKey.ToneDisplayColor)
        }


        // MARK: - Cangjie / Quick Reverse Lookup

        private(set) static var cangjieVariant: CangjieVariant = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CangjieVariant)
                switch savedValue {
                case CangjieVariant.cangjie5.rawValue:
                        return .cangjie5
                case CangjieVariant.cangjie3.rawValue:
                        return .cangjie3
                case CangjieVariant.quick5.rawValue:
                        return .quick5
                case CangjieVariant.quick3.rawValue:
                        return .quick3
                default:
                        return .cangjie5
                }
        }()
        static func updateCangjieVariant(to variant: CangjieVariant) {
                cangjieVariant = variant
                let value: Int = variant.rawValue
                UserDefaults.standard.set(value, forKey: SettingsKey.CangjieVariant)
        }


        // MARK: - User Lexicon

        private(set) static var isInputMemoryOn: Bool = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.UserLexiconInputMemory)
                switch savedValue {
                case 0, 1:
                        return true
                case 2:
                        return false
                default:
                        return true
                }
        }()
        static func updateInputMemory(to isOn: Bool) {
                isInputMemoryOn = isOn
                let value: Int = isOn ? 1 : 2
                UserDefaults.standard.set(value, forKey: SettingsKey.UserLexiconInputMemory)
        }


        // MARK: - Font Size

        private(set) static var candidateFontSize: CGFloat = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CandidateFontSize)
                let isSavedValueValid: Bool = fontSizeValidity(of: savedValue)
                let size: Int = isSavedValueValid ? savedValue : defaultCandidateFontSize
                return CGFloat(size)
        }()
        static func updateCandidateFontSize(to newFontSize: Int) {
                let isNewFontSizeValid: Bool = fontSizeValidity(of: newFontSize)
                guard isNewFontSizeValid else { return }
                candidateFontSize = CGFloat(newFontSize)
                UserDefaults.standard.set(newFontSize, forKey: SettingsKey.CandidateFontSize)
                Font.updateCandidateFont()
        }

        private(set) static var commentFontSize: CGFloat = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CommentFontSize)
                let isSavedValueValid: Bool = fontSizeValidity(of: savedValue)
                let size: Int = isSavedValueValid ? savedValue : defaultCommentFontSize
                return CGFloat(size)
        }()
        static func updateCommentFontSize(to newFontSize: Int) {
                let isNewFontSizeValid: Bool = fontSizeValidity(of: newFontSize)
                guard isNewFontSizeValid else { return }
                commentFontSize = CGFloat(newFontSize)
                UserDefaults.standard.set(newFontSize, forKey: SettingsKey.CommentFontSize)
                updateSyllableViewSize()
                Font.updateCommentFont()
        }

        private(set) static var labelFontSize: CGFloat = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.LabelFontSize)
                let isSavedValueValid: Bool = fontSizeValidity(of: savedValue)
                let size: Int = isSavedValueValid ? savedValue : defaultLabelFontSize
                return CGFloat(size)
        }()
        static func updateLabelFontSize(to newFontSize: Int) {
                let isNewFontSizeValid: Bool = fontSizeValidity(of: newFontSize)
                guard isNewFontSizeValid else { return }
                labelFontSize = CGFloat(newFontSize)
                UserDefaults.standard.set(newFontSize, forKey: SettingsKey.LabelFontSize)
                Font.updateLabelFont()
        }

        private static func fontSizeValidity(of value: Int) -> Bool {
                return fontSizeRange.contains(value)
        }
        private static let defaultCandidateFontSize: Int = 17
        private static let defaultCommentFontSize: Int = 13
        private static let defaultLabelFontSize: Int = 13
        static let fontSizeRange: Range<Int> = 10..<25


        // Candidate StackView syllable text frame
        private(set) static var syllableViewSize: CGSize = computeSyllableViewSize()
        private static func updateSyllableViewSize() {
                syllableViewSize = computeSyllableViewSize()
        }
        private static func computeSyllableViewSize() -> CGSize {
                let width: CGFloat = commentFontSize * 2.0 + 8.0
                let height: CGFloat = commentFontSize
                return CGSize(width: width, height: height)
        }


        // MARK: - Font Mode

        private(set) static var candidateFontMode: FontMode = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CandidateFontMode)
                return FontMode.mode(of: savedValue)
        }()
        static func updateCandidateFontMode(to newMode: FontMode) {
                candidateFontMode = newMode
                let value: Int = newMode.rawValue
                UserDefaults.standard.set(value, forKey: SettingsKey.CandidateFontMode)
                Font.updateCandidateFont()
        }

        private(set) static var commentFontMode: FontMode = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.CommentFontMode)
                return FontMode.mode(of: savedValue)
        }()
        static func updateCommentFontMode(to newMode: FontMode) {
                commentFontMode = newMode
                let value: Int = newMode.rawValue
                UserDefaults.standard.set(value, forKey: SettingsKey.CommentFontMode)
                Font.updateCommentFont()
        }

        private(set) static var labelFontMode: FontMode = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.LabelFontMode)
                return FontMode.mode(of: savedValue)
        }()
        static func updateLabelFontMode(to newMode: FontMode) {
                labelFontMode = newMode
                let value: Int = newMode.rawValue
                UserDefaults.standard.set(value, forKey: SettingsKey.LabelFontMode)
                Font.updateLabelFont()
        }


        // MARK: - Custom Fonts

        private(set) static var customCandidateFonts: [String] = {
                let fallback: [String] = [PresetConstant.PingFangHK]
                let savedNames: String? = UserDefaults.standard.string(forKey: SettingsKey.CustomCandidateFontList)
                guard let savedNames else { return fallback }
                let names: [String] = savedNames.split(separator: ",").map({ $0.trimmed() }).filter(\.isNotEmpty).uniqued()
                guard names.isNotEmpty else { return fallback }
                return names
        }()
        static func updateCustomCandidateFonts(to fontNames: [String]) {
                let names: [String] = fontNames.map({ $0.trimmed() }).filter(\.isNotEmpty).uniqued()
                customCandidateFonts = names
                let fontList: String = names.joined(separator: ",")
                UserDefaults.standard.set(fontList, forKey: SettingsKey.CustomCandidateFontList)
                Font.updateCandidateFont()
        }

        private(set) static var customCommentFonts: [String] = {
                let fallback: [String] = [PresetConstant.HelveticaNeue]
                let savedNames: String? = UserDefaults.standard.string(forKey: SettingsKey.CustomCommentFontList)
                guard let savedNames else { return fallback }
                let names: [String] = savedNames.split(separator: ",").map({ $0.trimmed() }).filter(\.isNotEmpty).uniqued()
                guard names.isNotEmpty else { return fallback }
                return names
        }()
        static func updateCustomCommentFonts(to fontNames: [String]) {
                let names: [String] = fontNames.map({ $0.trimmed() }).filter(\.isNotEmpty).uniqued()
                customCommentFonts = names
                let fontList: String = names.joined(separator: ",")
                UserDefaults.standard.set(fontList, forKey: SettingsKey.CustomCommentFontList)
                Font.updateCommentFont()
        }

        private(set) static var customLabelFonts: [String] = {
                let fallback: [String] = [PresetConstant.Menlo]
                let savedNames = UserDefaults.standard.string(forKey: SettingsKey.CustomLabelFontList)
                guard let savedNames else { return fallback }
                let names: [String] = savedNames.split(separator: ",").map({ $0.trimmed() }).filter(\.isNotEmpty).uniqued()
                guard names.isNotEmpty else { return fallback }
                return names
        }()
        static func updateCustomLabelFonts(to fontNames: [String]) {
                let names: [String] = fontNames.map({ $0.trimmed() }).filter(\.isNotEmpty).uniqued()
                customLabelFonts = names
                let fontList: String = names.joined(separator: ",")
                UserDefaults.standard.set(fontList, forKey: SettingsKey.CustomLabelFontList)
                Font.updateLabelFont()
        }


        // MARK: - Hotkeys

        /// Press Shift Key Once TO
        ///
        /// 1. Do Nothing
        /// 2. Switch between Cantonese and English
        private(set) static var pressShiftOnce: PressShiftOnce = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.PressShiftOnce)
                switch savedValue {
                case 0, 1:
                        return .doNothing
                case 2:
                        return .switchInputMethodMode
                default:
                        return .doNothing
                }
        }()
        static func updatePressShiftOnce(to option: PressShiftOnce) {
                pressShiftOnce = option
                let value: Int = switch option {
                case .doNothing: 1
                case .switchInputMethodMode: 2
                }
                UserDefaults.standard.set(value, forKey: SettingsKey.PressShiftOnce)
        }

        /// Press Shift+Space TO
        ///
        /// 1. Input Full-width Space (U+3000)
        /// 2. Switch between Cantonese and English
        private(set) static var shiftSpaceCombination: ShiftSpaceCombination = {
                let savedValue: Int = UserDefaults.standard.integer(forKey: SettingsKey.ShiftSpaceCombination)
                switch savedValue {
                case 0, 1:
                        return .inputFullWidthSpace
                case 2:
                        return .switchInputMethodMode
                default:
                        return .inputFullWidthSpace
                }
        }()
        static func updateShiftSpaceCombination(to option: ShiftSpaceCombination) {
                shiftSpaceCombination = option
                let value: Int = switch option {
                case .inputFullWidthSpace: 1
                case .switchInputMethodMode: 2
                }
                UserDefaults.standard.set(value, forKey: SettingsKey.ShiftSpaceCombination)
        }
}
