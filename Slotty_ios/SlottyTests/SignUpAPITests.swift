//
//  SignUpAPITests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Testing
@testable import Slotty

/// 서버 회원가입 - 성공하면 토큰 저장, 이미 쓰는 아이디면 안내
@MainActor
@Suite(.serialized)
struct SignUpAPITests {
    private let host = "signup.test"
    
    private var validForm: SignUpForm {
        var form = SignUpForm()
        form.loginId = "sujin201"
        form.password = "password12"
        form.passwordConfirm = "password12"
        form.name = " 이수진 "
        form.phone = "010-1234-5678"
        form.agreedToTerms = true
        return form
    }
    
    private func makeRepository(_ store: InMemoryTokenStore) -> LiveAuthRepository {
        let client = APIClient(baseURL: URL(string: "http://\(host)")!, session: StubURLProtocol.makeSession(), tokenStore: store)
        return LiveAuthRepository(client: client, tokenStore: store)
    }
    
    @Test func 가입하면_토큰을_저장한다() async throws {
        StubURLProtocol.handlers[host] = { _ in
            (201, #"{ "accessToken": "access-1", "refreshToken": "refresh-1" }"#)
        }
        let store = InMemoryTokenStore()
        
        try await makeRepository(store).signUp(validForm)
        
        #expect(store.tokens == AuthTokens(accessToken: "access-1", refreshToken: "refresh-1"))
    }
    
    @Test func 이미_쓰는_아이디면_안내_문구가_나온다() async {
        StubURLProtocol.handlers[host] = { _ in
            (409, #"{ "code": "LOGIN_ID_DUPLICATED", "message": "이미 사용 중인 아이디입니다.", "details": {} }"#)
        }
        let viewModel = SignUpViewModel(repository: makeRepository(InMemoryTokenStore()))
        viewModel.form = validForm
        
        #expect(await viewModel.signUp() == false)
        #expect(viewModel.errorMessage == "이미 사용 중인 아이디예요")
    }
    
    @Test func 이름은_공백을_빼고_전화번호는_숫자만_보낸다() {
        let request = SignUpRequest(form: validForm)
        
        #expect(request.name == "이수진")
        #expect(request.phone == "01012345678")
    }
}
