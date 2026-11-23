//
//  VisitRepository.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// 우리 세대 방문차량을 불러오고 등록/종료/삭제하는 약속
protocol VisitRepository {
    /// 우리 세대 방문 목록
    func fetchVisits() async throws -> [Visit]
    /// 방문 등록: 등록된 방문을 돌려준다
    func register(plateNumber: String, startAt: Date, endAt: Date, spotNumber: Int?) async throws -> Visit
    /// [방문 종료]: 방문 중인 방문을 지금 끝낸다
    func end(visitID: String) async throws -> Visit
    /// 삭제: 시작 전 방문만 지울 수 있다
    func delete(visitID: String) async throws
    /// 그 시간에 방문차량을 세울 수 있는 면 번호 (공용 면, 가용시간이 겹치는 면)
    func availableSpotNumbers(startAt: Date, endAt: Date) async throws -> [Int]
    /// 우리 세대에 자주 오는 방문 차량번호 - 최근 순
    func frequentPlateNumbers() async throws -> [String]
    /// 방문 상세 - 등록한 사람과 연락처
    func fetchDetail(visitID: String) async throws -> VisitDetail
    /// 수정: 시작 전 방문만 바꿀 수 있다, 바뀐 방문을 돌려준다
    func update(visitID: String, plateNumber: String, startAt: Date, endAt: Date, spotNumber: Int?) async throws -> Visit
}
