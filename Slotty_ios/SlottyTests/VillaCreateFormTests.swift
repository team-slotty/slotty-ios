//
//  VillaCreateFormTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Testing
@testable import Slotty

/// 빌라 만들기 입력 검사와 요청
@MainActor
struct VillaCreateFormTests {
    private var validForm: VillaCreateForm {
        var form = VillaCreateForm()
        form.name = "슬로티빌라"
        form.address = "서울시 금천구 가산디지털1로 189"
        form.unitsText = "101, 102 201"
        form.myUnitNumber = "101"
        return form
    }
    
    @Test func 호수는_쉼표와_띄어쓰기로_나눈다() {
        #expect(validForm.unitNumbers == ["101", "102", "201"])
        #expect(validForm.problem == nil)
    }
    
    @Test func 같은_호수가_있으면_막힌다() {
        var form = validForm
        form.unitsText = "101, 101"
        #expect(form.problem == "같은 호수가 두 번 있어요")
    }
    
    @Test func 내_호수는_세대_호수_중_하나여야_한다() {
        var form = validForm
        form.myUnitNumber = "999"
        #expect(form.problem == "내 호수를 골라 주세요")
    }
    
    @Test func 빌라를_만들면_세대별_초대_코드를_받는다() async throws {
        let repository = MockHouseholdRepository(myUnit: nil)
        
        let result = try await repository.createVilla(validForm.request)
        
        #expect(result.inviteCodes.map(\.unitNumber) == ["101", "102", "201"])
        #expect(try await repository.fetchMyUnit() == "101")
    }
}
