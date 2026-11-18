//
//  VisitListViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation
import Observation

/// 방문차량 목록 화면의 상태와 동작
@Observable
final class VisitListViewModel {
    /// 우리 세대 방문 - 불러오기 전에는 nil
    private(set) var visits: [Visit]?
    /// 화면에 띄울 오류 문구 - 없으면 nil
    private(set) var errorMessage: String?
    
    private let repository: any VisitRepository
    
    init(repository: any VisitRepository) {
        self.repository = repository
    }
    
    /// 방문 목록 불러오기
    func load() async {
        do {
            visits = try await repository.fetchVisits()
            errorMessage = nil
        } catch {
            errorMessage = "방문 목록을 불러오지 못했어요"
        }
    }
    /// 방문 등록 - 성공하면 목록에 더하고 true, 실패하면 false
    func register(_ form: VisitForm) async -> Bool {
        guard form.problem == nil else { return false }
        do {
            let visit = try await repository.register(
                plateNumber: form.trimmedPlateNumber,
                startAt: form.startAt,
                endAt: form.endAt,
                spotNumber: form.spotNumber
            )
            visits = (visits ?? []) + [visit]
            return true
        } catch {
            return false
        }
    }
    
    /// [방문 종료] - 성공하면 목록의 방문을 끝난 방문으로 바꾸고 true
    func end(_ visit: Visit) async -> Bool {
        do {
            let ended = try await repository.end(visitID: visit.id)
            visits = visits?.map { $0.id == ended.id ? ended : $0 }
            return true
        } catch {
            return false
        }
    }
    
    /// 삭제 - 성공하면 목록에서 빼고 true
    func delete(_ visit: Visit) async -> Bool {
        do {
            try await repository.delete(visitID: visit.id)
            visits?.removeAll { $0.id == visit.id }
            return true
        } catch {
            return false
        }
    }
    
    /// 구분에 맞는 방문 - 예정/방문 중은 빠른 순, 지난 방문은 최근 순
    func visits(in filter: VisitFilter, now: Date = Date()) -> [Visit] {
        let filtered = (visits ?? []).filter { filter.contains($0.status(at: now)) }
        switch filter {
        case .scheduled, .visiting:
            return filtered.sorted { $0.startAt < $1.startAt }
        case.ended:
            return filtered.sorted { $0.endAt > $1.endAt }
        }
    }
}
