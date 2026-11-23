//
//  SlotLayout.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import Foundation

/// 서버(SlotLayoutCalculator)와 같은 배치 계산 - 모양, 입구 방향, 면 수 → 면 위치
/// 배치 변경 전에 바뀔 모양을 미리 보여 주려고 앱에도 같은 식을 둔다
/// 계산은 "입구가 아래(BOTTOM)" 기준으로 한 번 하고, 다른 입구는 좌표를 돌리거나 뒤집는다
enum SlotLayout {
    /// 면 하나 - 중심 위치와 크기는 주차장 전체를 1로 본 비율, rotation은 차가 놓인 방향(도)
    struct Slot: Equatable {
        let x: Double
        let y: Double
        let width: Double
        let height: Double
        let rotation: Int
    }
    
    /// 줄 배치에서 면의 세로 길이
    private static let slotDepth = 0.30
    private static let maxSlotWidth = 0.20
    
    static func calculate(template: String, entranceSide: String, count: Int) -> [Slot] {
        let base: [Slot]
        switch template {
        case "LINE":
            base = row(count, from: 0.05, to: 0.95, y: 0.30)
        case "L_SHAPE":
            // 왼쪽 세로 줄에 1/3, 위쪽 가로 줄에 나머지
            let side = count / 3
            base = row(count - side, from: 0.25, to: 0.95, y: 0.20) + column(side, from: 0.45, to: 0.95, x: 0.12)
        default:
            // DOUBLE - 위 줄이 하나 더 많게 (7면 → 4 + 3)
            let top = (count + 1) / 2
            base = row(top, from: 0.05, to: 0.95, y: 0.25) + row(count - top, from: 0.05, to: 0.95, y: 0.65)
        }
        return base.map { rotate($0, for: entranceSide) }
    }
    
    /// 가로 한 줄: from~to 구간을 k칸으로 나눠 각 칸 가운데에 둔다 (칸 사이 10% 여백)
    private static func row(_ k: Int, from: Double, to: Double, y: Double) -> [Slot] {
        let pitch = (to - from) / Double(max(k, 1))
        let width = min(maxSlotWidth, pitch * 0.9)
        return (0..<max(k, 0)).map { i in
            Slot(x: from + pitch * (Double(i) + 0.5), y: y, width: width, height: slotDepth, rotation: 0)
        }
    }
    
    /// 세로 한 줄 (ㄱ자의 옆 줄): 차가 가로로 서서 90도
    private static func column(_ k: Int, from: Double, to: Double, x: Double) -> [Slot] {
        let pitch = (to - from) / Double(max(k, 1))
        let height = min(maxSlotWidth, pitch * 0.9)
        return (0..<max(k, 0)).map { i in
            Slot(x: x, y: from + pitch * (Double(i) + 0.5), width: 0.20, height: height, rotation: 90)
        }
    }
    
    /// 입구 방향에 맞게 바꾸기 (기준: 입구가 아래 = 차도가 아래, 면이 위쪽)
    private static func rotate(_ slot: Slot, for entranceSide: String) -> Slot {
        switch entranceSide {
        case "TOP":
            Slot(x: slot.x, y: 1 - slot.y, width: slot.width, height: slot.height, rotation: slot.rotation)
        case "LEFT":
            Slot(x: 1 - slot.y, y: slot.x, width: slot.height, height: slot.width, rotation: (slot.rotation + 90) % 360)
        case "RIGHT":
            Slot(x: slot.y, y: slot.x, width: slot.height, height: slot.width, rotation: (slot.rotation + 90) % 360)
        default:
            slot
        }
    }
}
