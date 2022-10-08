import SwiftUI

struct HotkeysView: View {

        @AppStorage(SettingsKeys.PressShiftOnce) private var pressShiftOnce: Int = AppSettings.pressShiftOnce.rawValue

        var body: some View {
                ScrollView {
                        LazyVStack(spacing: 16) {
                                HStack {
                                        Picker("Press Shift Once To", selection: $pressShiftOnce) {
                                                Text("Do Nothing").tag(1)
                                                Text("Switch between Cantonese and English").tag(2)
                                        }
                                        .scaledToFit()
                                        .pickerStyle(.radioGroup)
                                        .onChange(of: pressShiftOnce) { newValue in
                                                AppSettings.updatePressShiftOnce(to: newValue)
                                        }
                                        Spacer()
                                }
                                .block()
                                VStack(spacing: 8) {
                                        HStack(spacing: 4) {
                                                LabelText("Open Preferences Window (This Window)")
                                                Text.separator
                                                KeyBlockView.Control
                                                Text.plus
                                                KeyBlockView.Shift
                                                Text.plus
                                                KeyBlockView(",")
                                                Spacer()
                                        }
                                        HStack(spacing: 4) {
                                                LabelText("Open/Close InstantSettings Window")
                                                Text.separator
                                                KeyBlockView.Control
                                                Text.plus
                                                KeyBlockView.Shift
                                                Text.plus
                                                KeyBlockView("`")
                                                Spacer()
                                        }
                                }
                                .block()
                                VStack {
                                        HStack(spacing: 4) {
                                                LabelText("Directly toggle InstantSettings options")
                                                Text.separator
                                                KeyBlockView.Control
                                                Text.plus
                                                KeyBlockView.Shift
                                                Text.plus
                                                KeyBlockView("1~0")
                                                Spacer()
                                        }
                                }
                                .block()
                                VStack(spacing: 8) {
                                        HStack(spacing: 4) {
                                                LabelText("Switch to Cantonese Mode")
                                                Text.separator
                                                KeyBlockView.Control
                                                Text.plus
                                                KeyBlockView.Shift
                                                Text.plus
                                                KeyBlockView("-")
                                                Spacer()
                                        }
                                        HStack(spacing: 4) {
                                                LabelText("Switch to English Mode")
                                                Text.separator
                                                KeyBlockView.Control
                                                Text.plus
                                                KeyBlockView.Shift
                                                Text.plus
                                                KeyBlockView("=")
                                                Spacer()
                                        }
                                }
                                .block()
                                HStack(spacing: 4) {
                                        LabelText("Remove highlighted Candidate from User Lexicon")
                                        Text.separator
                                        KeyBlockView.Control
                                        Text.plus
                                        KeyBlockView.Shift
                                        Text.plus
                                        KeyBlockView.BackwardDelete
                                        Spacer()
                                }
                                .block()
                                HStack(spacing: 4) {
                                        LabelText("Clear current Input Buffer")
                                        Text.separator
                                        KeyBlockView.escape
                                        Spacer()
                                }
                                .block()
                                VStack(spacing: 8) {
                                        HStack(spacing: 4) {
                                                LabelText("Highlight previous Candidate")
                                                Text.separator
                                                KeyBlockView("▲")
                                                Spacer()
                                        }
                                        HStack(spacing: 4) {
                                                LabelText("Highlight next Candidate")
                                                Text.separator
                                                KeyBlockView("▼")
                                                Spacer()
                                        }
                                        HStack(spacing: 4) {
                                                LabelText("Backward to previous Candidate page")
                                                Text.separator
                                                KeyBlockView("-")
                                                Text("or")
                                                KeyBlockView("[")
                                                Text("or")
                                                KeyBlockView(",")
                                                Text("or")
                                                KeyBlockView("Page Up ↑")
                                                Spacer()
                                        }
                                        HStack(spacing: 4) {
                                                LabelText("Forward to next Candidate page")
                                                Text.separator
                                                KeyBlockView("=")
                                                Text("or")
                                                KeyBlockView("]")
                                                Text("or")
                                                KeyBlockView(".")
                                                Text("or")
                                                KeyBlockView("Page Down ↓")
                                                Spacer()
                                        }
                                        HStack(spacing: 4) {
                                                LabelText("Jump to the first Candidate page")
                                                Text.separator
                                                KeyBlockView("Home ⤒")
                                                Spacer()
                                        }
                                }
                                .block()
                        }
                        .textSelection(.enabled)
                        .padding(.bottom)
                        .padding()
                }
                .navigationTitle("Hotkeys")
        }
}


private struct LabelText: View {
        init(_ title: LocalizedStringKey) {
                self.title = title
        }
        private let title: LocalizedStringKey
        var body: some View {
                Text(title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(width: 270, alignment: .leading)
        }
}


private struct KeyBlockView: View {

        init(_ keyText: String) {
                self.keyText = keyText
        }

        private let keyText: String
        private let backColor: Color = Color(nsColor: NSColor.textBackgroundColor)

        var body: some View {
                Text(verbatim: keyText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(2)
                        .frame(width: 72)
                        .background(backColor, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
        }

        static let Control: KeyBlockView = KeyBlockView("Control ⌃")
        static let Shift: KeyBlockView = KeyBlockView("Shift ⇧")
        static let Space: KeyBlockView = KeyBlockView("Space ␣")
        static let escape: KeyBlockView = KeyBlockView("esc ⎋")

        /// Backspace. NOT Forward Delete.
        static let BackwardDelete: KeyBlockView = KeyBlockView("Delete ⌫")
}


private extension Text {
        static let separator: Text = Text(verbatim: ": ").foregroundColor(.secondary)
        static let plus: Text = Text(verbatim: "+")
}

