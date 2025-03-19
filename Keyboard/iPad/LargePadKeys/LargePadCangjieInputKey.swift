import SwiftUI
import CoreIME
import CommonExtensions

struct LargePadCangjieInputKey: View {

        init(_ letter: Character) {
                let radical: Character = CharacterStandard.cangjie(of: letter) ?? "?"
                self.letter = String(letter)
                self.radical = String(radical)
        }

        private let letter: String
        private let radical: String

        @EnvironmentObject private var context: KeyboardViewController

        @Environment(\.colorScheme) private var colorScheme
        private var keyColor: Color {
                switch colorScheme {
                case .light:
                        return .light
                case .dark:
                        return .dark
                @unknown default:
                        return .light
                }
        }
        private var activeKeyColor: Color {
                switch colorScheme {
                case .light:
                        return .lightEmphatic
                case .dark:
                        return .darkEmphatic
                @unknown default:
                        return .lightEmphatic
                }
        }

        @GestureState private var isTouching: Bool = false

        var body: some View {
                let keyWidth: CGFloat = context.widthUnit
                let keyHeight: CGFloat = context.heightUnit
                let isLandscape: Bool = context.keyboardInterface.isPadLandscape
                let verticalPadding: CGFloat = isLandscape ? 5 : 4
                let horizontalPadding: CGFloat = isLandscape ? 5 : 4
                let shouldShowLowercaseKeys: Bool = Options.showLowercaseKeys && context.keyboardCase.isLowercased
                let textCase: Text.Case = shouldShowLowercaseKeys ? .lowercase : .uppercase
                ZStack {
                        Color.interactiveClear
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(isTouching ? activeKeyColor : keyColor)
                                .shadow(color: .shadowGray, radius: 0.5, y: 0.5)
                                .padding(.vertical, verticalPadding)
                                .padding(.horizontal, horizontalPadding)
                        ZStack(alignment: .topTrailing) {
                                Color.clear
                                Text(verbatim: letter)
                                        .textCase(textCase)
                                        .font(.footnote)
                                        .opacity(0.8)
                        }
                        .padding(.vertical, verticalPadding + 4)
                        .padding(.horizontal, horizontalPadding + 4)
                        Text(verbatim: radical)
                }
                .frame(width: keyWidth, height: keyHeight)
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                        .updating($isTouching) { _, tapped, _ in
                                if tapped.negative {
                                        AudioFeedback.inputed()
                                        tapped = true
                                }
                        }
                        .onEnded { _ in
                                let text: String = context.keyboardCase.isLowercased ? letter : letter.uppercased()
                                context.operate(.process(text))
                         }
                )
        }
}
