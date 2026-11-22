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
    
    /// 현황판과 내 차량을 차례로 불러와 합친다
    func fetchBoard() async throws -> ParkingBoard {
        let board: BoardResponse = try await client.get("/api/board")
        let myVehicles: MyVehiclesResponse = try await client.get("/api/vehicles/me")
        return board.toBoard(myUnit: myVehicles.unitNumber, myVehicles: myVehicles.toVehicles())
    }
    
    func checkInOptions() async throws -> CheckInOptions {
        let response: CheckInOptionsResponse = try await client.get("/api/parking/check-in-options")
        return response.toOptions()
    }
    
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
