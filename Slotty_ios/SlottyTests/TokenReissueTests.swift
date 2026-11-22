//
//  TokenReissueTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation
import Testing
@testable import Slotty

/// access 토큰이 만료됐을 때 재발급하고 다시 보내기
@MainActor
@Suite(.serialized)
struct TokenReissueTests {
    /// 테스트용 응답 본문
    private struct Ping: Decodable {
        let ok: Bool
    }

    private let unauthorized = #"{ "code": "UNAUTHORIZED", "message": "로그인이 필요합니다.", "details": {} }"#

    private func makeClient(_ store: InMemoryTokenStore) -> APIClient {
        APIClient(baseURL: URL(string: "http://test")!, session: StubURLProtocol.makeSession(), tokenStore: store)
    }

    @Test func 만료되면_재발급받아_다시_보낸다() async throws {
        let store = InMemoryTokenStore(tokens: AuthTokens(accessToken: "old", refreshToken: "refresh-old"))
        let unauthorized = unauthorized
        StubURLProtocol.handler = { request in
            switch (request.url?.path, request.value(forHTTPHeaderField: "Authorization")) {
            case ("/api/auth/reissue", _):
                return (200, #"{ "accessToken": "new", "refreshToken": "refresh-new" }"#)
            case ("/ping", "Bearer new"):
                return (200, #"{ "ok": true }"#)
            default:
                return (401, unauthorized)
            }
        }

        let ping: Ping = try await makeClient(store).get("/ping")

        #expect(ping.ok)
        #expect(store.tokens == AuthTokens(accessToken: "new", refreshToken: "refresh-new"))
    }

    @Test func 재발급도_실패하면_토큰을_지운다() async {
        let store = InMemoryTokenStore(tokens: AuthTokens(accessToken: "old", refreshToken: "refresh-old"))
        let unauthorized = unauthorized
        StubURLProtocol.handler = { request in
            if request.url?.path == "/api/auth/reissue" {
                return (401, #"{ "code": "INVALID_REFRESH_TOKEN", "message": "로그인이 만료되었습니다.", "details": {} }"#)
            }
            return (401, unauthorized)
        }

        await #expect(throws: APIError.server(statusCode: 401, code: "UNAUTHORIZED", message: "로그인이 필요합니다.")) {
            let _: Ping = try await makeClient(store).get("/ping")
        }
        #expect(store.tokens == nil)
    }
}
