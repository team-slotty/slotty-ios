//
//  JoinHouseholdViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation
import Observation

/// 초대 코드 참여 화면의 입력과 동작
@Observable
final class JoinHouseholdViewModel {
    var inviteCode = ""
    /// 참여하지 못한 이유 - 없으면 nil
    private(set) var errorMessage: String?
    /// 참여 요청 중인지
    private(set) var isJoining = false
    /// 참여한 세대 호수 - 참여 전이면 nil ("○○호로 가입되었어요" 안내에 쓴다)
    private(set) var joinedUnit: String?
    
    private let repository: any HouseholdRepository
    
    init(repository: any HouseholdRepository) {
        self.repository = repository
    }
    
    /// 코드를 입력했고 요청 중이 아닐 때만 [참여하기]를 누를 수 있다
    var canJoin: Bool {
        !inviteCode.trimmingCharacters(in: .whitespaces).isEmpty && !isJoining
    }
    
    /// 참여 - 실패하면 서버 문구(없는 코드, 이미 소속, 너무 많이 틀림)를 보여 준다
    func join() async {
        isJoining = true
        defer { isJoining = false }
        do {
            joinedUnit = try await repository.join(inviteCode: inviteCode)
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "초대 코드를 다시 확인해 주세요"
        }
    }
}
