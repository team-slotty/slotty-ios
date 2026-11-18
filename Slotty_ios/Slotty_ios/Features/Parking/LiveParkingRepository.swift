//
//  LiveParkingRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import Foundation

/// 서버와 통신하는 주차 저장소
struct LiveParkingRepository: ParkingRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func fetchBoard() async throws -> ParkingBoard {
        let response: BoardResponse = try await client.get("/api/board")
        return response.toBoard(myUnit: Self.temporaryUnit, myVehicles: Self.temporaryVehicles)
    }
    
    // 서버 응답에 내 세대, 내 차량이 아직 없어서 로컬 시드의 사용자 1번(101호) 값을 임시로 사용
    private static let temporaryUnit = "101"
    private static let temporaryVehicles = [
        Vehicle(id: "1", plateNumber: "12가3456", nickname: nil, unit: "101"),
        Vehicle(id: "5", plateNumber: "90마2468", nickname: nil, unit: "101"),
    ]
    
    func enter(vehicle: Vehicle, spotNumber: Int) async throws -> ParkingBoard {
        // 서버에 입차 API가 아직 없음
        throw ParkingError.notSupported
    }
    
    func exit(spotNumber: Int) async throws -> ParkingBoard {
        // 서버에 출차 API가 아직 없음
        throw ParkingError.notSupported
    }
    
    func recordUnidentified(spotNumber: Int) async throws -> ParkingBoard {
        // 서버에 미확인 기록 API가 아직 없음
        throw ParkingError.notSupported
    }
    
    func markAsMine(spotNumber: Int, vehicle: Vehicle) async throws -> ParkingBoard {
        // 서버에 바로잡기 API가 아직 없음
        throw ParkingError.notSupported
    }
}
