//
//  AvailabilityRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 가용시간 목록/등록/삭제/이번만 빼기 약속
protocol AvailabilityRepository {
    func fetchAvailabilities() async throws -> [Availability]
    func register(_ request: AvailabilityRequest) async throws
    func delete(id: Int) async throws
    /// 반복 가용시간에서 그날만 뺀다 (yyyy-MM-dd)
    func skip(id: Int, date: String) async throws
}

/// 목 데이터로 동작하는 가용시간 저장소
final class MockAvailabilityRepository: AvailabilityRepository {
    private var items = [
        Availability(id: 1, spotLabel: "1번", days: ["MON", "WED", "FRI"], targetDate: nil,
                     allDay: false, startTime: "09:00", endTime: "18:00", skippedDates: []),
    ]
    
    func fetchAvailabilities() async throws -> [Availability] { items }
    
    func register(_ request: AvailabilityRequest) async throws {
        let id = (items.map(\.id).max() ?? 0) + 1
        items.append(Availability(
            id: id, spotLabel: "\(request.slotId)번", days: request.days ?? [], targetDate: request.targetDate,
            allDay: request.allDay, startTime: request.startTime, endTime: request.endTime, skippedDates: []
        ))
    }
    
    func delete(id: Int) async throws {
        items.removeAll { $0.id == id }
    }
    
    func skip(id: Int, date: String) async throws {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let item = items[index]
        items[index] = Availability(
            id: item.id, spotLabel: item.spotLabel, days: item.days, targetDate: item.targetDate,
            allDay: item.allDay, startTime: item.startTime, endTime: item.endTime, skippedDates: item.skippedDates + [date]
        )
    }
}

/// 서버와 통신하는 가용시간 저장소
struct LiveAvailabilityRepository: AvailabilityRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func fetchAvailabilities() async throws -> [Availability] {
        let response: [AvailabilityResponse] = try await client.get("/api/availabilities")
        return response.map { $0.toAvailability() }
    }
    
    func register(_ request: AvailabilityRequest) async throws {
        let _: AvailabilityResponse = try await client.post("/api/availabilities", body: request)
    }
    
    func delete(id: Int) async throws {
        try await client.delete("/api/availabilities/\(id)")
    }
    
    func skip(id: Int, date: String) async throws {
        try await client.post("/api/availabilities/\(id)/exceptions", body: AvailabilitySkipRequest(skipDate: date))
    }
}
