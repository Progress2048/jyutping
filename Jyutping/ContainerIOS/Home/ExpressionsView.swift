import SwiftUI

struct ExpressionsView: View {
        var body: some View {
                List {
                        Group {
                                Section {
                                        Label {
                                                Text(verbatim: "第二人稱代詞")
                                        } icon: {
                                                Image(systemName: "1.circle")
                                        }
                                        .font(.headline)

                                        Label {
                                                Text(verbatim: "單數：你")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "複數：你哋／你等")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "毋用「您」。「您」係北京方言用字，好少見於其他漢語。如果要用敬詞，粵語一般用「閣下」")
                                        } icon: {
                                                Image.warning.foregroundColor(.orange)
                                        }
                                        Label {
                                                Text(verbatim: "毋推薦用「妳」，冇必要畫蛇添足")
                                        } icon: {
                                                Image.warning.foregroundColor(.orange)
                                        }
                                }
                                Section {
                                        Label {
                                                Text(verbatim: "第三人稱代詞")
                                        } icon: {
                                                Image(systemName: "2.circle")
                                        }
                                        .font(.headline)

                                        Label {
                                                Text(verbatim: "單數：佢")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "複數：佢哋／佢等")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "避免：他、她、它、他們、她們")
                                        } icon: {
                                                Image.warning.foregroundColor(.orange)
                                        }
                                        Label {
                                                Text(verbatim: "佢亦作渠、⿰亻渠、其")
                                        } icon: {
                                                Image(systemName: "info.circle").foregroundColor(.primary)
                                        }
                                }
                        }
                        Group {
                                Section {
                                        Label {
                                                Text(verbatim: "區分「係」同「喺」")
                                        } icon: {
                                                Image(systemName: "3.circle")
                                        }
                                        .font(.headline)
                                        Label {
                                                Text(verbatim: """
                                                係 hai6：謂語，義同是。
                                                喺 hai2：表方位、時間，義同在。
                                                """)
                                        } icon: {
                                                Image(systemName: "info.circle").hidden()
                                        }
                                        Label {
                                                Text(verbatim: """
                                                例：我係曹阿瞞。
                                                例：我喺天后站落車。
                                                """)
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green).hidden()
                                        }
                                }
                                .lineSpacing(5)

                                Section {
                                        Label {
                                                Text(verbatim: "區分「諗」同「冧」")
                                        } icon: {
                                                Image(systemName: "4.circle")
                                        }
                                        .font(.headline)
                                        Label {
                                                Text(verbatim: """
                                                諗 nam2：想、思考、覺得。
                                                冧 lam3：表示倒塌、倒下。
                                                """)
                                        } icon: {
                                                Image(systemName: "info.circle").hidden()
                                        }
                                        Label {
                                                Text(verbatim: """
                                                例：我諗緊今晚食咩。
                                                例：佢畀人㨃冧咗。
                                                """)
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green).hidden()
                                        }
                                }
                                .lineSpacing(5)

                                Section {
                                        Label {
                                                Text(verbatim: "區分「咁」同「噉」")
                                        } icon: {
                                                Image(systemName: "5.circle")
                                        }
                                        .font(.headline)

                                        Label {
                                                Text(verbatim: """
                                                咁 gam3，音同「禁」。
                                                噉 gam2，音同「感」。
                                                """)
                                        } icon: {
                                                Image(systemName: "info.circle").hidden()
                                        }
                                        Label {
                                                Text(verbatim: """
                                                例：我生得咁靚仔。
                                                例：噉又未必。
                                                """)
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green).hidden()
                                        }
                                }
                                .lineSpacing(5)
                        }
                        Group {
                                Section {
                                        Label {
                                                HStack {
                                                        Text(verbatim: "推薦").fontWeight(.medium)
                                                        Text(verbatim: "嘅／個得噉。")
                                                        Text(verbatim: "避免").fontWeight(.medium)
                                                        Text(verbatim: "的得地")
                                                }
                                        } icon: {
                                                Image(systemName: "6.circle").font(.headline)
                                        }
                                        Label {
                                                Text(verbatim: """
                                                例：我嘅細佬／我個細佬。
                                                例：講得好！
                                                例：細細聲噉講話。
                                                """)
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green).hidden()
                                        }
                                }
                                .lineSpacing(5)

                                Section {
                                        Label {
                                                HStack {
                                                        Text(verbatim: "推薦").fontWeight(.medium)
                                                        Text(verbatim: "啩、啊嘛。")
                                                        Text(verbatim: "避免").fontWeight(.medium)
                                                        Text(verbatim: "吧")
                                                }
                                        } icon: {
                                                Image(systemName: "7.circle").font(.headline)
                                        }
                                        Label {
                                                Text(verbatim: "下個禮拜會出啩。")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "毋係啊嘛，真係冇？")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "下個禮拜會出吧。")
                                        } icon: {
                                                Image.xmark.foregroundColor(.red)
                                        }
                                        Label {
                                                Text(verbatim: "毋係吧，真係冇？")
                                        } icon: {
                                                Image.xmark.foregroundColor(.red)
                                        }
                                }
                                Section {
                                        Label {
                                                HStack {
                                                        Text(verbatim: "推薦").fontWeight(.medium)
                                                        Text(verbatim: "啦、嘞。")
                                                        Text(verbatim: "避免").fontWeight(.medium)
                                                        Text(verbatim: "了")
                                                }
                                        } icon: {
                                                Image(systemName: "8.circle").font(.headline)
                                        }
                                        Label {
                                                Text(verbatim: "各位，我毋客氣啦。")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "係嘞，你試過箇間餐廳未呀？")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "各位，我毋客氣了。")
                                        } icon: {
                                                Image.xmark.foregroundColor(.red)
                                        }
                                        Label {
                                                Text(verbatim: "係了，你試過箇間餐廳未呀？")
                                        } icon: {
                                                Image.xmark.foregroundColor(.red)
                                        }
                                }
                                Section {
                                        Label {
                                                HStack {
                                                        Text(verbatim: "推薦").fontWeight(.medium)
                                                        Text(verbatim: "使。")
                                                        Text(verbatim: "避免").fontWeight(.medium)
                                                        Text(verbatim: "駛、洗")
                                                }
                                        } icon: {
                                                Image(systemName: "9.circle").font(.headline)
                                        }
                                        Label {
                                                Text(verbatim: "毋使驚")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "毋駛驚")
                                        } icon: {
                                                Image.xmark.foregroundColor(.red)
                                        }
                                        Label {
                                                Text(verbatim: "毋洗驚")
                                        } icon: {
                                                Image.xmark.foregroundColor(.red)
                                        }
                                }
                                Section {
                                        Label {
                                                HStack {
                                                        Text(verbatim: "推薦").fontWeight(.medium)
                                                        Text(verbatim: "而家／而今。")
                                                        Text(verbatim: "避免").fontWeight(.medium)
                                                        Text(verbatim: "宜家")
                                                }
                                        } icon: {
                                                Image(systemName: "10.circle").font(.headline)
                                        }
                                        Label {
                                                Text(verbatim: "我而家食緊飯。")
                                        } icon: {
                                                Image.checkmark.foregroundColor(.green)
                                        }
                                        Label {
                                                Text(verbatim: "我宜家食緊飯。")
                                        } icon: {
                                                Image.xmark.foregroundColor(.red)
                                        }
                                }
                        }
                }
                .navigationTitle("title.expressions")
                #if os(iOS)
                .listStyle(.insetGrouped)
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }
}
