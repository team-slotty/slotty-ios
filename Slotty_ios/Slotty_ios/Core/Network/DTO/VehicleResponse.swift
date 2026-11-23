//
//  VehicleResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import Foundation

/// 차량 등록 요청 - POST /api/vehicles (담당자를 생략하면 본인)
struct VehicleCreateRequest: Encodable {
    let plateNumber: String
}

/// 차량 응답 - 등록/목록 공통
struct VehicleResponse: Decodable {
    let vehicleId: Int
    let plateNumber: String
    /// 연락 담당자, 지정 전이면 null
    let contactUser: ContactUser?
    
    struct ContactUser: Decodable {
        let userId: Int
        let name: String
    }
}

extension VehicleResponse {
    /// 앱 모델로 변환
    func toRegisteredVehicle() -> RegisteredVehicle {
        RegisteredVehicle(id: vehicleId, plateNumber: plateNumber, contactName: contactUser?.name, contactUserId: contactUser?.userId)
    }
}

/// 차량 수정 요청 - PATCH /api/vehicles/{id} (보낸 필드만 바뀐다)
struct VehicleUpdateRequest: Encodable {
    let contactUserId: Int
}

/// 내 세대 응답 - GET /api/households/me (세대원 이름만 쓴다)
struct MyHouseholdResponse: Decodable {
    let members: [Member]
    
    struct Member: Decodable {
        let userId: Int
        let name: String
    }
}
