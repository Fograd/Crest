import SwiftUI

/// The shared Window group, plus the choices only the desktop has.
struct BrowserPlatformAppearanceSettingsSection: View {
    // MARK: - Variables

    var space: BrowserSpaceAppearance?
    var showsPreview = false

    @AppStorage(BrowserChromeAppearancePreference.toolbarAtTopKey, store: BrowserChromeAppearancePreference.defaults)
    private var toolbarAtTop = BrowserLookAndFeelDefaults.toolbarAtTop
    @AppStorage(SpacePageMotionPreference.key)
    private var animatesSpacePages = SpacePageMotionPreference.defaultValue
    @AppStorage(SidebarRevealWidthPreference.key, store: BrowserChromeAppearancePreference.defaults)
    private var sidebarRevealWidth = SidebarRevealWidthPreference.defaultValue

    var body: some View {
        let toolbarPosition = CrestSettingValue($toolbarAtTop, default: BrowserLookAndFeelDefaults.toolbarAtTop)
        let motion = CrestSettingValue($animatesSpacePages, default: SpacePageMotionPreference.defaultValue)

        let revealWidth = CrestSettingValue($sidebarRevealWidth, default: SidebarRevealWidthPreference.defaultValue)

        return BrowserWindowAppearanceGroup(
            space: space,
            showsPreview: showsPreview,
            extraSettings: [
                toolbarPosition.resettable("Toolbar position"),
                motion.resettable("Animate pages when switching Spaces"),
                revealWidth.resettable("Sidebar hover area"),
            ]
        ) {
            CrestSettingRow("Toolbar position", setting: toolbarPosition.resettable("Toolbar position")) {
                Picker("Toolbar position", selection: toolbarPosition.binding) {
                    Text("Sidebar").tag(false)
                    Text("Top").tag(true)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
                .accessibilityLabel("Toolbar position")
                .accessibilityIdentifier("toolbar-position")
            }

            CrestSettingRow(
                "Animate pages when switching Spaces",
                setting: motion.resettable("Animate pages when switching Spaces")
            ) {
                Toggle("Animate pages when switching Spaces", isOn: motion.binding)
                    .labelsHidden()
                    .accessibilityIdentifier("animate-space-pages")
            }

            CrestSettingSlider(
                "Sidebar hover area",
                value: revealWidth,
                range: SidebarRevealWidthPreference.range,
                readout: .points,
                identifier: "sidebar-reveal-width",
                onEditingChanged: { _ in SidebarRevealWidthPreview.shared.adjusted() }
            )
            .onChange(of: sidebarRevealWidth) { SidebarRevealWidthPreview.shared.adjusted() }
        }
    }
}
