//
//  VillaCreateForm.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 빌라 만들기 입력값과 입력 검사
struct VillaCreateForm: Equatable {
    var name = ""
    var address = ""
    /// LINE / DOUBLE / L_SHAPE
    var layoutTemplate = "DOUBLE"
    /// TOP / BOTTOM / LEFT / RIGHT
    var entranceSide = "BOTTOM"
    var slotCount = 4
    /// 세대 호수 - 쉼표나 띄어쓰기로 구분 (예: 101, 102, 201)
    var unitsText = ""
    /// 내 호수 - 세대 호수 중 하나
    var myUnitNumber = ""
    
    /// 입력한 세대 호수 목록 - 빈 칸은 뺀다
    var unitNumbers: [String] {
        unitsText
            .split(whereSeparator: { $0 == "," || $0.isWhitespace })
            .map(String.init)
    }
    
    /// 만들 수 없는 이유, 문제 없으면 nil - 위에서부터 걸리는 것 하나만
    var problem: String? {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            return "빌라 이름을 입력해 주세요"
        }
        if address.trimmingCharacters(in: .whitespaces).isEmpty {
            return "주소를 입력해 주세요"
        }
        if unitNumbers.isEmpty {
            return "세대 호수를 입력해 주세요"
        }
        if Set(unitNumbers).count != unitNumbers.count {
            return "같은 호수가 두 번 있어요"
        }
        if !unitNumbers.contains(myUnitNumber) {
            return "내 호수를 골라 주세요"
        }
        return nil
    }
    
    /// 서버 요청으로 - 면 배정은 만든 뒤 관리 탭에서
    var request: VillaCreateRequest {
        VillaCreateRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            address: address.trimmingCharacters(in: .whitespaces),
            layoutTemplate: layoutTemplate,
            entranceSide: entranceSide,
            slotCount: slotCount,
            households: unitNumbers.map { .init(unitNumber: $0) },
            myUnitNumber: myUnitNumber
        )
    }
}

/// 빌라를 만든 결과 - 세대별 초대 코드를 공유한다
struct VillaCreateResult: Equatable {
    /// 주소를 좌표로 바꾸지 못했는지 - 도착 알림 기준점이 없다
    let geocodeFailed: Bool
    /// (호수, 초대 코드)
    let inviteCodes: [InviteCode]
    
    struct InviteCode: Equatable, Identifiable {
        let unitNumber: String
        let code: String
        var id: String { unitNumber }
    }
}
