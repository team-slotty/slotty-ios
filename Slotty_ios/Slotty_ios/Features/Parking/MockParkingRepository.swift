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
    
    func enter(vehicle: Vehicle, spotNumber: Int) async throws ->
    ParkingBoard {
        guard let index = board.spots.firstIndex(where: { $0.number == spotNumber }) else {
            throw ParkingError.spotNotFound
        }
        guard !board.spots[index].status.isOccupied else {
            throw ParkingError.spotOccupied
        }
        let isAlreadyParked = board.spots.contains {
            $0.currentParking?.plateNumber == vehicle.plateNumber }
        guard !isAlreadyParked else {
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
}
