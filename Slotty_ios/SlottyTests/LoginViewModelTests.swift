//
//  LoginViewModelTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Testing
@testable import Slotty

/// 로그인 입력과 결과
@MainActor
struct LoginViewModelTests {
    @Test func 두_칸을_다_채워야_로그인할_수_있다() {
        let viewModel = LoginViewModel(repository: MockAuthRepository())
        viewModel.loginId = "kim101"
        #expect(!viewModel.canLogin)
        viewModel.password = "slotty1234"
        #expect(viewModel.canLogin)
    }
    
    @Test func 맞는_계정이면_로그인된다() async {
        let viewModel = LoginViewModel(repository: MockAuthRepository())
        viewModel.loginId = "kim101"
        viewModel.password = "slotty1234"
        #expect(await viewModel.login())
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func 비밀번호가_틀리면_안내_문구가_나온다() async {
        let viewModel = LoginViewModel(repository: MockAuthRepository())
        viewModel.loginId = "kim101"
        viewModel.password = "wrong"
        #expect(await viewModel.login() == false)
        #expect(viewModel.errorMessage == "아이디 또는 비밀번호가 맞지 않아요")
    }
}
