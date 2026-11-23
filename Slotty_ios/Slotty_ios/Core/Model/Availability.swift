//
//  Availability.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 내 면을 비워 두는 시간 한 건 - 그 시간에는 다른 세대가 쓸 수 있다
struct Availability: Identifiable, Equatable {
    let id: Int
    /// 예: 1번
    let spotLabel: String
    /// 매주 반복이면 요일(MON~SUN), 하루만이면 빈 배열
    let days: [String]
    /// 하루만일 때 날짜 (예: 2026-11-24), 반복이면 nil
    let targetDate: String?
    let allDay: Bool
    /// "HH:mm", 종일이면 nil
    let startTime: String?
    let endTime: String?
    /// [이번만 빼기]로 뺀 날짜들 (오늘 이후)
    let skippedDates: [String]

    var isRecurring: Bool { !days.isEmpty }

    /// 예: "매주 월 수 · 09:00~18:00", "2026-11-24 · 종일"
    var summary: String {
        let when = isRecurring ? "매주 " + days.map { Self.dayLabel($0) }.joined(separator: " ") : (targetDate ?? "")
        let time = allDay ? "종일" : "\(startTime ?? "")~\(endTime ?? "")"
        return "\(when) · \(time)"
    }

    /// 서버 요일 글자를 한글로
    static func dayLabel(_ day: String) -> String {
        ["MON": "월", "TUE": "화", "WED": "수", "THU": "목", "FRI": "금", "SAT": "토", "SUN": "일"][day] ?? day
    }

    /// 요일 순서 (월~일)
    static let allDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
}
