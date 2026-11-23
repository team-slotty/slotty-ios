//
//  HouseholdRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 내 세대 소속 확인과 초대 코드 참여 약속
protocol HouseholdRepository {
    /// 내가 속한 세대 호수 (예: 101), 아직 소속 전이면 nil
    func fetchMyUnit() async throws -> String?
    /// 초대 코드로 세대에 참여하고, 참여한 세대 호수를 돌려준다
    func join(inviteCode: String) async throws -> String
    
    /// 빌라 만들기 - 만든 사람이 관리자가 되고 세대별 초대 코드를 돌려준다
    func createVilla(_ request: VillaCreateRequest) async throws -> VillaCreateResult
}
