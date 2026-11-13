//
//  ParkingRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

/// 주차 현황을 불러오고 입출차를 기록하는 약속
protocol ParkingRepository {
    /// 현황판 불러오기
    func fetchBoard() async throws -> ParkingBoard
    /// 입차: 차량을 해당 면에 기록하고, 바뀐 현황판을 돌려준다
    func enter(vehicle: Vehicle, spotNumber: Int) async throws ->
    ParkingBoard
    /// 출차: 해당 면을 비우고, 바뀐 현황판을 돌려준다
    func exit(spotNumber: Int) async throws -> ParkingBoard
}

