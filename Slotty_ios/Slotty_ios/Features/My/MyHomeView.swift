//
//  MyHomeView.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/18/26.
//

import SwiftUI

/// 마이 탭: 내 세대, 우리 세대 차 요약, 메뉴
struct MyHomeView: View {
    /// 홈과 같은 ViewModel - 입출차하면 차 요약도 함께 바뀐다
    let viewModel: ParkingHomeViewModel

    var body: some View {
        Group {
            if let board = viewModel.board {
                content(board)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("마이")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func content(_ board: ParkingBoard) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                household(board)
                vehicles(board)
                menu(board)
            }
            .padding(20)
        }
        .background(SlottyColor.background)
    }

    /// 빌라 이름과 내 세대 호수
    private func household(_ board: ParkingBoard) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("내 세대")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
            Text("\(board.villaName) · \(board.myUnit)호")
                .font(SlottyFont.headline)
                .foregroundStyle(SlottyColor.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }

    /// 우리 세대 차 요약 - 예: "12가3456 / 남편 차 · 2번 면 주차 중"
    private func vehicles(_ board: ParkingBoard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("우리 세대 차량 \(board.myVehicles.count)대")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
            if board.myVehicles.isEmpty {
                Text("등록된 차량이 없어요")
                    .font(SlottyFont.body)
                    .foregroundStyle(SlottyColor.primary)
            }
            ForEach(board.myVehicles) { vehicle in
                VStack(alignment: .leading, spacing: 4) {
                    Text(vehicle.plateNumber)
                        .font(SlottyFont.headline)
                        .foregroundStyle(SlottyColor.primary)
                    Text(vehicleStatus(vehicle, in: board))
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
        }
    }

    /// 별칭과 주차 상태 - 주차 중이 아니면 "운행 중"
    private func vehicleStatus(_ vehicle: Vehicle, in board: ParkingBoard) -> String {
        let status = board.spot(parkedBy: vehicle).map { "\($0.number)번 면 주차 중" } ?? "운행 중"
        guard let nickname = vehicle.nickname else { return status }
        return "\(nickname) · \(status)"
    }

    /// 하위 화면 메뉴 - 가용시간은 배정 면이 있는 세대만 보인다
    private func menu(_ board: ParkingBoard) -> some View {
        let hasAssignedSpot = board.spots.contains { $0.isAssigned(to: board.myUnit) }
        return VStack(spacing: 0) {
            menuRow("내 차량 관리")
            if hasAssignedSpot {
                Divider()
                menuRow("가용시간")
            }
            Divider()
            menuRow("설정")
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }

    /// 메뉴 한 줄 - 아직 만들지 않은 화면은 임시 화면으로 이동
    private func menuRow(_ title: String) -> some View {
        NavigationLink {
            Text("\(title) 준비 중")
                .font(SlottyFont.body)
                .foregroundStyle(SlottyColor.secondary)
        } label: {
            HStack {
                Text(title)
                    .font(SlottyFont.body)
                    .foregroundStyle(SlottyColor.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(SlottyColor.secondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let viewModel = ParkingHomeViewModel(repository: MockParkingRepository())
    NavigationStack {
        MyHomeView(viewModel: viewModel)
    }
    .task { await viewModel.load() }
}
