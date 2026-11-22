//
//  JoinHouseholdViewModelTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Testing
@testable import Slotty

/// 초대 코드 참여 화면의 입력과 결과
@MainActor
struct JoinHouseholdViewModelTests {
    private let viewModel = JoinHouseholdViewModel(repository: MockHouseholdRepository(myUnit: nil))
    
    @Test func 코드를_입력해야_참여할_수_있다() {
        viewModel.inviteCode = "  "
        #expect(!viewModel.canJoin)
        viewModel.inviteCode = "SEED101AAAA"
        #expect(viewModel.canJoin)
    }
    
    @Test func 참여하면_세대_호수가_생긴다() async {
        viewModel.inviteCode = "SEED101AAAA"
        
        await viewModel.join()
        
        #expect(viewModel.joinedUnit == "101")
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func 틀린_코드면_안내_문구가_나온다() async {
        viewModel.inviteCode = "WRONG"
        
        await viewModel.join()
        
        #expect(viewModel.joinedUnit == nil)
        #expect(viewModel.errorMessage == "초대 코드를 다시 확인해 주세요")
    }
}
