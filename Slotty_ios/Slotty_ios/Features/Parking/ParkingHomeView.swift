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
    /// 상세 시트로 보고 있는 면, 시트가 닫혀 있으면 nil
    @State private var selectedSpot: ParkingSpot?
    /// 입차 화면을 연 차량, 닫혀 있으면 nil
    @State private var enteringVehicle: Vehicle?
    /// 차량 검색 화면에 넘겨줄 저장소
    private let searchRepository: any VehicleSearchRepository
    
    init(viewModel: ParkingHomeViewModel, searchRepository: any VehicleSearchRepository) {
        _viewModel = State(initialValue: viewModel)
        self.searchRepository = searchRepository
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
        .sheet(item: $selectedSpot) { spot in
            ParkingSpotDetailSheet(
                spot: spot,
                canExit: canExit(at: spot, in: board),
                onExit: {
                    selectedSpot = nil
                    Task { await viewModel.exit(spotNumber: spot.number) }
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(item: $enteringVehicle) { vehicle in
            ParkingEntryView(board: board, vehicle: vehicle) { vehicle, spotNumber in
                enteringVehicle = nil
                Task { await viewModel.enter(vehicle: vehicle, spotNumber: spotNumber) }
            }
            .presentationDetents([.medium])
        }
    }
    
    /// 이 면에 우리 세대 차가 서 있는지
    private func canExit(at spot: ParkingSpot, in board: ParkingBoard) -> Bool {
        board.myVehicles.contains { board.spot(parkedBy: $0)?.number == spot.number }
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
            NavigationLink {
                VehicleSearchView(viewModel: VehicleSearchViewModel(repository: searchRepository))
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundStyle(SlottyColor.primary)
            }
            .accessibilityLabel("차량 검색")
        }
    }
    
    /// 우리 세대 차 카드 목록
    private func myVehicles(_ board: ParkingBoard) -> some View {
        VStack(spacing: 12) {
            ForEach(board.myVehicles) { vehicle in
                let parkedSpot = board.spot(parkedBy: vehicle)
                MyVehicleCard(
                    vehicle: vehicle,
                    parkedSpot: parkedSpot,
                    onEnter: { enteringVehicle = vehicle },
                    onExit: {
                        guard let parkedSpot else { return }
                        Task { await viewModel.exit(spotNumber: parkedSpot.number) }
                    }
                )
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
                Button {
                    selectedSpot = spot
                } label: {
                    ParkingSpotCell(spot: spot, isMine: spot.isAssigned(to: myUnit))
                }
                .buttonStyle(.plain)
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
    NavigationStack {
        ParkingHomeView(
            viewModel: ParkingHomeViewModel(repository: MockParkingRepository()),
            searchRepository: MockVehicleSearchRepository()
        )
    }
}
