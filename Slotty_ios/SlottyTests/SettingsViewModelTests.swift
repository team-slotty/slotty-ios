//
//  SettingsViewModelTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 설정 - 연락처 공개와 탈퇴
@MainActor
@Suite(.serialized)
struct SettingsViewModelTests {
    @Test func 연락처_공개를_바꾼다() async {
        let viewModel = SettingsViewModel(repository: MockAccountRepository())
        await viewModel.load()

        await viewModel.setPhonePublic(false)

        #expect(viewModel.phonePublic == false)
    }

    @Test func 관리자는_탈퇴가_거절되고_서버_문구가_나온다() async {
        let host = "account.test"
        StubURLProtocol.handlers[host] = { _ in
            (409, #"{ "code": "ADMIN_MUST_DELEGATE", "message": "관리자는 다른 입주민에게 관리자를 위임한 뒤 탈퇴할 수 있습니다.", "details": {} }"#)
        }
        let store = InMemoryTokenStore(tokens: AuthTokens(accessToken: "access-1", refreshToken: "refresh-1"))
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: store)
        let viewModel = SettingsViewModel(repository: LiveAccountRepository(client: client, tokenStore: store))

        #expect(await viewModel.withdraw() == false)
        #expect(viewModel.errorMessage == "관리자는 다른 입주민에게 관리자를 위임한 뒤 탈퇴할 수 있습니다.")
        // 거절되면 이 기기의 로그인은 그대로
        #expect(store.tokens != nil)
    }
}
