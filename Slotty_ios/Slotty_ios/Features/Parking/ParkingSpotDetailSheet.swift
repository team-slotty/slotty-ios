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
    /// 내 면이라 미확인 차량으로 기록할 수 있는지
    let canRecordUnconfirmed: Bool
    let onRecordUnconfirmed: () -> Void
    /// 내 면의 미확인 차량이 떠났다고 알릴 수 있는지
    let canMarkLeft: Bool
    let onMarkLeft: () -> Void
    /// 내 면의 미확인 차량이 사실 우리 세대 차라고 정정할 수 있는지
    let canMarkAsMine: Bool
    let onMarkAsMine: () -> Void
    
    @State private var isConfirmingExit = false
    @State private var isConfirmingLeft = false
    
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
            if spot.status == .unconfirmed {
                Text("등록되지 않은 차량이에요")
                    .font(SlottyFont.body)
                    .foregroundStyle(SlottyColor.primary)
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
            if canRecordUnconfirmed {
                VStack(alignment: .leading, spacing: 8) {
                    Button("미확인 차량으로 기록", action: onRecordUnconfirmed)
                        .buttonStyle(.slottySecondary)
                    Text("※ 관리자·면 주인은 미확인 차량으로 기록할 수 있어요")
                        .font(SlottyFont.caption)
                        .foregroundStyle(SlottyColor.secondary)
                }
            }
            if canMarkAsMine {
                Button("내 차예요", action: onMarkAsMine)
                    .buttonStyle(.slottyPrimary)
            }
            if canMarkLeft {
                Button("차량 떠남") {
                    isConfirmingLeft = true
                }
                .buttonStyle(.slottySecondary)
            }
        }
        .padding(20)
        .exitConfirmation("\(spot.number)번 면에서 출차할까요?", isPresented: $isConfirmingExit, onConfirm: onExit)
        .exitConfirmation("\(spot.number)번 면의 차가 떠났나요?", isPresented: $isConfirmingLeft, onConfirm: onMarkLeft)
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
            ParkingSpotDetailSheet(
                spot: MockParkingData.board.spots[5],
                canExit: false,
                onExit: {},
                canRecordUnconfirmed: false,
                onRecordUnconfirmed: {},
                canMarkLeft: true,
                onMarkLeft: {},
                canMarkAsMine: true,
                onMarkAsMine: {}
            )
            .presentationDetents([.medium])
        }
}
