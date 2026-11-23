//
//  MockVisitRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// 목 데이터로 동작하는 방문 저장소
/// 앱이 켜져 있는 동안만 등록/종료/삭제를 기억한다
final class MockVisitRepository: VisitRepository {
    private var visits = MockVisitData.visits
    private var nextID = 1
    
    func fetchVisits() async throws -> [Visit] {
        visits
    }
    
    func register(plateNumber: String, startAt: Date, endAt: Date, spotNumber: Int?) async throws -> Visit {
        guard startAt < endAt, endAt.timeIntervalSince(startAt) <= 24 * 60 * 60 else {
            throw VisitError.invalidPeriod
        }
        let visit = Visit(
            id: "new\(nextID)", plateNumber: plateNumber,
            startAt: startAt, endAt: endAt, spotNumber: spotNumber
        )
        nextID += 1
        visits.append(visit)
        return visit
    }
    
    func end(visitID: String) async throws -> Visit {
        guard let index = visits.firstIndex(where: { $0.id == visitID }) else {
            throw VisitError.visitNotFound
        }
        guard visits[index].canEnd() else {
            throw VisitError.notVisiting
        }
        visits[index].endedAt = Date()
        return visits[index]
    }
    
    func delete(visitID: String) async throws {
        guard let index = visits.firstIndex(where: { $0.id == visitID }) else {
            throw VisitError.visitNotFound
        }
        guard visits[index].canDelete() else {
            throw VisitError.alreadyStarted
        }
        visits.remove(at: index)
    }
    
    /// 목 현황판의 공용 면
    func availableSpotNumbers(startAt: Date, endAt: Date) async throws -> [Int] {
        [6, 7]
    }
    
    func frequentPlateNumbers() async throws -> [String] {
        ["78마3456", "56바7890"]
    }
    
    func fetchDetail(visitID: String) async throws -> VisitDetail {
        VisitDetail(registeredBy: "김민준", phoneNumber: "010-0000-0001")
    }
    
    func update(visitID: String, plateNumber: String, startAt: Date, endAt: Date, spotNumber: Int?) async throws -> Visit {
        guard let index = visits.firstIndex(where: { $0.id == visitID }) else {
            throw VisitError.visitNotFound
        }
        guard visits[index].canDelete() else {
            throw VisitError.alreadyStarted
        }
        visits[index] = Visit(id: visitID, plateNumber: plateNumber, startAt: startAt, endAt: endAt, spotNumber: spotNumber)
        return visits[index]
    }
}
