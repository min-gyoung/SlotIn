//
//  TimeTableModel.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import Foundation

struct TimeTableModel {
    static func durationText(start: Date, end: Date) -> String {
        let diff = Calendar.current.dateComponents([.hour, .minute], from: start, to: end)
        return "소요시간: \(diff.hour ?? 0)시간 \(diff.minute ?? 0)분"
    }

    static func weekInfoText(from date: Date) -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let weekOfMonth = calendar.component(.weekOfMonth, from: date)
        return "\(month)월 \(weekOfMonth)주차"
    }

    static func currentWeekDates(reference: Date = Date()) -> [Date] {
        let calendar = Calendar.current
        let weekDay = calendar.component(.weekday, from: reference) // 1 = Sun
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekDay - 1), to: reference)!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}
