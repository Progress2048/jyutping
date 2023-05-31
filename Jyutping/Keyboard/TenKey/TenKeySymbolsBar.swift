import SwiftUI

struct TenKeySymbolsBar: View {

        @EnvironmentObject private var context: KeyboardViewController

        @Environment(\.colorScheme) private var colorScheme
        private var keyColor: Color {
                switch colorScheme {
                case .light:
                        return .lightEmphatic
                case .dark:
                        return .darkEmphatic
                @unknown default:
                        return .lightEmphatic
                }
        }

        private let abcPadSymbols: [String] = ["，", "。", "？", "！", "…", "……", "、", "~", "～"]
        private let numericPadSymbols: [String] = ["+", "-", "*", "/", "=", "%", "#", ":", "@"]

        var body: some View {
                let symbols: [String] = (context.keyboardForm == .tenKeyNumeric) ? numericPadSymbols : abcPadSymbols
                ZStack {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(keyColor)
                                .shadow(color: .black.opacity(0.4), radius: 0.5, y: 1)
                        ScrollView {
                                LazyVStack(spacing: 0) {
                                        ForEach(0..<symbols.count, id: \.self) { index in
                                                ZStack {
                                                        Color.interactiveClear
                                                        Text(verbatim: symbols[index])
                                                }
                                                .frame(height: context.heightUnit * 3.0 / 4.0 - 1.0)
                                                .frame(maxWidth: .infinity)
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                        AudioFeedback.inputed()
                                                        context.triggerHapticFeedback()
                                                        context.operate(.input(symbols[index]))
                                                }
                                                Divider()
                                        }
                                }
                        }
                }
                .padding(3)
                .frame(width: context.widthUnit * 2, height: context.heightUnit * 3)
        }
}
