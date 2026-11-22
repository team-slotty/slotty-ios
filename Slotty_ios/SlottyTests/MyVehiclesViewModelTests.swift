//
//  MyVehiclesViewModelTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Testing
@testable import Slotty

/// 내 차량 관리 목록과 삭제
@MainActor
struct MyVehiclesViewModelTests {
    private let viewModel = MyVehiclesViewModel(repository: MockVehicleRepository())
    
    @Test func 목록을_불러온다() async {
        await viewModel.load()
        
        #expect(viewModel.vehicles?.map(\.plateNumber) == ["12가3456", "90마2468"])
    }
    
    @Test func 삭제하면_목록에서_빠진다() async throws {
        await viewModel.load()
        let vehicle = try #require(viewModel.vehicles?.first)
        
        #expect(await viewModel.delete(vehicle))
        #expect(viewModel.vehicles?.contains(vehicle) == false)
    }
}
