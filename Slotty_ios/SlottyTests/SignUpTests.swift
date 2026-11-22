//
//  SignUpTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Testing
@testable import Slotty

/// 회원가입 입력 검사와 가입 결과
@MainActor
struct SignUpTests {
    /// 모든 칸이 올바른 입력
    private var validForm: SignUpForm {
        var form = SignUpForm()
        form.loginId = "lee201"
        form.password = "slotty1234"
        form.passwordConfirm = "slotty1234"
        form.name = "이서연"
        form.phone = "010-1234-5678"
        form.agreedToTerms = true
        return form
    }
    
    @Test func 올바르게_채우면_문제가_없다() {
        #expect(validForm.problem == nil)
        #expect(validForm.phoneDigits == "01012345678")
    }
    
    @Test func 아이디에_한글이_있으면_막힌다() {
        var form = validForm
        form.loginId = "이서연201"
        #expect(form.problem == "아이디는 영문, 숫자 4~30자로 입력해 주세요")
    }
    
    @Test func 비밀번호_확인이_다르면_막힌다() {
        var form = validForm
        form.passwordConfirm = "slotty12345"
        #expect(form.problem == "비밀번호가 서로 달라요")
    }
    
    @Test func 필수_약관에_동의해야_한다() {
        var form = validForm
        form.agreedToTerms = false
        #expect(form.problem == "필수 약관에 동의해 주세요")
    }
    
    @Test func 이미_쓰는_아이디면_안내_문구가_나온다() async {
        let viewModel = SignUpViewModel(repository: MockAuthRepository())
        viewModel.form = validForm
        viewModel.form.loginId = "kim101"
        #expect(await viewModel.signUp() == false)
        #expect(viewModel.errorMessage == "이미 사용 중인 아이디예요")
    }
    
    @Test func 서버에_가입_기능이_없으면_안내_문구가_나온다() async {
        let viewModel = SignUpViewModel(repository: LiveAuthRepository())
        viewModel.form = validForm
        #expect(await viewModel.signUp() == false)
        #expect(viewModel.errorMessage == "아직 가입할 수 없어요")
    }
    
    @Test func 가입한_계정으로_로그인할_수_있다() async throws {
        let repository = MockAuthRepository()
        try await repository.signUp(validForm)
        try await repository.login(loginId: "lee201", password: "slotty1234")
    }
}
