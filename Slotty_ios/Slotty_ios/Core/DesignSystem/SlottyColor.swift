//
//  SlottyColor.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/12/26.
//

import Foundation
import SwiftUI

enum SlottyColor {
    /// #333333 · 기본 글자, 기본 버튼, 선택 상태
    static let primary = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
    /// #8C8C8C · 보조 글자, 안내 문구
    static let secondary = Color(red: 0x8C / 255, green: 0x8C / 255, blue: 0x8C / 255)
    /// #D9D9D9 · 테두리, 비활성 아이콘
    static let line = Color(red: 0xD9 / 255, green: 0xD9 / 255, blue: 0xD9 / 255)
    /// #EDEDED · 검색창, 썸네일 배경
    static let fill = Color(red: 0xED / 255, green: 0xED / 255, blue: 0xED / 255)
    /// #F2C230 · 포인트 (사용 중·방문 중 주차면)
    static let accent = Color(red: 0xF2 / 255, green: 0xC2 / 255, blue: 0x30 / 255)
    /// #FFFFFF · 화면 배경, 카드 배경
    static let background = Color.white
}
