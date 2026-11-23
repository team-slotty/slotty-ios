//
//  VehicleSearchRow.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/17/26.
//

import SwiftUI

/// 검색 결과 한 줄 - 세대, 입주민/방문, 가린 번호, [전화 걸기]
struct VehicleSearchRow: View {
    let result: VehicleSearchResult
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(SlottyFont.headline)
                    .foregroundStyle(SlottyColor.primary)
                Text(subtitle)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let callURL {
                Button("전화 걸기") {
                    openURL(callURL)
                }
                .buttonStyle(.slottySecondary)
                .frame(width: 96)
            }
        }
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
    
    /// 예: "입주민 · **3456", "방문 · **3456 · 오늘 14:00~18:00" (방문 시간은 볼 권한이 있을 때만)
    private var subtitle: String {
        switch result.kind {
        case .resident:
            "입주민 · \(result.maskedPlateNumber)"
        case let .visitor(start?, end?):
            "방문 · \(result.maskedPlateNumber) · 오늘 \(time(start))~\(time(end))"
        case .visitor:
            "방문 · \(result.maskedPlateNumber)"
        }
    }
    
    /// 전화 앱으로 넘길 주소 - 연락처 비공개면 nil이라 버튼이 안 보인다
    private var callURL: URL? {
        guard let phoneNumber = result.phoneNumber else { return nil }
        return URL(string: "tel:" + phoneNumber.filter(\.isNumber))
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
