//
//  VehicleSearchRow.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/17/26.
//

import SwiftUI

/// 검색 결과 한 줄 - 세대, 입주민/방문, 가린 번호

struct VehicleSearchRow: View {
    let result: VehicleSearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(SlottyFont.headline)
                .foregroundStyle(SlottyColor.primary)
            Text(subtitle)
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
    
    /// 예: "201호 차량", "403호 방문"
       private var title: String {
           switch result.kind {
           case .resident:
               "\(result.unit)호 차량"
           case .visitor:
               "\(result.unit)호 방문"
           }
       }
    
    /// 예: "입주민 · **가3456", "방문 · **마3456 · 오늘 14:00~18:00"
       private var subtitle: String {
           switch result.kind {
           case .resident:
               "입주민 · \(result.maskedPlateNumber)"
           case let .visitor(start, end):
               "방문 · \(result.maskedPlateNumber) · 오늘 \(time(start))~\(time(end))"
           }
       }

       private func time(_ date: Date) -> String {
           date.formatted(date: .omitted, time: .shortened)
       }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(MockVehicleSearchData.vehicles) { result in
            VehicleSearchRow(result: result)
        }
    }
    .padding(20)
}
