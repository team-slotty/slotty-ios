//
//  ParkingHomeViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation
import Observation

/// 홈 (주차 현황판) 화면의 상태와 동작
@Observable
final class ParkingHomeViewModel {
    /// 현황판 데이터 - 불러오기 전에는 nil
    private(set) var board: ParkingBoard?
    /// 화면에 띄울 오류 문구 - 없으면 nil
    private(set) var errorMessage: String?
    
    private let repository: any ParkingRepository
    
    init(repository: any ParkingRepository) {
        self.repository = repository
    }
    
    /// 현황판 불러오기
    func load() async {
        do {
            board = try await repository.fetchBoard()
            errorMessage = nil
        } catch {
            errorMessage = "연결이 불안정해요"
        }
    }
}
