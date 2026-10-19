import SwiftUI

/// Window-wide browsing controls. The sidebar keeps its Spaces, pins, and tabs.
struct BrowserRootTopToolbar: View {
    // MARK: - Static Variables

    private static let windowControlsWidth: CGFloat = 80
    private static let minimumWingWidth: CGFloat = 224
    private static let minimumAddressWidth: CGFloat = 160
    private static let maximumAddressWidth: CGFloat = 640
    private static let maximumExtensionsWidth: CGFloat = 224

    // MARK: - Variables

    let model: BrowserRootModel
    let commandSurfaceNamespace: Namespace.ID

    @Environment(\.browserChromeAppearance) private var appearance
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection

    private var selectedSpaceIsLocked: Bool {
        model.browser.shownSpace.map { model.spaceAccess.isLocked($0) } ?? true
    }

    var body: some View {
        GeometryReader { proxy in
            let sideWidth = wingWidth(in: proxy.size.width)
            HStack(spacing: CrestSpacing.small) {
                navigation
                    .environment(\.layoutDirection, layoutDirection)
                    .padding(.leading, Self.windowControlsWidth)
                    .frame(width: sideWidth, alignment: .leading)

                address
                    .environment(\.layoutDirection, layoutDirection)
                    .frame(width: addressWidth(in: proxy.size.width))

                HStack(spacing: 0) {
                    extensions
                        .environment(\.layoutDirection, layoutDirection)
                }
                .frame(width: sideWidth, alignment: .trailing)
            }
            // Native traffic lights stay physically left in every language.
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, CrestSpacing.medium)
            .frame(height: BrowserChromeLayout.sidebarTitlebarHeight)
        }
        .frame(height: BrowserChromeLayout.sidebarTitlebarHeight)
        .background { BrowserWindowTitleBarSurface() }
        .environment(\.colorScheme, model.browser.shownSpace?.settings.look.foregroundTone.colorScheme ?? .dark)
        .modifier(
            SpaceForegroundBlend(
                spaces: model.browser.availableSpaces, selectedSpaceID: model.browser.selectedSpaceID)
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Actions - Composition

    private var navigation: some View {
        HStack(spacing: CrestSpacing.extraSmall) {
            Button(
                model.sidebarPresentation.sidebarToggleAction.title,
                systemImage: appearance.sidebarOnRight ? "sidebar.right" : "sidebar.left"
            ) {
                model.toggleSidebar(reduceMotion: reduceMotion)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(
                CrestChromeButtonStyle(
                    controlSize: CGSize(
                        width: BrowserChromeLayout.sidebarNavigationControlHitTarget,
                        height: BrowserChromeLayout.sidebarNavigationControlHitTarget))
            )
            .help(model.sidebarPresentation.sidebarToggleAction.title)

            BrowserSidebarNavigationControls(
                port: BrowserSidebarNavigationPort(
                    pages: model.pages, browser: model.browser,
                    showHistory: { model.chrome.presentUtility(.history) }),
                capabilities: BrowserInteractionCapabilities(),
                reservesLeadingSpace: false
            )
            .fixedSize(horizontal: true, vertical: false)
            .disabled(selectedSpaceIsLocked)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private var address: some View {
        if let space = model.browser.shownSpace {
            SpaceSidebarAddressBand(
                space: space,
                offersSiteControls: !model.browser.isDeleting(space.id),
                selectedTabID: model.browser.selectedTabID(in: space.id),
                pages: model.pages,
                capabilities: BrowserInteractionCapabilities(),
                address: model.addressBinding,
                isAddressEditing: model.isAddressEditingBinding,
                addressFocusRequest: model.chrome.addressFocusRequest,
                activateAddress: { model.chrome.openLocation(model.address) },
                submitAddress: model.submitAddress,
                commandSurfaceNamespace: commandSurfaceNamespace,
                commandPaletteHandoff: model.commandPaletteHandoff(reduceMotion: reduceMotion, toolbarAtTop: true),
                siteControlPresentationChanged: {
                    model.chrome.utilityPresentation.setSiteControlPresented($0)
                },
                siteControlContextMenuPresentationChanged: {
                    model.chrome.utilityPresentation.setSiteControlContextMenuPresented($0)
                },
                horizontalInset: 0,
                morphsIntoUtilitySearch: false,
                showsFullAddress: true
            )
            .blur(radius: selectedSpaceIsLocked ? BrowserSidebarMetrics.lockedSpaceBlurRadius : 0)
            .redacted(reason: selectedSpaceIsLocked ? .placeholder : [])
            .allowsHitTesting(!selectedSpaceIsLocked)
            .accessibilityHidden(selectedSpaceIsLocked)
        }
    }

    @ViewBuilder
    private var extensions: some View {
        if let space = model.browser.shownSpace, !selectedSpaceIsLocked, !model.browser.isDeleting(space.id) {
            BrowserEngineSidebarAccessory(space: space, browser: model.browser, pages: model.pages, toolbarLayout: true)
                .frame(maxWidth: Self.maximumExtensionsWidth)
        }
    }

    /// Explicit wings keep the address centered even when an engine has no
    /// extension controls to contribute.
    private func wingWidth(in windowWidth: CGFloat) -> CGFloat {
        max(0, (windowWidth - addressWidth(in: windowWidth) - 2 * (CrestSpacing.medium + CrestSpacing.small)) / 2)
    }

    private func addressWidth(in windowWidth: CGFloat) -> CGFloat {
        min(
            Self.maximumAddressWidth,
            max(
                Self.minimumAddressWidth,
                windowWidth - 2 * (Self.minimumWingWidth + CrestSpacing.medium + CrestSpacing.small))
        )
    }
}
