import SwiftUI

struct HotkeysView: View {

        @AppStorage(SettingsKey.PressShiftOnce) private var pressShiftOnce: Int = AppSettings.pressShiftOnce.rawValue
        @AppStorage(SettingsKey.ShiftSpaceCombination) private var shiftSpaceCombination: Int = AppSettings.shiftSpaceCombination.rawValue

        var body: some View {
                ScrollView {
                        LazyVStack(spacing: 16) {
                                VStack {
                                        HStack {
                                                Picker("HotkeysView.PressShiftOnceTo", selection: $pressShiftOnce) {
                                                        Text("HotkeysView.PressShiftOnceTo.DoNothing").tag(1)
                                                        Text("HotkeysView.SwitchInputMethodMode").tag(2)
                                                }
                                                .scaledToFit()
                                                .onChange(of: pressShiftOnce) { newValue in
                                                        AppSettings.updatePressShiftOnce(to: newValue)
                                                }
                                                Spacer()
                                        }
                                        HStack {
                                                Picker("HotkeysView.PressShiftSpaceTo", selection: $shiftSpaceCombination) {
                                                        Text("HotkeysView.PressShiftSpaceTo.InputFullWidthSpace").tag(1)
                                                        Text("HotkeysView.SwitchInputMethodMode").tag(2)
                                                }
                                                .scaledToFit()
                                                .onChange(of: shiftSpaceCombination) { newValue in
                                                        AppSettings.updateShiftSpaceCombination(to: newValue)
                                                }
                                                Spacer()
                                        }
                                }
                                .block()
                                VStack(spacing: 8) {
                                        HStack(spacing: 4) {
                                                LabelText("HotkeysView.OpenPreferencesWindow")
                                                Text.separator
                                                KeyBlockView.control
                                                Text.plus
                                                KeyBlockView.shift
                                                Text.plus
                                                KeyBlockView(",")
                                                Spacer()
                                        }
                                        HStack(spacing: 4) {
                                                LabelText("HotkeysView.EnterExitOptionsView")
                                                Text.separator
                                                KeyBlockView.control
                                                Text.plus
                                                KeyBlockView.shift
                                                Text.plus
                                                KeyBlockView("`")
                                                Spacer()
                                        }
                                }
                                .block()
                                VStack(spacing: 2) {
                                        HStack(spacing: 4) {
                                                LabelText("HotkeysView.DirectlyToggleSpecificOption")
                                                Text.separator
                                                KeyBlockView.control
                                                Text.plus
                                                KeyBlockView.shift
                                                Text.plus
                                                KeyBlockView.number
                                                Spacer()
                                        }
                                        .block()
                                        HStack {
                                                Text(verbatim: "number: 1, 2, 3, ... 8, 9, 0").font(.subheadline).padding(.horizontal)
                                                Spacer()
                                        }
                                }
                                HStack(spacing: 4) {
                                        LabelText("HotkeysView.RemoveCurrentCandidateFromUserLexicon")
                                        Text.separator
                                        KeyBlockView.control
                                        Text.plus
                                        KeyBlockView.shift
                                        Text.plus
                                        KeyBlockView.backwardDelete
                                        Spacer()
                                }
                                .block()
                                HStack(spacing: 4) {
                                        LabelText("HotkeysView.ClearCurrentPreEditText")
                                        Text.separator
                                        KeyBlockView.escape
                                        Spacer()
                                }
                                .block()
                                VStack(spacing: 2) {
                                        HStack {
                                                Text("HotkeysView.Header.HorizontalOrientation").font(.subheadline).padding(.horizontal)
                                                Spacer()
                                        }
                                        VStack(spacing: 8) {
                                                HStack(spacing: 4) {
                                                        LabelText("HotkeysView.MoveToPreviousCandidate")
                                                        Text.separator
                                                        KeyBlockView("◀")
                                                        Text.or
                                                        KeyBlockView.shift
                                                        Text.plus
                                                        KeyBlockView.tab
                                                        Spacer()
                                                }
                                                HStack(spacing: 4) {
                                                        LabelText("HotkeysView.MoveToNextCandidate")
                                                        Text.separator
                                                        KeyBlockView("▶")
                                                        Text.or
                                                        KeyBlockView.tab
                                                        Spacer()
                                                }
                                                HStack(spacing: 4) {
                                                        LabelText("HotkeysView.BackwardToPreviousCandidatePage")
                                                        Text.separator
                                                        KeyBlockView("▲")
                                                        Text.or
                                                        KeyBlockView("-")
                                                        Text.or
                                                        KeyBlockView("Page Up ↑")
                                                        Spacer()
                                                }
                                                HStack(spacing: 4) {
                                                        LabelText("HotkeysView.ForwardToNextCandidatePage")
                                                        Text.separator
                                                        KeyBlockView("▼")
                                                        Text.or
                                                        KeyBlockView("=")
                                                        Text.or
                                                        KeyBlockView("Page Down ↓")
                                                        Spacer()
                                                }
                                        }
                                        .block()
                                }
                                VStack(spacing: 2) {
                                        HStack {
                                                Text("HotkeysView.Header.VerticalOrientation").font(.subheadline).padding(.horizontal)
                                                Spacer()
                                        }
                                        VStack(spacing: 8) {
                                                HStack(spacing: 4) {
                                                        LabelText("HotkeysView.MoveToPreviousCandidate")
                                                        Text.separator
                                                        KeyBlockView("▲")
                                                        Text.or
                                                        KeyBlockView.shift
                                                        Text.plus
                                                        KeyBlockView.tab
                                                        Spacer()
                                                }
                                                HStack(spacing: 4) {
                                                        LabelText("HotkeysView.MoveToNextCandidate")
                                                        Text.separator
                                                        KeyBlockView("▼")
                                                        Text.or
                                                        KeyBlockView.tab
                                                        Spacer()
                                                }
                                                HStack(spacing: 4) {
                                                        LabelText("HotkeysView.BackwardToPreviousCandidatePage")
                                                        Text.separator
                                                        KeyBlockView("◀")
                                                        Text.or
                                                        KeyBlockView("-")
                                                        Text.or
                                                        KeyBlockView("Page Up ↑")
                                                        Spacer()
                                                }
                                                HStack(spacing: 4) {
                                                        LabelText("HotkeysView.ForwardToNextCandidatePage")
                                                        Text.separator
                                                        KeyBlockView("▶")
                                                        Text.or
                                                        KeyBlockView("=")
                                                        Text.or
                                                        KeyBlockView("Page Down ↓")
                                                        Spacer()
                                                }
                                        }
                                        .block()
                                }
                                HStack(spacing: 4) {
                                        LabelText("HotkeysView.BackToFirstCandidatePage")
                                        Text.separator
                                        KeyBlockView("Home ⤒")
                                        Spacer()
                                }
                                .block()
                        }
                        .textSelection(.enabled)
                        .padding()
                }
                .navigationTitle("PreferencesView.NavigationTitle.Hotkeys")
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

        var body: some View {
                Text(verbatim: keyText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .frame(width: 72, height: 24)
                        .background(Material.regular, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
        }

        static let control: KeyBlockView = KeyBlockView("Control ⌃")
        static let shift: KeyBlockView = KeyBlockView("Shift ⇧")
        static let number: KeyBlockView = KeyBlockView("number")
        static let space: KeyBlockView = KeyBlockView("Space ␣")
        static let escape: KeyBlockView = KeyBlockView("Esc ⎋")
        static let tab: KeyBlockView = KeyBlockView("Tab ⇥")

        /// Backspace. NOT Forward-Delete.
        static let backwardDelete: KeyBlockView = KeyBlockView("Delete ⌫")
}


private extension Text {
        static let separator: Text = Text(verbatim: ": ").foregroundColor(.secondary)
        static let plus: Text = Text(verbatim: "+")
        static let or: Text = Text("HotkeysView.Or")
}

