//
//  VehicleSearchViewModelTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/17/26.
//

import Testing
@testable import Slotty

@MainActor
struct VehicleSearchViewModelTests {
    @Test func 숫자만_4자리까지_입력된다() {
        let viewModel = VehicleSearchViewModel(repository: MockVehicleSearchRepository())
        viewModel.query = "12가34567"
        #expect(viewModel.query == "1234")
    }
    
    @Test func 뒤_4자리로_검색하면_결과와_남은_횟수가_바뀐다() async {
        let viewModel = VehicleSearchViewModel(repository: MockVehicleSearchRepository())
        viewModel.query = "3456"
        await viewModel.search()
        #expect(viewModel.results?.count == 2)
        #expect(viewModel.remainingCount == 19)
    }
}
