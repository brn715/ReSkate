import SwiftUI

/// Collapsed badge — we only ever launch into `skate-fex` on Preview, so there's
/// nothing to pick. Shows bottle state inline instead.
struct BottlePickerView: View {
    @Environment(CrossOverService.self) private var crossOver

    var body: some View {
        if let bottle = crossOver.bottle {
            HStack(spacing: 6) {
                Image(systemName: "wineglass.fill")
                Text(bottle.name)
                if bottle.hasGameInstalled {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
            }
            .foregroundStyle(.secondary)
            .font(.callout)
        }
    }
}
