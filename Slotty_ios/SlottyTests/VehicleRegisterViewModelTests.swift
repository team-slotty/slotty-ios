//
//  VehicleRegisterViewModelTests.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Testing
@testable import Slotty

/// 차량 등록 화면의 입력 검사와 결과
@MainActor
struct VehicleRegisterViewModelTests {
    private let viewModel = VehicleRegisterViewModel(repository: MockVehicleRepository())
    
    @Test(arguments: ["12가3456", "123가4567", "서울12가3456", "12가 3456"])
    func 서버와_같은_형식이면_등록할_수_있다(plateNumber: String) {
        viewModel.plateNumber = plateNumber
        
        #expect(viewModel.canRegister)
    }
    
    @Test(arguments: ["1234", "12가345", "가3456", "ab12가3456"])
    func 형식이_다르면_등록할_수_없다(plateNumber: String) {
        viewModel.plateNumber = plateNumber
        
        #expect(!viewModel.canRegister)
    }
    
    @Test func 공백을_빼고_등록한다() async {
        viewModel.plateNumber = "56바 7890"
        
        #expect(await viewModel.register())
        #expect(viewModel.normalizedPlateNumber == "56바7890")
    }
    
    @Test func 이미_있는_번호면_안내_문구가_나온다() async {
        viewModel.plateNumber = "12가3456"
        
        #expect(await viewModel.register() == false)
        #expect(viewModel.errorMessage == "이미 등록된 차량번호예요")
    }
}
