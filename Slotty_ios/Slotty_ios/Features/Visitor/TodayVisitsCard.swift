//
//  TodayVisitsCard.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import SwiftUI

/// 홈 "오늘 방문 예정" 카드 - 방문 한 줄씩, 누르면 상세
struct TodayVisitsCard: View {
    let visits: [Visit]
    let onSelect: (Visit) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘 방문 예정")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
            ForEach(visits) { visit in
                Button {
                    onSelect(visit)
                } label: {
                    row(visit)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }
    
    /// 예:  78마3456  14:00~18:00  7번 면
    private func row(_ visit: Visit) -> some View {
        HStack {
            Text(visit.plateNumber)
                .font(SlottyFont.headline)
            Spacer()
            Text("\(time(visit.startAt))~\(time(visit.endAt))")
                .font(SlottyFont.body)
            Text(visit.spotNumber.map { "\($0)번 면" } ?? "면 지정 안 함")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
        }
        .foregroundStyle(SlottyColor.primary)
        .contentShape(Rectangle())
    }
    
    private func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}

#Preview {
    TodayVisitsCard(visits: MockVisitData.visits) { _ in }
        .padding(20)
}
