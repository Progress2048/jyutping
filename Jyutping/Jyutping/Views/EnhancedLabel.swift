import SwiftUI

@available(iOS 15.0, *)
struct EnhancedLabel: View {

        private let title: LocalizedStringKey
        private let icon: String
        private let message: Text?
        private let symbol: Image?
        private let tintColor: Color

        init(_ title: LocalizedStringKey, icon: String, message: Text? = nil, symbol: Image? = nil, tintColor: Color = .primary) {
                self.title = title
                self.icon = icon
                self.message = message
                self.symbol = symbol
                self.tintColor = tintColor
        }

        var body: some View {
                if message == nil && symbol == nil {
                        Label {
                                Text(title).tint(tintColor)
                        } icon: {
                                Image(systemName: icon)
                        }
                } else if symbol == nil {
                        HStack {
                                Label {
                                        Text(title).tint(tintColor)
                                } icon: {
                                        Image(systemName: icon)
                                }
                                Spacer()
                                message.tint(tintColor)
                        }
                } else if message == nil {
                        HStack {
                                Label {
                                        Text(title).tint(tintColor)
                                } icon: {
                                        Image(systemName: icon)
                                }
                                Spacer()
                                symbol?.foregroundColor(.secondary)
                        }
                } else {
                        HStack {
                                Label {
                                        Text(title).tint(tintColor)
                                } icon: {
                                        Image(systemName: icon)
                                }
                                Spacer()
                                message?.tint(tintColor)
                                symbol?.foregroundColor(.secondary)
                        }
                }
        }
}

@available(iOS 15.0, *)
struct EnhancedLabel_Previews: PreviewProvider {
        static var previews: some View {
                EnhancedLabel("Test Text",
                              icon: "info.circle",
                              message: Text("Test Message"),
                              symbol: Image(systemName: "plus"))
        }
}
