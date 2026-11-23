//
//  AvailabilityViewModel.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation
import Observation

/// 가용시간 등록 화면에서 입력 중인 값
struct AvailabilityForm: Equatable {
    var isRecurring = true
    /// 고른 요일 (MON~SUN)
    var days: Set<String> = []
    /// 하루만일 때 날짜
    var date = Date()
    var allDay = true
    /// 30분 단위 "HH:mm"
    var startTime = "09:00"
    var endTime = "18:00"
    
    /// 등록할 수 없는 이유, 문제 없으면 nil
    var problem: String? {
        if isRecurring && days.isEmpty {
            return "요일을 골라 주세요"
        }
        if !allDay && startTime >= endTime {
            return "끝 시간은 시작 시간보다 늦어야 해요"
        }
        return nil
    }
    
    /// 고를 수 있는 시각 - 00:00부터 23:30까지 30분 단위 (서버 규칙)
    static let times: [String] = (0..<48).map { String(format: "%02d:%02d", $0 / 2, $0 % 2 * 30) }
    
    /// 서버 요청으로 - 요일은 월~일 순서, 날짜는 yyyy-MM-dd
    func request(spotNumber: Int) -> AvailabilityRequest {
        AvailabilityRequest(
            slotId: spotNumber,
            isRecurring: isRecurring,
            days: isRecurring ? Availability.allDays.filter(days.contains) : nil,
            targetDate: isRecurring ? nil : Self.dateString(date),
            allDay: allDay,
            startTime: allDay ? nil : startTime,
            endTime: allDay ? nil : endTime
        )
    }
    
    /// 날짜를 서버 형식(yyyy-MM-dd, 한국 날짜)으로
    static func dateString(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}

/// 가용시간 화면의 목록과 동작
@Observable
final class AvailabilityViewModel {
    private(set) var items: [Availability]?
    /// 화면에 띄울 오류 문구 - 없으면 nil
    private(set) var errorMessage: String?
    
    private let repository: any AvailabilityRepository
    /// 가용시간을 거는 내 배정 면
    let spotNumber: Int
    
    init(repository: any AvailabilityRepository, spotNumber: Int) {
        self.repository = repository
        self.spotNumber = spotNumber
    }
    
    func load() async {
        do {
            items = try await repository.fetchAvailabilities()
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "가용시간을 불러오지 못했어요"
        }
    }
    
    /// 등록 - 성공하면 true
    func register(_ form: AvailabilityForm) async -> Bool {
        guard form.problem == nil else { return false }
        return await run { try await self.repository.register(form.request(spotNumber: self.spotNumber)) }
    }
    
    func delete(_ item: Availability) async {
        _ = await run { try await self.repository.delete(id: item.id) }
    }
    
    /// 오늘만 빼기 - 반복 가용시간에서
    func skipToday(_ item: Availability, today: Date = Date()) async {
        _ = await run { try await self.repository.skip(id: item.id, date: AvailabilityForm.dateString(today)) }
    }
    
    /// 동작을 하고 목록을 다시 불러온다 - 실패하면 서버 문구
    private func run(_ action: () async throws -> Void) async -> Bool {
        do {
            try await action()
            await load()
            return true
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "처리하지 못했어요"
            return false
        }
    }
}
