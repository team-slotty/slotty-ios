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
    /// 오늘 방문 예정 카드에 쓰는 방문 목록 - 방문차량 탭과 공유
    @State private var visitViewModel: VisitListViewModel
    /// 상세 시트로 보고 있는 면, 시트가 닫혀 있으면 nil
    @State private var selectedSpot: ParkingSpot?
    /// 입차 화면을 연 차량, 닫혀 있으면 nil
    @State private var enteringVehicle: Vehicle?
    /// [내 차예요]로 차를 고르는 중인 면, 닫혀 있으면 nil
    @State private var correctingSpot: ParkingSpot?
    /// 상세 시트가 닫힌 뒤 차 고르기를 열 면
    @State private var pendingCorrectionSpot: ParkingSpot?
    /// 상세 시트로 보고 있는 방문, 닫혀 있으면 nil
    @State private var selectedVisit: Visit?
    /// 차량 검색 화면에 넘겨줄 저장소
    private let searchRepository: any VehicleSearchRepository
    
    init(
        viewModel: ParkingHomeViewModel,
        visitViewModel: VisitListViewModel,
        searchRepository: any VehicleSearchRepository
    ) {
        _viewModel = State(initialValue: viewModel)
        _visitViewModel = State(initialValue: visitViewModel)
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
            await reload()
        }
        .alert(viewModel.errorMessage ?? "", isPresented: isShowingActionError) {
            Button("확인", role: .cancel) {}
        }
    }
    
    /// 현황판이 떠 있을 때 동작이 실패하면 알림창으로 - 처음 못 불러온 경우는 화면 가운데 문구로 보여 준다
    private var isShowingActionError: Binding<Bool> {
        Binding(get: { viewModel.board != nil && viewModel.errorMessage != nil },
                set: { isShowing in
            if !isShowing {
                viewModel.dismissError()
            }
        }
        )
    }
    
    /// 현황판과 오늘 방문 예정을 다시 불러온다 - 처음 열 때와 당겨서 새로고침할 때
    private func reload() async {
        await viewModel.load()
        await visitViewModel.load()
    }
    
    private func content(_ board: ParkingBoard) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header(board)
                myVehicles(board)
                let todayVisits = visitViewModel.todayVisits()
                if !todayVisits.isEmpty {
                    TodayVisitsCard(visits: todayVisits) { selectedVisit = $0 }
                }
                boardCard(board)
                legend
            }
            .padding(20)
        }
        .background(SlottyColor.background)
        .refreshable {
            await reload()
        }
        .sheet(item: $selectedSpot, onDismiss: {
            correctingSpot = pendingCorrectionSpot
            pendingCorrectionSpot = nil
        }) { spot in
            ParkingSpotDetailSheet(
                spot: spot,
                canExit: canExit(at: spot, in: board),
                onExit: {
                    selectedSpot = nil
                    Task { await viewModel.exit(spotNumber: spot.number) }
                },
                canRecordUnconfirmed: canRecordUnconfirmed(at: spot, in: board),
                onRecordUnconfirmed: {
                    selectedSpot = nil
                    Task { await viewModel.recordUnidentified(spotNumber: spot.number) }
                },
                canMarkLeft: canMarkLeft(at: spot, in: board),
                onMarkLeft: {
                    selectedSpot = nil
                    Task { await viewModel.markLeft(spotNumber: spot.number) }
                },
                canMarkAsMine: canMarkLeft(at: spot, in: board),
                onMarkAsMine: {
                    markAsMine(spot, in: board)
                },
                loadDetail: { await viewModel.spotDetail(number: spot.number) }
            )
            .presentationDetents([.medium])
        }
        .sheet(item: $correctingSpot) { spot in
            let drivingVehicles = drivingVehicles(in: board)
            VehicleSelectSheet(board: board, selected: nil, includesParked: drivingVehicles.isEmpty) { vehicle in
                correctingSpot = nil
                Task { await viewModel.markAsMine(spotNumber: spot.number, vehicle: vehicle) }
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $enteringVehicle) { vehicle in
            ParkingEntryView(board: board, vehicle: vehicle, loadOptions: { await viewModel.checkInOptions() }, onRecordUnconfirmed: { spotNumber in
                Task { await viewModel.recordUnidentified(spotNumber: spotNumber) }
            }) { vehicle, spotNumber in
                enteringVehicle = nil
                Task { await viewModel.enter(vehicle: vehicle, spotNumber: spotNumber) }
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $selectedVisit) { visit in
            VisitDetailView(
                visit: visit,
                onEnd: { await visitViewModel.end(visit) },
                onDelete: { await visitViewModel.delete(visit) },
                failureMessage: visitViewModel.actionErrorMessage,
                loadDetail: { await visitViewModel.detail(of: visit) },
                onUpdate: { await visitViewModel.update(visit, with: $0) },
                loadSpotOptions: { await visitViewModel.availableSpotNumbers(startAt: $0, endAt: $1) }
            )
            .presentationDetents([.medium])
        }
    }
    
    /// 이 면에 우리 세대 차가 서 있는지
    private func canExit(at spot: ParkingSpot, in board: ParkingBoard) -> Bool {
        board.myVehicles.contains { board.spot(parkedBy: $0)?.number == spot.number }
    }
    
    /// 내 배정 면이고, 미확인 차량으로 기록할 수 있는 상태인지
    private func canRecordUnconfirmed(at spot: ParkingSpot, in board: ParkingBoard) -> Bool {
        spot.isAssigned(to: board.myUnit) && spot.status.canRecordUnconfirmed
    }
    
    /// 주차 중이 아닌(운행 중인) 우리 세대 차
    private func drivingVehicles(in board: ParkingBoard) -> [Vehicle] {
        board.myVehicles.filter { board.spot(parkedBy: $0) == nil }
    }
    
    /// [내 차예요] - 운행 중인 차가 1대면 바로 정정, 아니면 상세 시트를 닫은 뒤 차 고르기
    private func markAsMine(_ spot: ParkingSpot, in board: ParkingBoard) {
        let drivingVehicles = drivingVehicles(in: board)
        if drivingVehicles.count == 1 {
            selectedSpot = nil
            Task { await viewModel.markAsMine(spotNumber: spot.number, vehicle: drivingVehicles[0]) }
        } else {
            pendingCorrectionSpot = spot
            selectedSpot = nil
        }
    }
    
    /// 내 배정 면에 미확인 차량이 기록돼 있는지
    private func canMarkLeft(at spot: ParkingSpot, in board: ParkingBoard) -> Bool {
        spot.isAssigned(to: board.myUnit) && spot.status == .unconfirmed
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
            if board.myVehicles.isEmpty {
                // 입차하려면 차량이 있어야 해서 등록할 곳을 알려 준다
                Text("등록된 차량이 없어요. 마이 탭에서 차량을 등록해 주세요.")
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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
            visitViewModel: VisitListViewModel(repository: MockVisitRepository()),
            searchRepository: MockVehicleSearchRepository()
        )
    }
}

