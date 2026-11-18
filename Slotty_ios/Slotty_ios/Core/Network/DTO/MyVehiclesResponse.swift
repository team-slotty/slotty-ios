//
//  MyVehiclesResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// GET /api/vehicles/me 응답 - 서버 JSON 모양 그대로
struct MyVehiclesResponse: Decodable {
    /// 내 세대 호수 (예: 101)
    let unitNumber: String
    let vehicles: [MyVehicle]
    
    /// 우리 세대 차 한 대
    struct MyVehicle: Decodable {
        let vehicleId: Int
        /// 전체 차량번호 (내 차라서 가리지 않음)
        let plateNumber: String
        /// 차 상태 (PARKED/DRIVING)
        let state: String
        /// 서 있는 면 번호, 주차 중이 아니면 null
        let slotNumber: Int?
    }
}
