import SwiftUI

struct BottlePickerView: View {
    @Environment(CrossOverService.self) private var crossOver

    var body: some View {
        if crossOver.bottles.isEmpty {
            EmptyView()
        } else {
            HStack(spacing: 6) {
                Image(systemName: "wineglass")
                Picker("Bottle", selection: .constant(crossOver.primaryBottle())) {
                    ForEach(crossOver.bottles) { bottle in
                        Text(bottle.name).tag(Optional(bottle))
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 160)
            }
        }
    }
}
