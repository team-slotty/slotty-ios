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
        // 서버 응답에 내 세대, 내 차량이 아직 없어서 목 데이터 값을 임시로 사용
        return response.toBoard(
            myUnit: MockParkingData.board.myUnit,
            myVehicles: MockParkingData.board.myVehicles
        )
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
}
