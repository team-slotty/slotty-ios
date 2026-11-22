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
            errorMessage = "출차하지 못했어요"
        }
    }
    
    /// 입차 - 성공하면 현황판을 바뀐 상태로 교체
    func enter(vehicle: Vehicle, spotNumber: Int) async {
        do {
            board = try await repository.enter(vehicle: vehicle, spotNumber: spotNumber)
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "입차하지 못했어요"
        }
    }
    
    /// 미확인 차량 기록 - 성공하면 현황판을 바뀐 상태로 교체
    func recordUnidentified(spotNumber: Int) async {
        do {
            board = try await repository.recordUnidentified(spotNumber: spotNumber)
            errorMessage = nil
        } catch {
            errorMessage = "기록하지 못했어요"
        }
    }
    
    /// 내 차예요 - 성공하면 현황판을 바뀐 상태로 교체
       func markAsMine(spotNumber: Int, vehicle: Vehicle) async {
           do {
               board = try await repository.markAsMine(spotNumber: spotNumber, vehicle: vehicle)
               errorMessage = nil
           } catch {
               errorMessage = "바로잡지 못했어요"
           }
       }
}
