//
//  ParkingActionErrorTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/21/26.
//

import Foundation
import Testing
@testable import Slotty

/// 현황판 동작이 실패했을 때 오류 문구
@MainActor
struct ParkingActionErrorTests {
    /// 서버 저장소는 출차 API가 아직 없어 항상 실패한다
    private let viewModel = ParkingHomeViewModel(repository: LiveParkingRepository())
    
    @Test func 출차가_실패하면_문구가_생긴다() async {
        await viewModel.exit(spotNumber: 1)
        
        #expect(viewModel.errorMessage == "출차하지 못했어요")
    }
    
    @Test func 확인을_누르면_문구가_사라진다() async {
        await viewModel.exit(spotNumber: 1)
        
        viewModel.dismissError()
        
        #expect(viewModel.errorMessage == nil)
    }
}
