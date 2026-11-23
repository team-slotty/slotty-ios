//
//  AdminRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 관리 탭에 보이는 세대 한 줄
struct AdminHousehold: Identifiable, Equatable {
    let id: Int
    let unitNumber: String
    let inviteCode: String
    /// 배정된 면 이름 (예: 1번)
    let spotLabels: [String]
    let vehicleCount: Int
    let members: [Member]
    
    struct Member: Identifiable, Equatable {
        let id: Int
        let name: String
        /// 빌라 관리자인지 - 관리자는 내보낼 수 없다
        let isAdmin: Bool
    }
}

/// 관리자 세대 관리 약속
protocol AdminRepository {
    /// 내가 빌라 관리자인지 - 관리 탭을 보일지 정한다
    func fetchIsAdmin() async throws -> Bool
    func fetchHouseholds() async throws -> [AdminHousehold]
    func addHousehold(unitNumber: String) async throws
    /// 세대원이나 차량이 남아 있으면 서버가 거절한다 (HOUSEHOLD_NOT_EMPTY)
    func deleteHousehold(id: Int) async throws
    func reissueInviteCode(householdId: Int) async throws
    func removeMember(householdId: Int, memberId: Int) async throws
}

/// 목 데이터로 동작하는 관리 저장소
final class MockAdminRepository: AdminRepository {
    private var households = [
        AdminHousehold(id: 1, unitNumber: "101", inviteCode: "SEED101AAAA", spotLabels: ["1번"], vehicleCount: 2,
                       members: [.init(id: 1, name: "김민준", isAdmin: true)]),
        AdminHousehold(id: 2, unitNumber: "102", inviteCode: "SEED102BBBB", spotLabels: ["2번"], vehicleCount: 0, members: []),
    ]
    
    func fetchIsAdmin() async throws -> Bool { true }
    
    func fetchHouseholds() async throws -> [AdminHousehold] { households }
    
    func addHousehold(unitNumber: String) async throws {
        let id = (households.map(\.id).max() ?? 0) + 1
        households.append(AdminHousehold(id: id, unitNumber: unitNumber, inviteCode: "NEW\(id)CODE", spotLabels: [], vehicleCount: 0, members: []))
    }
    
    func deleteHousehold(id: Int) async throws {
        households.removeAll { $0.id == id }
    }
    
    func reissueInviteCode(householdId: Int) async throws {}
    
    func removeMember(householdId: Int, memberId: Int) async throws {}
}

/// 서버와 통신하는 관리 저장소
struct LiveAdminRepository: AdminRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func fetchIsAdmin() async throws -> Bool {
        let me: MeResponse = try await client.get("/api/me")
        return me.isAdmin ?? false
    }
    
    func fetchHouseholds() async throws -> [AdminHousehold] {
        let response: [HouseholdSummaryResponse] = try await client.get("/api/households")
        return response.map { $0.toHousehold() }
    }
    
    func addHousehold(unitNumber: String) async throws {
        try await client.post("/api/households", body: HouseholdCreateRequest(unitNumber: unitNumber))
    }
    
    func deleteHousehold(id: Int) async throws {
        try await client.delete("/api/households/\(id)")
    }
    
    /// 재발급하면 이전 코드는 쓸 수 없다
    func reissueInviteCode(householdId: Int) async throws {
        try await client.post("/api/households/\(householdId)/invite-code/reissue", body: EmptyBody())
    }
    
    func removeMember(householdId: Int, memberId: Int) async throws {
        try await client.delete("/api/households/\(householdId)/members/\(memberId)")
    }
}
