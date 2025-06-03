//
//  TimeTableModel.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import Foundation

struct TimeTableModel {
    // 시간 차이 텍스트
    static func durationText(start: Date, end: Date) -> String {
        let diff = Calendar.current.dateComponents([.hour, .minute], from: start, to: end)
        return "소요시간: \(diff.hour ?? 0)시간 \(diff.minute ?? 0)분"
    }

    // 주차 정보
    static func weekInfoText(from date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let weekOfMonth = calendar.component(.weekOfMonth, from: date)
        return "\(month)월 \(weekOfMonth)주차"
    }

    // 해당 날짜를 기준으로 한 주의 일~토 날짜 배열 반환
    static func currentWeekDates(reference: Date = Date()) -> [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: reference) // 1 = 일요일
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: reference)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    // 이전 주차 시작일
    static func previousWeek(from date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -7, to: date) ?? date
    }

    // 다음 주차 시작일
    static func nextWeek(from date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 7, to: date) ?? date
    }
}
