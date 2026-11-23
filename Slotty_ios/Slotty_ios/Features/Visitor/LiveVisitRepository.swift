//
//  LiveVisitRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 서버와 통신하는 방문 저장소
struct LiveVisitRepository: VisitRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    /// 서버는 예정/방문 중/지난 방문을 나눠서 주므로 세 번 불러와 합친다
    func fetchVisits() async throws -> [Visit] {
        var visits: [Visit] = []
        for scope in ["UPCOMING", "ONGOING", "PAST"] {
            let page: VisitPageResponse = try await client.get(
                "/api/visits",
                query: [URLQueryItem(name: "scope", value: scope)]
            )
            visits += page.items.map { $0.toVisit() }
        }
        return visits
    }
    
    func register(plateNumber: String, startAt: Date, endAt: Date, spotNumber: Int?) async throws -> Visit {
        let request = VisitCreateRequest(plateNumber: plateNumber, startAt: startAt, endAt: endAt, slotId: spotNumber)
        let response: VisitResponse = try await client.post("/api/visits", body: request)
        return response.toVisit()
    }
    
    func end(visitID: String) async throws -> Visit {
        let response: VisitResponse = try await client.post("/api/visits/\(visitID)/end", body: EmptyBody())
        return response.toVisit()
    }
    
    func delete(visitID: String) async throws {
        try await client.delete("/api/visits/\(visitID)")
    }
}
