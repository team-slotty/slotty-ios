//
//  MockHouseholdRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 목 데이터로 동작하는 세대 저장소 - 처음부터 101호 소속
final class MockHouseholdRepository: HouseholdRepository {
    private var myUnit: String?
    /// 초대 코드 -> 세대 호수 (서버 시드와 같은 코드)
    private let inviteCodes = ["SEED101AAAA": "101", "SEED201CCCC": "201", "SEED302FFFF": "302"]
    
    init(myUnit: String? = "101") {
        self.myUnit = myUnit
    }
    
    func fetchMyUnit() async throws -> String? {
        myUnit
    }
    
    /// 서버처럼 소문자와 앞뒤 공백은 괜찮다
    func join(inviteCode: String) async throws -> String {
        let code = inviteCode.trimmingCharacters(in: .whitespaces).uppercased()
        guard let unit = inviteCodes[code] else {
            throw HouseholdError.inviteCodeInvalid
        }
        myUnit = unit
        return unit
    }
    
    /// 시연 빌라(LG 가산 디지털센터)와 같은 기준점
    func fetchVillaAnchor() async throws -> (latitude: Double, longitude: Double)? {
        (37.4822875, 126.8792969)
    }
    
    func createVilla(_ request: VillaCreateRequest) async throws -> VillaCreateResult {
        myUnit = request.myUnitNumber
        let codes = request.households.map { VillaCreateResult.InviteCode(unitNumber: $0.unitNumber, code: "NEW\($0.unitNumber)CODE") }
        return VillaCreateResult(geocodeFailed: false, inviteCodes: codes)
    }
}

/// 세대 참여 중에 생길 수 있는 오류
enum HouseholdError: Error, Equatable {
    /// 없는 초대 코드
    case inviteCodeInvalid
}
