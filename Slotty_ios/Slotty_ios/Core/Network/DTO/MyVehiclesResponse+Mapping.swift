//
//  MyVehiclesResponse+Mapping.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

extension MyVehiclesResponse {
    /// 앱의 차량 목록으로 변환 - 서버에 별칭이 없어서 nil
    func toVehicles() -> [Vehicle] {
        vehicles.map {
            Vehicle(id: String($0.vehicleId), plateNumber: $0.plateNumber, nickname: nil, unit: unitNumber)
        }
    }
}
