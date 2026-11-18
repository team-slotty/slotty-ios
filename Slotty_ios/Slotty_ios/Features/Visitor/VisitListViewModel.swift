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
