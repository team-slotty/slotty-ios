//
//  VillaRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 관리 탭 빌라 정보
struct VillaInfo: Equatable {
    var name: String
    var address: String
    let slotCount: Int
    let householdCount: Int
    /// 기준점(도착 알림의 중심)이 있는지 - 주소를 좌표로 못 바꾸면 없다
    let hasAnchor: Bool
}

/// 빌라 정보 수정, 기준점, 관리자 위임 약속
protocol VillaRepository {
    func fetchVilla() async throws -> VillaInfo
    /// 이름/주소 수정 - 주소를 좌표로 바꾸지 못했으면 true
    func updateVilla(name: String, address: String) async throws -> Bool
    /// 주소로 기준점 다시 잡기 - 좌표로 바꾸지 못했으면 true
    func resetAnchorFromAddress() async throws -> Bool
    /// 다른 입주민에게 관리자 넘기기 - 넘기면 나는 관리자가 아니다
    func delegateAdmin(to userId: Int) async throws
}

/// 목 데이터로 동작하는 빌라 저장소
final class MockVillaRepository: VillaRepository {
    private var villa = VillaInfo(name: "슬로티빌라", address: "서울특별시 테스트구 슬로티로 1", slotCount: 7, householdCount: 6, hasAnchor: true)
    
    func fetchVilla() async throws -> VillaInfo { villa }
    
    func updateVilla(name: String, address: String) async throws -> Bool {
        villa.name = name
        villa.address = address
        return false
    }
    
    func resetAnchorFromAddress() async throws -> Bool { false }
    
    func delegateAdmin(to userId: Int) async throws {}
}

/// 서버와 통신하는 빌라 저장소
struct LiveVillaRepository: VillaRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func fetchVilla() async throws -> VillaInfo {
        let response: VillaResponse = try await client.get("/api/villas/me")
        return response.toInfo()
    }
    
    func updateVilla(name: String, address: String) async throws -> Bool {
        let response: GeocodeResultResponse = try await client.patch("/api/villas/me", body: VillaUpdateRequest(name: name, address: address))
        return response.geocodeFailed
    }
    
    func resetAnchorFromAddress() async throws -> Bool {
        let response: GeocodeResultResponse = try await client.put("/api/villas/me/anchor", body: AnchorRequest(mode: "ADDRESS"))
        return response.geocodeFailed
    }
    
    func delegateAdmin(to userId: Int) async throws {
        try await client.put("/api/villas/me/admin", body: AdminDelegateRequest(userId: userId))
    }
}
