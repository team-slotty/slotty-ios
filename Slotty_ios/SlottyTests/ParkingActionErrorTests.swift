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
    /// 모든 동작이 실패하는 테스트용 저장소
    private final class FailingParkingRepository: ParkingRepository {
        func boardChanges() -> AsyncStream<Void> { AsyncStream { $0.finish() }
        }
        func fetchBoard() async throws -> ParkingBoard { throw ParkingError.notSupported }
        func checkInOptions() async throws -> CheckInOptions { throw ParkingError.notSupported }
        func fetchSpotDetail(number: Int) async throws -> SpotDetail {
            throw ParkingError.notSupported
        }
        func enter(vehicle: Vehicle, spotNumber: Int) async throws -> ParkingBoard { throw ParkingError.notSupported }
        func exit(spotNumber: Int) async throws -> ParkingBoard { throw ParkingError.notSupported }
        func recordUnidentified(spotNumber: Int) async throws -> ParkingBoard { throw ParkingError.notSupported }
        func markLeft(spotNumber: Int) async throws -> ParkingBoard {
            throw ParkingError.notSupported
        }
        func markAsMine(spotNumber: Int, vehicle: Vehicle) async throws -> ParkingBoard { throw ParkingError.notSupported }
    }
    
    private let viewModel = ParkingHomeViewModel(repository: FailingParkingRepository())
    
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
