import OSLog
import SwiftUI

extension EnvironmentValues {
    @Entry var schedules: any ScheduleRepository = DisabledScheduleRepository()
}

extension View {
    func loadSchedules<Request: Hashable & Sendable, Value: Sendable>(
        _ request: Request?,
        into value: Binding<Value>,
        using load: @escaping @Sendable (any ScheduleRepository, Request) async throws -> Value
    ) -> some View {
        modifier(ScheduleLoader(request: request, value: value, load: load))
    }
}

private struct ScheduleLoader<Request: Hashable & Sendable, Value: Sendable>: ViewModifier {
    let request: Request?
    @Binding var value: Value
    let load: @Sendable (any ScheduleRepository, Request) async throws -> Value

    @Environment(\.schedules) private var schedules

    func body(content: Content) -> some View {
        content.task(id: request) {
            guard let request else { return }
            do {
                let loaded = try await load(schedules, request)
                guard !Task.isCancelled else { return }
                value = loaded
            } catch {
                guard !Task.isCancelled else { return }
                Logger.schedules.error("Schedule load failed: \(String(describing: error), privacy: .public)")
            }
        }
    }
}
