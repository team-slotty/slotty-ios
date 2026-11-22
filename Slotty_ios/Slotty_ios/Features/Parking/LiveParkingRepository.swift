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
    
    /// 입차 기록 후 바뀐 현황판을 다시 불러온다
    func enter(vehicle: Vehicle, spotNumber: Int) async throws -> ParkingBoard {
        guard let vehicleId = Int(vehicle.id) else {
            throw ParkingError.vehicleNotFound
        }
        // 탭 한 번에 id 하나 - 토큰 재발급으로 다시 보낼 때도 같은 요청이라 중복 입차가 안 된다
        let request = CheckInRequest(
            vehicleId: vehicleId,
            slotId: spotNumber,
            method: "MANUAL",
            clientRequestId: UUID().uuidString
        )
        let _: CheckInResponse = try await client.post("/api/parking/check-in", body: request)
        return try await fetchBoard()
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
