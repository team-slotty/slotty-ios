//
//  VisitRow.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import SwiftUI

/// 방문 카드 한 줄 - 차량번호, 방문 일시, 지정 면
struct VisitRow: View {
    let visit: Visit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(visit.plateNumber)
                    .font(SlottyFont.headline)
                    .foregroundStyle(SlottyColor.primary)
                Spacer()
                if visit.status() == .needsCheck {
                    Text(VisitStatus.needsCheck.label)
                        .font(SlottyFont.caption)
                        .foregroundStyle(SlottyColor.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(SlottyColor.accent, in: Capsule())
                }
            }
            Text(period)
                .font(SlottyFont.body)
                .foregroundStyle(SlottyColor.primary)
            Text(visit.spotNumber.map { "\($0)번 면" } ?? "면 지정 안 함")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }
    
    /// 예: "오늘 14:00~18:00", "11월 20일 14:00~18:00"
    private var period: String {
        "\(day(visit.startAt)) \(time(visit.startAt))~\(time(visit.endAt))"
    }
    
    /// 오늘/내일/어제는 글자로, 그 밖에는 날짜로
    private func day(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "오늘" }
        if calendar.isDateInTomorrow(date) { return "내일" }
        if calendar.isDateInYesterday(date) { return "어제" }
        return date.formatted(.dateTime.month().day())
    }
    
    private func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(MockVisitData.visits) { visit in
            VisitRow(visit: visit)
        }
    }
    .padding(20)
}
