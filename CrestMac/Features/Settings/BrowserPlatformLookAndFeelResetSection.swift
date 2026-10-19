import SwiftUI

/// The desktop's Reset All: the shared choices, plus toolbar position, Space
/// page motion, the sidebar hover area, and the Dock icon.
struct BrowserPlatformLookAndFeelResetSection: View {
    // MARK: - Variables

    @AppStorage(BrowserChromeAppearancePreference.toolbarAtTopKey, store: BrowserChromeAppearancePreference.defaults)
    private var toolbarAtTop = BrowserLookAndFeelDefaults.toolbarAtTop
    @AppStorage(SpacePageMotionPreference.key)
    private var animatesSpacePages = SpacePageMotionPreference.defaultValue
    @AppStorage(SidebarRevealWidthPreference.key, store: BrowserChromeAppearancePreference.defaults)
    private var sidebarRevealWidth = SidebarRevealWidthPreference.defaultValue

    var body: some View {
        BrowserLookAndFeelResetFooter {
            toolbarAtTop = BrowserLookAndFeelDefaults.toolbarAtTop
            animatesSpacePages = SpacePageMotionPreference.defaultValue
            sidebarRevealWidth = SidebarRevealWidthPreference.defaultValue
            _ = BrowserMacDockTile.shared.select("")
        }
    }
}
