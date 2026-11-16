//
//  ParkingSpotDetailSheet.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import SwiftUI

/// 면을 눌렀을 때 아래에서 올라오는 상세 정보
struct ParkingSpotDetailSheet: View {
    let spot: ParkingSpot
    /// 우리 세대 차가 서 있어서 출차할 수 있는지
    let canExit: Bool
    let onExit: () -> Void
    
    @State private var isConfirmingExit = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("\(spot.number)번 면")
                    .font(SlottyFont.title)
                    .foregroundStyle(SlottyColor.primary)
                Spacer()
                Text(spot.status.label)
                    .font(SlottyFont.subtitle)
                    .foregroundStyle(SlottyColor.secondary)
            }
            VStack(spacing: 12) {
                infoRow("배정 세대", spot.assignedUnit.map { "\($0)호" } ?? "공용")
                if let record = spot.currentParking {
                    infoRow("차량번호", record.maskedPlateNumber ?? "알 수 없음")
                    infoRow("입차 시각", record.enteredAt.formatted(date: .omitted, time: .shortened))
                    infoRow("기록 방식", record.method.label)
                }
            }
            if canExit {
                Button("출차") {
                    isConfirmingExit = true
                }
                    .buttonStyle(.slottyPrimary)
            }
        }
        .padding(20)
        .exitConfirmation("\(spot.number)번 면에서 출차할까요?", isPresented: $isConfirmingExit, onConfirm: onExit)
    }
    
    /// 왼쪽 항목 이름, 오른쪽 값 한 줄
    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(SlottyColor.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(SlottyColor.primary)
        }
        .font(SlottyFont.body)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ParkingSpotDetailSheet(spot: MockParkingData.board.spots[1], canExit: true, onExit: {})
                .presentationDetents([.medium])
        }
}
