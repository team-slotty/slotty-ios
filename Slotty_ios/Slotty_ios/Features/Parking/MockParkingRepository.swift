//
//  MockParkingRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

/// 목 데이터로 동작하는 주차 Repository
/// 앱이 켜져 있는 동안만 입출차 상태를 기억하고, 다시 켜면 처음 상태로 돌아간다

final class MockParkingRepository: ParkingRepository {
    private var board = MockParkingData.board
    
    func fetchBoard() async throws -> ParkingBoard {
        board
    }
    
    /// 목 데이터에는 가용시간과 방문 지정이 없다
    func fetchSpotDetail(number: Int) async throws -> SpotDetail {
        SpotDetail(availableTime: nil, visit: nil)
    }
    
    /// 서버와 같은 규칙 - 빈 내 배정 면 -> 빈 공용 면, 찬 면과 남의 배정 면은 제외
    func checkInOptions() async throws -> CheckInOptions {
        let mySpots = board.spots.filter { $0.isAssigned(to: board.myUnit) }
        let myEmptySpots = mySpots.filter { !$0.status.isOccupied }
        let sharedEmptySpots = board.spots.filter { $0.isShared && !$0.status.isOccupied }
        return CheckInOptions(
            spotNumbers: (myEmptySpots + sharedEmptySpots).map(\.number),
            suggestedSpotNumber: myEmptySpots.first?.number,
            assignedAllOccupied: !mySpots.isEmpty && myEmptySpots.isEmpty
        )
    }
    
    func enter(vehicle: Vehicle, spotNumber: Int) async throws ->
    ParkingBoard {
        guard let index = board.spots.firstIndex(where: { $0.number == spotNumber }) else {
            throw ParkingError.spotNotFound
        }
        guard !board.spots[index].status.isOccupied else {
            throw ParkingError.spotOccupied
        }
        guard board.spot(parkedBy: vehicle) == nil else {
            throw ParkingError.vehicleAlreadyParked
        }
        board.spots[index].status = .occupied
        board.spots[index].currentParking = ParkingRecord(
            plateNumber: vehicle.plateNumber,
            enteredAt: Date(),
            method: .manual
        )
        return board
    }
    
    func exit(spotNumber: Int) async throws -> ParkingBoard {
        guard let index = board.spots.firstIndex(where: { $0.number == spotNumber }) else {
            throw ParkingError.spotNotFound
        }
        
        board.spots[index].status = .empty
        board.spots[index].currentParking = nil
        return board
    }
    
    func recordUnidentified(spotNumber: Int) async throws ->
    ParkingBoard {
        guard let index = board.spots.firstIndex(where: { $0.number == spotNumber }) else {
            throw ParkingError.spotNotFound
        }
        guard board.spots[index].status.canRecordUnconfirmed else {
            throw ParkingError.spotOccupied
        }
        board.spots[index].status = .unconfirmed
        board.spots[index].currentParking = ParkingRecord(
            plateNumber: nil,
            enteredAt: Date(),
            method: .manual
        )
        return board
    }
    
    /// 목 저장소는 출차처럼 면을 비운다
    func markLeft(spotNumber: Int) async throws -> ParkingBoard {
        try await exit(spotNumber: spotNumber)
    }
    
    func markAsMine(spotNumber: Int, vehicle: Vehicle) async throws -> ParkingBoard {
        guard let index = board.spots.firstIndex(where: { $0.number == spotNumber }) else {
            throw ParkingError.spotNotFound
        }
        guard board.spots[index].status == .unconfirmed else {
            throw ParkingError.notUnconfirmed
        }
        // 운행 중인 차가 없어 주차 중인 차를 고른 경우: 이전 면의 열린 기록을 자동 정리
        if let previousIndex = board.spots.firstIndex(where: { $0.currentParking?.plateNumber == vehicle.plateNumber }) {
            board.spots[previousIndex].status = .empty
            board.spots[previousIndex].currentParking = nil
        }
        board.spots[index].status = .occupied
        board.spots[index].currentParking = ParkingRecord(
            plateNumber: vehicle.plateNumber,
            enteredAt: board.spots[index].currentParking?.enteredAt ?? Date(),
            method: .correction
        )
        return board
    }
}
