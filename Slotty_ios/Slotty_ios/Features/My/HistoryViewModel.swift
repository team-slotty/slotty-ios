//
//  HistoryViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Observation

/// 입출차 이력 / 미확인 기록 화면의 목록
@Observable
final class HistoryViewModel {
    private(set) var parkingHistory: [ParkingHistoryItem]?
    private(set) var unidentifiedReports: [UnidentifiedReportItem]?
    /// 화면에 띄울 오류 문구 - 관리자가 아니면 미확인 기록은 서버가 거절한다
    private(set) var errorMessage: String?
    
    private let repository: any HistoryRepository
    
    init(repository: any HistoryRepository) {
        self.repository = repository
    }
    
    func loadParkingHistory() async {
        do {
            parkingHistory = try await repository.fetchParkingHistory()
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "이력을 불러오지 못했어요"
        }
    }
    
    func loadUnidentifiedReports() async {
        do {
            unidentifiedReports = try await repository.fetchUnidentifiedReports()
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "기록을 불러오지 못했어요"
        }
    }
}
