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
    
    /// 오류 문구를 지운다 - 알림창에서 [확인]을 눌렀을 때
    func dismissError() {
        errorMessage = nil
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
    
    /// 출차 - 성공하면 현황판을 바뀐 상태로 교체
    func exit(spotNumber: Int) async {
        do {
            board = try await repository.exit(spotNumber: spotNumber)
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "출차하지 못했어요"
        }
    }
    
    /// 입차할 때 고를 수 있는 면 - 못 불러오면 nil (입차 화면에서 안내)
    func checkInOptions() async -> CheckInOptions? {
        try? await repository.checkInOptions()
    }
    
    /// 입차 - 성공하면 현황판을 바뀐 상태로 교체
    func enter(vehicle: Vehicle, spotNumber: Int) async {
        do {
            board = try await repository.enter(vehicle: vehicle, spotNumber: spotNumber)
            errorMessage = nil
        } catch {
            // 그 사이 다른 차가 들어온 면이면 현황판을 새로 받아 보여 준다
            if case .server(_, code: "SLOT_OCCUPIED", _)? = error as? APIError {
                await load()
            }
            errorMessage = (error as? APIError)?.serverMessage ?? "입차하지 못했어요"
        }
    }
    
    /// 미확인 차량 기록 - 성공하면 현황판을 바뀐 상태로 교체
    func recordUnidentified(spotNumber: Int) async {
        do {
            board = try await repository.recordUnidentified(spotNumber: spotNumber)
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "기록하지 못했어요"
        }
    }
    
    /// 차량 떠남 - 미확인 기록을 풀고 현황판을 바뀐 상태로 교체
    func markLeft(spotNumber: Int) async {
        do {
            board = try await repository.markLeft(spotNumber: spotNumber)
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "처리하지 못했어요"
        }
    }
    
    /// 내 차예요 - 성공하면 현황판을 바뀐 상태로 교체
    func markAsMine(spotNumber: Int, vehicle: Vehicle) async {
        do {
            board = try await repository.markAsMine(spotNumber: spotNumber, vehicle: vehicle)
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "바로잡지 못했어요"
        }
    }
}
