//
//  ParkingEntryView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import SwiftUI

/// 입차 화면 - 차량과 주차면을 고르고 [입차하기]
struct ParkingEntryView: View {
    let board: ParkingBoard
    /// 고를 수 있는 면 불러오기 - 못 불러오면 nil
    let loadOptions: () async -> CheckInOptions?
    /// [내 면에 다른 차가 있어요] - 내 면 번호를 넘겨 미확인 차량으로 기록
    let onRecordUnconfirmed: (Int) -> Void
    let onEnter: (Vehicle, Int) -> Void

    @State private var vehicle: Vehicle
    /// 고를 수 있는 면, 불러오기 전이거나 실패하면 nil
    @State private var options: CheckInOptions?
    /// 면 불러오기가 끝났는지 - 실패 안내를 불러오는 중과 구분
    @State private var hasLoadedOptions = false
    /// 고른 주차면 번호, 고를 수 있는 면이 없으면 nil
    @State private var spotNumber: Int?
    @State private var isSelectingVehicle = false
    @State private var isSelectingSpot = false

    init(
        board: ParkingBoard,
        vehicle: Vehicle,
        loadOptions: @escaping () async -> CheckInOptions?,
        onRecordUnconfirmed: @escaping (Int) -> Void,
        onEnter: @escaping (Vehicle, Int) -> Void
    ) {
        self.board = board
        self.loadOptions = loadOptions
        self.onRecordUnconfirmed = onRecordUnconfirmed
        self.onEnter = onEnter
        _vehicle = State(initialValue: vehicle)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("입차")
                .font(SlottyFont.title)
                .foregroundStyle(SlottyColor.primary)
            selectionRow(title: "차량", value: vehicle.plateNumber, actionTitle: "다른 차량") {
                isSelectingVehicle = true
            }
            selectionRow(title: "주차면", value: spotNumber.map { "\($0)번" } ?? "선택 안 됨", actionTitle: "변경") {
                isSelectingSpot = true
            }
            if let notice {
                Text(notice)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            if let mySpot, mySpot.status.canRecordUnconfirmed {
                Button("내 면에 다른 차가 있어요") {
                    onRecordUnconfirmed(mySpot.number)
                    if spotNumber == mySpot.number {
                        spotNumber = nil
                    }
                }
                .buttonStyle(.slottySecondary)
            }
            Spacer()
            Button("입차하기") {
                if let spotNumber {
                    onEnter(vehicle, spotNumber)
                }
            }
            .buttonStyle(.slottyPrimary)
            .disabled(spotNumber == nil)
        }
        .padding(20)
        .task {
            options = await loadOptions()
            spotNumber = options?.suggestedSpotNumber
            hasLoadedOptions = true
        }
        .sheet(isPresented: $isSelectingVehicle) {
            VehicleSelectSheet(board: board, selected: vehicle) { selected in
                vehicle = selected
                isSelectingVehicle = false
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isSelectingSpot) {
            SpotSelectSheet(board: board, spotNumbers: options?.spotNumbers ?? [], selectedNumber: spotNumber) { selected in
                spotNumber = selected
                isSelectingSpot = false
            }
            .presentationDetents([.medium])
        }
    }

    /// 우리 세대에 배정된 면
    private var mySpot: ParkingSpot? {
        board.spots.first { $0.isAssigned(to: board.myUnit) }
    }

    /// 주차면 아래 안내 - 면을 못 불러왔거나, 고른 면이 없을 때
    private var notice: String? {
        guard hasLoadedOptions else { return nil }
        guard let options else {
            return "주차면을 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
        if options.spotNumbers.isEmpty {
            return "지금 입차할 수 있는 면이 없어요."
        }
        if spotNumber == nil, options.assignedAllOccupied {
            return "배정 면이 사용 중이에요. 다른 면을 선택해 주세요."
        }
        return nil
    }

    /// 항목 이름/값 + 오른쪽 변경 버튼 한 줄
    private func selectionRow(title: String, value: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
                Text(value)
                    .font(SlottyFont.headline)
                    .foregroundStyle(SlottyColor.primary)
            }
            Spacer()
            Button(actionTitle, action: action)
                .font(SlottyFont.body)
                .foregroundStyle(SlottyColor.primary)
        }
        .padding(16)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }
}

#Preview("배정 면 사용 중") {
    let board = MockParkingData.board
    let repository = MockParkingRepository()
    ParkingEntryView(board: board, vehicle: board.myVehicles[1], loadOptions: { try? await repository.checkInOptions() }, onRecordUnconfirmed: { _ in }) { _, _ in }
}

#Preview("배정 면 비어 있음") {
    var board = MockParkingData.board
    board.spots[1].status = .empty
    board.spots[1].currentParking = nil
    let options = CheckInOptions(spotNumbers: [2, 6, 7], suggestedSpotNumber: 2, assignedAllOccupied: false)
    return ParkingEntryView(board: board, vehicle: board.myVehicles[1], loadOptions: { options }, onRecordUnconfirmed: { _ in }) { _, _ in }
}
