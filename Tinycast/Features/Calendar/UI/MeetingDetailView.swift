import SwiftUI

/// The detail page for one meeting: header, location, who's coming, and the invite's own text.
struct MeetingDetailView: View {
    @Environment(\.metrics) private var metrics
    let meeting: MeetingEvent

    private var trimmedLocation: String? {
        guard let location = meeting.location?.trimmingCharacters(in: .whitespacesAndNewlines),
            !location.isEmpty
        else { return nil }
        return location
    }

    private var trimmedNotes: String? {
        guard let notes = meeting.notes?.trimmingCharacters(in: .whitespacesAndNewlines),
            !notes.isEmpty
        else { return nil }
        return notes
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: metrics.spacing.xl) {
                header
                if let trimmedLocation {
                    MeetingDetailRow(symbol: "mappin.and.ellipse", text: trimmedLocation)
                }
                if !meeting.attendees.isEmpty {
                    VStack(alignment: .leading, spacing: metrics.spacing.sm) {
                        sectionHeader("Attendees")
                        VStack(alignment: .leading, spacing: metrics.spacing.sm) {
                            ForEach(meeting.attendees) { attendee in
                                AttendeeRow(attendee: attendee)
                            }
                        }
                    }
                }
                if let trimmedNotes {
                    VStack(alignment: .leading, spacing: metrics.spacing.sm) {
                        sectionHeader("Description")
                        Text(trimmedNotes)
                            .font(metrics.typography.rowTitle)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(.horizontal, metrics.spacing.xxl)
            .padding(.top, metrics.spacing.md)
            .padding(.bottom, metrics.spacing.xxl)
            .hideNativeScrollers()
        }
        .edgeDissolve()
        .thinScrollbar()
        // A different meeting starts scrolled to the top, not wherever the last one left off.
        .id(meeting.id)
    }

    private var header: some View {
        HStack(spacing: metrics.spacing.xl) {
            SymbolImage(
                name: meeting.link?.provider.sfSymbol ?? "calendar",
                size: metrics.size.headerIconSlot
            )
            .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: metrics.spacing.xxs) {
                Text(meeting.title)
                    .font(metrics.typography.calcResult.weight(.semibold))
                    .textSelection(.enabled)
                Text(MeetingTimeFormat.range(of: meeting))
                    .font(metrics.typography.rowTrailing)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: metrics.spacing.xs) {
            Text(title)
                .font(metrics.typography.sectionHeader)
                .foregroundStyle(Theme.Colors.textTertiary)
            Rectangle()
                .fill(Theme.Colors.separator)
                .frame(height: 1)
        }
    }
}

private struct MeetingDetailRow: View {
    @Environment(\.metrics) private var metrics
    let symbol: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: metrics.spacing.sm) {
            Image(systemName: symbol)
                .foregroundStyle(Theme.Colors.textSecondary)
                .frame(width: metrics.size.rowIcon * 0.7)
            Text(text)
                .font(metrics.typography.rowTitle)
                .textSelection(.enabled)
        }
    }
}

private struct AttendeeRow: View {
    @Environment(\.metrics) private var metrics
    let attendee: MeetingEvent.Attendee

    var body: some View {
        HStack(spacing: metrics.spacing.sm) {
            Image(systemName: attendee.status.symbolName)
                .foregroundStyle(attendee.status.tint)
            Text(attendee.name)
                .font(metrics.typography.rowTitle)
                .lineLimit(1)
            if attendee.isOrganizer {
                Text("Organizer")
                    .font(metrics.typography.rowTrailing)
                    .foregroundStyle(Theme.Colors.textTertiary)
            }
            Spacer(minLength: metrics.spacing.md)
            Text(attendee.status.label)
                .font(metrics.typography.rowTrailing)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .accessibilityElement(children: .combine)
    }
}

private extension MeetingEvent.Attendee.Status {
    var symbolName: String {
        switch self {
        case .accepted: "checkmark.circle.fill"
        case .declined: "xmark.circle.fill"
        case .tentative: "questionmark.circle.fill"
        case .pending, .unknown: "circle.dashed"
        }
    }

    var tint: Color {
        switch self {
        case .accepted: Theme.Colors.success
        case .declined: Theme.Colors.destructive
        case .tentative: Theme.Colors.warning
        case .pending, .unknown: Theme.Colors.textTertiary
        }
    }

    var label: String {
        switch self {
        case .accepted: "Accepted"
        case .declined: "Declined"
        case .tentative: "Maybe"
        case .pending: "Pending"
        case .unknown: "No response"
        }
    }
}
