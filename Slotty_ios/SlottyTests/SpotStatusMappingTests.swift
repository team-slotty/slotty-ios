//
//  SpotStatusMappingTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation
import Testing
@testable import Slotty

/// 서버 상태 글자 → 앱 상태 변환
@MainActor
struct SpotStatusMappingTests {
    /// 테스트용 칸 하나 만들기 - 상태 글자만 바꿔 가며 쓴다
    private func slot(status: String) -> ParkingBoardResponse.Slot {
        ParkingBoardResponse.Slot(slotId: 1, assignedUnitNumber: "101", status: status, occupant: nil, unidentifiedReportId: nil)
    }
    
    @Test(arguments: [
        ("OCCUPIED", ParkingSpotStatus.occupied),
        ("VISITING", .visiting),
        ("UNIDENTIFIED", .unconfirmed),
        ("NEEDS_CHECK", .needsCheck),
        ("AVAILABLE", .available),
        ("EMPTY", .empty),
        ("VISIT_SCHEDULED", .empty),
    ])
    func 알려진_상태를_변환한다(serverStatus: String, expected: ParkingSpotStatus) {
        #expect(slot(status: serverStatus).spotStatus == expected)
    }
    
    @Test func 모르는_상태는_확인_필요로_변환한다() {
        #expect(slot(status: "SOMETHING_NEW").spotStatus == .needsCheck)
    }
}
