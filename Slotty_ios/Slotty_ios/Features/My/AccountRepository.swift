//
//  AccountRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 내 계정 설정(연락처 공개, 탈퇴) 약속
protocol AccountRepository {
    /// 차량번호 검색 시 이웃에게 연락처를 공개하는지
    func fetchPhonePublic() async throws -> Bool
    /// 연락처 공개 바꾸기
    func updatePhonePublic(_ isPublic: Bool) async throws
    /// 탈퇴 - 성공하면 이 기기의 토큰도 지운다
    func withdraw() async throws
}

/// 목 데이터로 동작하는 계정 저장소
final class MockAccountRepository: AccountRepository {
    private var phonePublic = true
    
    func fetchPhonePublic() async throws -> Bool {
        phonePublic
    }
    
    func updatePhonePublic(_ isPublic: Bool) async throws {
        phonePublic = isPublic
    }
    
    func withdraw() async throws {}
}

/// 서버와 통신하는 계정 저장소
struct LiveAccountRepository: AccountRepository {
    private let client: APIClient
    private let tokenStore: any TokenStore
    
    init(client: APIClient = APIClient(), tokenStore: any TokenStore = KeychainTokenStore()) {
        self.client = client
        self.tokenStore = tokenStore
    }
    
    func fetchPhonePublic() async throws -> Bool {
        let me: MeResponse = try await client.get("/api/me")
        return me.phonePublic ?? false
    }
    
    /// 보낸 필드만 바뀌어서 phonePublic만 보낸다
    func updatePhonePublic(_ isPublic: Bool) async throws {
        let _: MeResponse = try await client.patch("/api/me", body: MeUpdateRequest(phonePublic: isPublic))
    }
    
    /// 관리자는 먼저 관리자를 넘겨야 해서 서버가 거절할 수 있다 (ADMIN_MUST_DELEGATE)
    func withdraw() async throws {
        try await client.delete("/api/me")
        tokenStore.clear()
    }
}
