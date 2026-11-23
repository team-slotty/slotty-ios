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
        let board: ParkingBoardResponse = try await client.get("/api/parking-board")
        let myVehicles: MyVehiclesResponse = try await client.get("/api/vehicles/me")
        let me: MeResponse = try await client.get("/api/me")
        return board.toBoard(
            villaName: me.villa?.name ?? "",
            myUnit: myVehicles.unitNumber,
            myVehicles: myVehicles.toVehicles()
        )
    }
    
    func fetchSpotDetail(number: Int) async throws -> SpotDetail {
        let response: SlotDetailResponse = try await client.get("/api/parking-slots/\(number)")
        return response.toDetail()
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
    
    /// 그 면에 서 있는 우리 세대 차를 출차하고, 바뀐 현황판을 다시 불러온다
    func exit(spotNumber: Int) async throws -> ParkingBoard {
        do {
            let options: CheckOutOptionsResponse = try await client.get("/api/parking/check-out-options")
            guard let vehicle = options.vehicles.first(where: { $0.slotId == spotNumber }) else {
                throw ParkingError.vehicleNotFound
            }
            let request = CheckOutRequest(vehicleId: vehicle.vehicleId, method: "MANUAL")
            let _: CheckOutResponse = try await client.post("/api/parking/check-out", body: request)
        } catch APIError.server(_, code: "NOT_PARKED", _) {
            // 이미 출차됨 - 다시 눌렀거나 재시도한 경우라 성공으로 본다 (출차에는 중복 방지 id가 없음)
        }
        return try await fetchBoard()
    }
    
    /// 미확인 차량 기록 - 차량번호는 몰라도 되어서 면만 보낸다
    func recordUnidentified(spotNumber: Int) async throws -> ParkingBoard {
        try await client.post("/api/unidentified-reports", body: UnidentifiedReportRequest(slotId: spotNumber))
        return try await fetchBoard()
    }
    
    /// [차량 떠남] - 그 면의 미확인 기록을 푼다
    func markLeft(spotNumber: Int) async throws -> ParkingBoard {
        let reportId = try await unidentifiedReportId(at: spotNumber)
        try await client.post("/api/unidentified-reports/\(reportId)/resolve", body: EmptyBody())
        return try await fetchBoard()
    }
    
    /// [내 차예요] - 미확인 면의 차를 우리 세대 차로 바로잡는다 (입차처럼 탭 한 번에 id 하나)
    func markAsMine(spotNumber: Int, vehicle: Vehicle) async throws -> ParkingBoard {
        guard let vehicleId = Int(vehicle.id) else {
            throw ParkingError.vehicleNotFound
        }
        let reportId = try await unidentifiedReportId(at: spotNumber)
        let request = MarkAsMineRequest(vehicleId: vehicleId, clientRequestId: UUID().uuidString)
        try await client.post("/api/unidentified-reports/\(reportId)/mine", body: request)
        return try await fetchBoard()
    }
    
    /// 그 면의 미확인 기록 id - 현황판을 새로 받아 찾는다 (앱 모델은 저장소마다 따로라 서버에서 다시 확인)
    private func unidentifiedReportId(at spotNumber: Int) async throws -> Int {
        let board: ParkingBoardResponse = try await client.get("/api/parking-board")
        guard let reportId = board.slots.first(where: { $0.slotId == spotNumber })?.unidentifiedReportId else {
            throw ParkingError.notUnconfirmed
        }
        return reportId
    }
}
