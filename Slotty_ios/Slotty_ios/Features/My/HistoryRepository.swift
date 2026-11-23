//
//  HistoryRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 입출차 이력과 미확인 기록 목록 약속
protocol HistoryRepository {
    /// 입출차 이력 - 최근 순
    func fetchParkingHistory() async throws -> [ParkingHistoryItem]
    /// 미확인 기록 목록 - 관리자만 볼 수 있다
    func fetchUnidentifiedReports() async throws -> [UnidentifiedReportItem]
}

/// 목 데이터로 동작하는 이력 저장소
struct MockHistoryRepository: HistoryRepository {
    func fetchParkingHistory() async throws -> [ParkingHistoryItem] {
        let now = Date()
        return [
            ParkingHistoryItem(
                id: 2, plateNumber: "90마2468", spotLabel: "6번", enteredAt: now - 7200, enteredBy: "김민준",
                enterMethod: "MANUAL", exitedAt: now - 3600, exitedBy: "김민준", exitMethod: "MANUAL"
            ),
            ParkingHistoryItem(
                id: 1, plateNumber: "12가3456", spotLabel: "1번", enteredAt: now - 86400, enteredBy: "김민준",
                enterMethod: "NOTIFICATION", exitedAt: nil, exitedBy: nil, exitMethod: nil
            ),
        ]
    }
    
    func fetchUnidentifiedReports() async throws -> [UnidentifiedReportItem] {
        [
            UnidentifiedReportItem(
                id: 1, spotLabel: "1번", plateNumber: nil, reportedBy: "김민준",
                reportedAt: Date() - 3600, resolvedAt: Date() - 1800, resolveType: "LEFT"
            ),
        ]
    }
}

/// 서버와 통신하는 이력 저장소
struct LiveHistoryRepository: HistoryRepository {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func fetchParkingHistory() async throws -> [ParkingHistoryItem] {
        let response: ParkingHistoryResponse = try await client.get("/api/parking/history")
        return response.toItems()
    }
    
    func fetchUnidentifiedReports() async throws -> [UnidentifiedReportItem] {
        let response: UnidentifiedReportsResponse = try await client.get("/api/unidentified-reports")
        return response.toItems()
    }
}
