//
//  ParkingError.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

/// 입출차 중에 생길 수 있는 오류
enum ParkingError: Error, Equatable {
    /// 해당 번호의 주차면이 없음
    case soptNotFound
    /// 이미 차가 서 있는 면
    case spotOccupied
    /// 이 차량은 이미 다른 면에 주차 중
    case vehicleAlreadyParked
}
