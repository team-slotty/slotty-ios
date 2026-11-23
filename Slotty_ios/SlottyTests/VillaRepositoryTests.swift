//
//  VillaRepositoryTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 빌라 정보와 관리자 위임 요청
@MainActor
@Suite(.serialized)
struct VillaRepositoryTests {
    @Test func 기준점이_없으면_없다고_본다() throws {
        let json = #"{ "id": 1, "name": "슬로티빌라", "address": "주소", "layoutTemplate": "DOUBLE", "entranceSide": "BOTTOM", "slotCount": 7, "householdCount": 6, "anchor": null }"#
        
        let villa = try JSONDecoder().decode(VillaResponse.self, from: Data(json.utf8)).toInfo()
        
        #expect(villa.slotCount == 7)
        #expect(!villa.hasAnchor)
    }
    
    @Test func 관리자_위임은_PUT으로_보낸다() async throws {
        let host = "villa.test"
        let methods = Recorder()
        StubURLProtocol.handlers[host] = { request in
            methods.append("\(request.httpMethod ?? "") \(request.url?.path ?? "")")
            return (204, "")
        }
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: InMemoryTokenStore())
        
        try await LiveVillaRepository(client: client).delegateAdmin(to: 2)
        
        #expect(methods.values == ["PUT /api/villas/me/admin"])
    }
}
