//
//  SignUpViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import Foundation
import Observation

/// 회원가입 화면의 입력과 동작
@Observable
final class SignUpViewModel {
    var form = SignUpForm()
    /// 서버에서 거절된 이유 - 없으면 nil
    private(set) var errorMessage: String?
    /// 가입 요청 중인지
    private(set) var isSigningUp = false
    
    private let repository: any AuthRepository
    
    init(repository: any AuthRepository) {
        self.repository = repository
    }
    
    /// 입력에 문제가 없고 요청 중이 아닐 때만 [가입하기]를 누를 수 있다
    var canSignUp: Bool {
        form.problem == nil && !isSigningUp
    }
    
    /// 가입 - 성공하면 true
    func signUp() async -> Bool {
        guard form.problem == nil else { return false }
        isSigningUp = true
        defer { isSigningUp = false }
        do {
            try await repository.signUp(form)
            errorMessage = nil
            return true
        } catch AuthError.loginIdDuplicated {
            errorMessage = "이미 사용 중인 아이디예요"
            return false
        } catch AuthError.notSupported {
            errorMessage = "아직 가입할 수 없어요"
            return false
        } catch {
            errorMessage = "가입하지 못했어요"
            return false
        }
    }
    
}
