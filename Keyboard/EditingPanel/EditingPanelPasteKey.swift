import SwiftUI
import CommonExtensions

struct EditingPanelPasteKey: View {

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
        private var activeKeyColor: Color {
                switch colorScheme {
                case .light:
                        return .light
                case .dark:
                        return .dark
                @unknown default:
                        return .light
                }
        }

        @GestureState private var isTouching: Bool = false

        var body: some View {
                ZStack {
                        Color.interactiveClear
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(isTouching ? activeKeyColor : keyColor)
                                .shadow(color: .black.opacity(0.4), radius: 0.5, y: 1)
                                .padding(4)
                        VStack(spacing: 4) {
                                Image(systemName: "doc.on.clipboard")
                                Text("EditingPanel.Paste").font(.caption2)
                        }
                        .opacity(context.isClipboardEmpty ? 0.5 : 1)
                }
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0)
                        .updating($isTouching) { _, tapped, _ in
                                if !tapped {
                                        AudioFeedback.inputed()
                                        context.triggerHapticFeedback()
                                        tapped = true
                                }
                        }
                        .onEnded { _ in
                                context.operate(.paste)
                        }
                )
        }
}

@available(iOS 16.0, *)
@available(iOSApplicationExtension 16.0, *)
struct EditingPanelSystemPasteKey: View {
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
        var body: some View {
                ZStack {
                        Color.clear
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(keyColor)
                                .shadow(color: .black.opacity(0.4), radius: 0.5, y: 1)
                                .padding(4)
                        VStack(spacing: 0) {
                                PasteButton(payloadType: String.self) { strings in
                                        AudioFeedback.inputed()
                                        context.triggerHapticFeedback()
                                        guard let text = strings.first, text.isNotEmpty else { return }
                                        context.operate(.input(text))
                                }
                                .buttonBorderShape(.roundedRectangle)
                                .labelStyle(.iconOnly)
                                .tint(.gray)
                                Text("EditingPanel.Paste").font(.caption2).opacity(context.isClipboardEmpty ? 0.5 : 1)
                        }
                }
        }
}
