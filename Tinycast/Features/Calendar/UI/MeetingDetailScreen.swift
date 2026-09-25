import SwiftUI

/// One meeting's read-only page, opened from its own action menu. Escape returns to the row it
/// was opened from.
struct MeetingDetailScreen: PaletteScreen {
    let store: CalendarStore
    let core: AppCore
    let vm: PaletteState

    private var meeting: MeetingEvent? {
        core.calendarCoordinator.detailMeetingID.flatMap(store.event(id:))
    }

    /// The one meeting, so the footer and ⌘K act on it exactly as on a selected row.
    var rows: [MeetingEvent] { meeting.map { [$0] } ?? [] }

    /// Left visible and focused: nothing else on this screen would claim the keyboard if it
    /// stepped aside, and `Escape`, `Return` and every chord route through that focus.
    var hidesSearchField: Bool { false }

    /// A meeting with no link has nowhere to join, so the pill offers what it can instead.
    var primaryActionTitle: String {
        meeting?.link == nil ? "Open in Calendar" : "Join Meeting"
    }

    func actions(at selection: Int) -> PopoverMenuContent? {
        guard let meeting else { return nil }
        return MeetingActionsMenu.content(meeting: meeting, core: core)
    }

    func activate(at selection: Int) {
        guard let meeting else { return }
        core.calendarCoordinator.activateMeeting(id: meeting.id)
    }

    /// ⌘↵ — copy the link, matching the schedule row it was opened from.
    func secondary(at selection: Int) -> Bool {
        guard let meeting, meeting.link != nil else { return false }
        core.calendarCoordinator.copyLink(meeting)
        return true
    }

    func body(selection: Int, scroll: ScrollIntent) -> AnyView {
        guard let meeting else {
            return AnyView(EmptyResults(text: "This meeting is no longer available"))
        }
        return AnyView(MeetingDetailView(meeting: meeting))
    }
}
