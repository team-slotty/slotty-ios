//
//  MyVehiclesView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import SwiftUI

/// 6-2 내 차량 관리 - 우리 세대 차량 목록, 등록, 삭제
struct MyVehiclesView: View {
    @State private var viewModel: MyVehiclesViewModel
    /// 등록하거나 삭제했을 때 - 현황판의 내 차량을 다시 불러온다
    let onChanged: () async -> Void
    /// 삭제를 확인 중인 차량, 확인창이 닫혀 있으면 nil
    @State private var deletingVehicle: RegisteredVehicle?
    /// 담당자를 고르는 중인 차량, 닫혀 있으면 nil
    @State private var changingVehicle: RegisteredVehicle?

    init(viewModel: MyVehiclesViewModel, onChanged: @escaping () async -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onChanged = onChanged
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(SlottyFont.caption)
                        .foregroundStyle(SlottyColor.secondary)
                }
                if let vehicles = viewModel.vehicles {
                    if vehicles.isEmpty {
                        Text("등록된 차량이 없어요")
                            .font(SlottyFont.body)
                            .foregroundStyle(SlottyColor.secondary)
                    }
                    ForEach(vehicles) { vehicle in
                        row(vehicle)
                    }
                } else if viewModel.errorMessage == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
        }
        .background(SlottyColor.background)
        .navigationTitle("내 차량 관리")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("+ 등록") {
                    VehicleRegisterView(viewModel: VehicleRegisterViewModel(repository: viewModel.repository)) {
                        await viewModel.load()
                        await onChanged()
                    }
                }
            }
        }
        .confirmationDialog(
            "\(deletingVehicle?.plateNumber ?? "")을 삭제할까요?",
            isPresented: isConfirmingDelete,
            titleVisibility: .visible,
            presenting: deletingVehicle
        ) { vehicle in
            Button("삭제", role: .destructive) {
                Task {
                    if await viewModel.delete(vehicle) {
                        await onChanged()
                    }
                }
            }
        } message: { _ in
            Text("주차 중이면 주차 기록도 지워지고 면이 빈 면이 돼요")
        }
        .confirmationDialog(
            "\(changingVehicle?.plateNumber ?? "") 연락 담당자",
            isPresented: isChoosingContact,
            titleVisibility: .visible,
            presenting: changingVehicle
        ) { vehicle in
            ForEach(viewModel.members) { member in
                Button(member.id == vehicle.contactUserId ? "\(member.name) (지금 담당자)" : member.name) {
                    Task { await viewModel.changeContact(of: vehicle, to: member) }
                }
            }
        }
        .task {
            await viewModel.load()
            await viewModel.loadMembers()
        }
    }

    /// 담당자 고르기 창을 띄울지 - 닫히면 고른 차량을 지운다
    private var isChoosingContact: Binding<Bool> {
        Binding(
            get: { changingVehicle != nil },
            set: { isShowing in
                if !isShowing {
                    changingVehicle = nil
                }
            }
        )
    }

    /// 확인창을 띄울지 - 닫히면 고른 차량을 지운다
    private var isConfirmingDelete: Binding<Bool> {
        Binding(
            get: { deletingVehicle != nil },
            set: { isShowing in
                if !isShowing {
                    deletingVehicle = nil
                }
            }
        )
    }

    /// 차량번호와 담당자 + 오른쪽 [삭제]
    private func row(_ vehicle: RegisteredVehicle) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.plateNumber)
                    .font(SlottyFont.headline)
                    .foregroundStyle(SlottyColor.primary)
                Text(vehicle.contactName.map { "담당자 \($0)" } ?? "담당자 지정 필요")
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            Spacer()
            Button("담당자") {
                changingVehicle = vehicle
            }
            .font(SlottyFont.body)
            .foregroundStyle(SlottyColor.primary)
            Button("삭제") {
                deletingVehicle = vehicle
            }
            .font(SlottyFont.body)
            .foregroundStyle(SlottyColor.secondary)
        }
        .padding(16)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }
}

#Preview {
    NavigationStack {
        MyVehiclesView(viewModel: MyVehiclesViewModel(repository: MockVehicleRepository())) {}
    }
}
