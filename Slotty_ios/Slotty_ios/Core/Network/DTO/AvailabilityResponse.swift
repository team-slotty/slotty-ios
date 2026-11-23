//
//  AvailabilityResponse.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 가용시간 응답 - GET/POST /api/availabilities
/// 날짜(yyyy-MM-dd)와 시각(HH:mm)은 글자 그대로 받는다
struct AvailabilityResponse: Decodable {
    let availabilityId: Int
    let slotLabel: String
    let isRecurring: Bool
    let days: [String]?
    let targetDate: String?
    let allDay: Bool
    let startTime: String?
    let endTime: String?
    let skippedDates: [String]?

    func toAvailability() -> Availability {
        Availability(
            id: availabilityId, spotLabel: slotLabel,
            days: isRecurring ? (days ?? []) : [], targetDate: targetDate,
            allDay: allDay, startTime: startTime, endTime: endTime,
            skippedDates: skippedDates ?? []
        )
    }
}

/// 가용시간 등록 요청 - POST /api/availabilities
struct AvailabilityRequest: Encodable {
    let slotId: Int
    let isRecurring: Bool
    /// 반복일 때 요일, 아니면 nil
    let days: [String]?
    /// 하루만일 때 날짜 (yyyy-MM-dd), 반복이면 nil
    let targetDate: String?
    let allDay: Bool
    /// 종일이 아니면 30분 단위 "HH:mm"
    let startTime: String?
    let endTime: String?
}

/// 이번만 빼기 요청 - POST /api/availabilities/{id}/exceptions
struct AvailabilitySkipRequest: Encodable {
    /// yyyy-MM-dd
    let skipDate: String
}
