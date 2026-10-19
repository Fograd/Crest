import SwiftUI

/// The sidebar's address field, on every shell.
///
/// The field owns the address, the editing ring, the loading wash, and the
/// matched-geometry anchors that turn it into the command palette and the
/// utility search toolbar. What it does not own are the two controls a live
/// site contributes and the menu a compact shell hangs off the field: those
/// reach into a page layer that is the platform's own, so they arrive as slots
/// the field decides *when* to draw rather than views it knows how to build.
struct BrowserSidebarAddressField<
    LeadingAccessory: View,
    TrailingAccessory: View,
    FieldContextMenu: View
>: View {
    // MARK: - Variables

    private let configuration: BrowserSidebarAddressFieldConfiguration
    private let leadingAccessory: LeadingAccessory
    private let trailingAccessory: TrailingAccessory
    private let fieldContextMenu: FieldContextMenu

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Initializers

    init(
        configuration: BrowserSidebarAddressFieldConfiguration,
        @ViewBuilder leadingAccessory: () -> LeadingAccessory = { EmptyView() },
        @ViewBuilder trailingAccessory: () -> TrailingAccessory = {
            EmptyView()
        },
        @ViewBuilder fieldContextMenu: () -> FieldContextMenu = { EmptyView() }
    ) {
        self.configuration = configuration
        self.leadingAccessory = leadingAccessory()
        self.trailingAccessory = trailingAccessory()
        self.fieldContextMenu = fieldContextMenu()
    }

    // MARK: - Actions - Composition

    @ViewBuilder
    var body: some View {
        if hasFieldContextMenu {
            field.contextMenu {
                fieldContextMenu
                    .crestMenuActionLabelStyle()
            }
        } else {
            field
        }
    }

    private var field: some View {
        utilityMorphField
            .animation(handoffAnimation) {
                $0.opacity(configuration.commandPaletteHandoff.fieldOpacity)
            }
            .background { commandPaletteAnchor }
    }

    @ViewBuilder
    private var utilityMorphField: some View {
        if configuration.morphsIntoUtilitySearch {
            fieldContent.matchedGeometryEffect(
                id: BrowserCommandSurfaceMorph.utilitySearch(
                    spaceID: configuration.spaceID
                ),
                in: configuration.morphNamespace,
                properties: .frame,
                anchor: .center,
                isSource: true
            )
        } else {
            fieldContent
        }
    }

    private var fieldContent: some View {
        BrowserSidebarAddressFieldContent(configuration: configuration) {
            leadingAccessory
        } trailingAccessory: {
            trailingAccessory
        }
        .browserAddressFieldSurface(
            metrics: configuration.metrics,
            progress: configuration.progress,
            isLoading: configuration.isLoading,
            isEditing: configuration.isEditing.wrappedValue,
            branding: configuration.branding
        )
        .background {
            if !configuration.isEditing.wrappedValue {
                // The backing target catches the card padding without taking
                // clicks from the security and site-control buttons above it.
                Button {
                    if let activate = configuration.activate {
                        activate()
                    } else {
                        configuration.isEditing.wrappedValue = true
                    }
                } label: {
                    Color.clear
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
        }
    }

    /// The field's frame, carrying the palette's identity while the field
    /// holds it.
    ///
    /// A clear stand-in rather than the field itself: letting go of the
    /// identity inserts and removes only the stand-in, never the field and
    /// whatever it is showing or editing. Removing it in the transaction that
    /// inserts the palette is what grows the palette out of this frame.
    @ViewBuilder
    private var commandPaletteAnchor: some View {
        if configuration.commandPaletteHandoff.fieldHoldsMorph {
            Color.clear.matchedGeometryEffect(
                id: BrowserCommandSurfaceMorph.commandPalette(
                    spaceID: configuration.spaceID
                ),
                in: configuration.morphNamespace,
                properties: .frame,
                anchor: .center,
                isSource: true
            )
        }
    }

    private var handoffAnimation: Animation? {
        configuration.commandPaletteHandoff.fieldAnimation.unlessReducingMotion(reduceMotion)
    }

    /// Whether this field was given a menu at all.
    ///
    /// A blanket `.contextMenu` holding nothing is not the same as no context
    /// menu: it replaces whatever the platform's own text field would have
    /// offered — copy, paste, look up — with an empty one. A shell that has no
    /// menu to add keeps the system's.
    private var hasFieldContextMenu: Bool {
        FieldContextMenu.self != EmptyView.self
    }
}
