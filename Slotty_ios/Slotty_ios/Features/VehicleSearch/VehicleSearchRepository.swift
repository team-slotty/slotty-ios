//
//  VehicleSearchRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import Foundation

/// 차량번호로 차를 찾는 약속
protocol VehicleSearchRepository {
    /// 차량번호 뒤 4자리로 검색하고, 오늘 남은 검색 횟수도 함께 돌려준다
    func search(last4: String) async throws -> VehicleSearchResults
}
