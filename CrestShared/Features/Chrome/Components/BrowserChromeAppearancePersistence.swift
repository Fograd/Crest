import SwiftUI

/// Supplies live appearance preferences at the scene boundary.
struct BrowserChromeAppearancePersistence: ViewModifier {
    // MARK: - Variables

    @AppStorage(BrowserChromeAppearancePreference.sidebarOnRightKey, store: BrowserChromeAppearancePreference.defaults)
    private var sidebarOnRight = false
    @AppStorage(BrowserChromeAppearancePreference.toolbarAtTopKey, store: BrowserChromeAppearancePreference.defaults)
    private var toolbarAtTop = BrowserLookAndFeelDefaults.toolbarAtTop
    @AppStorage(BrowserChromeAppearancePreference.borderWidthKey, store: BrowserChromeAppearancePreference.defaults)
    private var borderWidth = BrowserChromeAppearance.defaultBorderWidth
    /// The corner radius of the window this scene fills, which the page frame
    /// follows on Mac.
    @State private var windowCornerRadius: CGFloat?
    @State private var isWindowFullScreen = false

    // MARK: - Actions - Appearance

    func body(content: Content) -> some View {
        content
            .environment(
                \.browserChromeAppearance,
                BrowserChromeAppearance(
                    sidebarOnRight: sidebarOnRight,
                    toolbarAtTop: toolbarAtTop,
                    borderWidth: borderWidth,
                    windowCornerRadius: isWindowFullScreen ? nil : windowCornerRadius
                )
            )
            #if os(macOS)
                // The window's corners change shape with its chrome, so the
                // radius is read live rather than assumed.
                .onGeometryChange(for: CGFloat?.self) { proxy in
                    BrowserChromeAppearance.windowCornerRadius(from: proxy.containerCornerInsets)
                } action: { radius in
                    windowCornerRadius = radius
                }
                // A full-screen window keeps reporting the corners it has as a
                // window, so whether it is full screen comes from AppKit.
                .background {
                    BrowserWindowFullScreenBridge(isFullScreen: $isWindowFullScreen).accessibilityHidden(true)
                }
            #endif
    }
}
