import SwiftUI

struct TonesTable: View {

        #if os(iOS)
        @Environment(\.horizontalSizeClass) var horizontalSize
        #endif

        private var responsiveWidth: CGFloat {
                #if os(macOS)
                return 128
                #else
                if Device.isPhone {
                        return (UIScreen.main.bounds.width - 64) / 4.0
                } else if horizontalSize == .compact {
                        return 80
                } else {
                        return 128
                }
                #endif
        }
        private var responsiveFont: Font {
                #if os(macOS)
                return Font.fixedWidth
                #else
                if Device.isPhone {
                        return Font.callout
                } else if horizontalSize == .compact {
                        return Font.subheadline
                } else {
                        return Font.fixedWidth
                }
                #endif
        }

        private let tonesDescription: VStack = {
                VStack(spacing: 0) {
                        HStack {
                                Text(verbatim: "聲調之「上」應讀上聲 soeng5")
                                Speaker("soeng5")
                                Spacer()
                        }
                        HStack {
                                Text(verbatim: "而非去聲 soeng6")
                                Speaker("soeng6")
                                Spacer()
                        }
                }
        }()

        var body: some View {
                let dataLines: [String] = sourceText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).map({ $0.trimmingCharacters(in: .whitespaces) })
                let width: CGFloat = responsiveWidth
                #if os(macOS)
                ScrollView {
                        LazyVStack {
                                VStack {
                                        ForEach(0..<dataLines.count, id: \.self) { index in
                                                ToneCell(dataLines[index], width: width)
                                        }
                                }
                                .font(responsiveFont)
                                .block()

                                HStack(spacing: 12) {
                                        HStack(spacing: 0) {
                                                Text(verbatim: "聲調之「上」應讀上聲 soeng5")
                                                Speaker("soeng5")
                                        }
                                        HStack(spacing: 0) {
                                                Text(verbatim: "而非去聲 soeng6")
                                                Speaker("soeng6")
                                        }
                                        Spacer()
                                }
                                .padding()
                        }
                        .padding(32)
                }
                .textSelection(.enabled)
                .navigationTitle("Jyutping Tones")
                #else
                List {
                        Section {
                                ForEach(0..<dataLines.count, id: \.self) { index in
                                        ToneCell(dataLines[index], width: width)
                                }
                        }
                        Section {
                                tonesDescription
                        }
                }
                .font(responsiveFont)
                .listStyle(.insetGrouped)
                .navigationTitle("Jyutping Tones")
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }


private let sourceText: String = """
例字,調值,聲調,粵拼
芬 fan1,55/53,陰平,1
粉 fan2,35,陰上,2
訓 fan3,33,陰去,3
焚 fan4,11/21,陽平,4
奮 fan5,13/23,陽上,5
份 fan6,22,陽去,6
忽 fat1,5,高陰入,1
法 faat3,3,低陰入,3
罰 fat6,2,陽入,6
"""


}


private struct ToneCell: View {

        init(_ line: String, width: CGFloat) {
                let parts: [String] = line.components(separatedBy: ",")
                self.components = parts
                self.width = width
                self.syllable = String(parts[0].dropFirst(2))
        }

        private let components: [String]
        private let width: CGFloat
        private let syllable: String

        var body: some View {
                HStack {
                        HStack(spacing: 8) {
                                Text(verbatim: components[0])
                                if !syllable.isEmpty {
                                        Speaker(syllable)
                                }
                        }
                        .frame(width: width + 25, alignment: .leading)
                        Text(verbatim: components[1]).frame(width: width - 14, alignment: .leading)
                        Text(verbatim: components[2]).frame(width: width - 14, alignment: .leading)
                        Text(verbatim: components[3])
                        Spacer()
                }
        }
}

