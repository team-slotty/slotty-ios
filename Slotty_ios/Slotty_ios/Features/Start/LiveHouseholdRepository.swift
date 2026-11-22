//
//  LiveHouseholdRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 서버와 통신하는 세대 저장소
struct LiveHouseholdRepository: HouseholdRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    /// 내 정보의 household가 null이면 소속 전
    func fetchMyUnit() async throws -> String? {
        let response: MeResponse = try await client.get("/api/me")
        return response.household?.unitNumber
    }
    
    func join(inviteCode: String) async throws -> String {
        let request = JoinHouseholdRequest(inviteCode: inviteCode)
        let response: JoinHouseholdResponse = try await client.post("/api/households/join", body: request)
        return response.household.unitNumber
    }
}
