//
//  ParkingHomeView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/14/26.
//

import SwiftUI

/// 홈 탭: 주차 현황판

struct ParkingHomeView: View {
    @State private var viewModel: ParkingHomeViewModel

    init(viewModel: ParkingHomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if let board = viewModel.board {
                content(board)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(SlottyFont.body)
                    .foregroundStyle(SlottyColor.secondary)
            } else {
                ProgressView()
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func content(_ board: ParkingBoard) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header(board)
                myVehicles(board)
                boardCard(board)
                legend
            }
            .padding(20)
        }
        .background(SlottyColor.background)
    }

    /// 빌라 이름과 내 세대 호수
    private func header(_ board: ParkingBoard) -> some View {
        HStack {
            Text(board.villaName)
                .font(SlottyFont.title)
                .foregroundStyle(SlottyColor.primary)
            Spacer()
            Text("\(board.myUnit)호")
                .font(SlottyFont.body)
                .foregroundStyle(SlottyColor.secondary)
        }
    }
    
    /// 우리 세대 차 카드 목록
    private func myVehicles(_ board: ParkingBoard) -> some View {
        VStack(spacing: 12) {
            ForEach(board.myVehicles) { vehicle in
                MyVehicleCard(vehicle: vehicle, parkedSpot: board.spot(parkedBy: vehicle), onEnter: {}, onExit: {})
            }
        }
    }

    /// 주차면 그리드 카드
    private func boardCard(_ board: ParkingBoard) -> some View {
        let mySpotNumber = board.spots.first { $0.isAssigned(to: board.myUnit) }?.number
        let half = (board.spots.count + 1) / 2
        let topRow = Array(board.spots.prefix(half))
        let bottomRow = Array(board.spots.dropFirst(half))

        return VStack(alignment: .leading, spacing: 8) {
            Text(mySpotNumber.map { "주차 현황 (\($0)번 = 내 면)" } ?? "주차 현황")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
            spotRow(topRow, myUnit: board.myUnit)
            spotRow(bottomRow, myUnit: board.myUnit)
            Text("입구 ↓")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
                .frame(maxWidth: .infinity)
        }
        .padding(16)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }

    /// 주차면 한 줄
    private func spotRow(_ spots: [ParkingSpot], myUnit: String) -> some View {
        HStack(spacing: 8) {
            ForEach(spots) { spot in
                ParkingSpotCell(spot: spot, isMine: spot.isAssigned(to: myUnit))
            }
        }
    }
    
    /// 상태 범례
    private var legend: some View {
        let labels = [
            ParkingSpotStatus.occupied.label,
            ParkingSpotStatus.empty.label,
            ParkingSpotStatus.available.label,
            ParkingSpotStatus.visiting.label,
            ParkingSpotStatus.unconfirmed.label,
            "공용",
            ParkingSpotStatus.needsCheck.label,
        ]
        return FlowLayout {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay {
                        Capsule()
                            .strokeBorder(SlottyColor.line)
                    }
            }
        }
    }
}

#Preview {
    ParkingHomeView(viewModel: ParkingHomeViewModel(repository: MockParkingRepository()))
}
