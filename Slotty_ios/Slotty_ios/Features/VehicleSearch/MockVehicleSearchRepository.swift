//
//  MockVehicleSearchRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import Foundation

/// 목 데이터로 동작하는 차량 검색 저장소
/// 앱이 켜져 있는 동안만 남은 횟수를 기억한다
final class MockVehicleSearchRepository: VehicleSearchRepository {
    private var remainingCount = 20
    
    func search(last4: String) async throws -> VehicleSearchResults {
        guard remainingCount > 0 else {
            throw VehicleSearchError.limitExceeded
        }
        remainingCount -= 1
        let items = MockVehicleSearchData.vehicles.filter { $0.maskedPlateNumber.hasSuffix(last4) }
        return VehicleSearchResults(items: items, remainingCount: remainingCount)
    }
}
