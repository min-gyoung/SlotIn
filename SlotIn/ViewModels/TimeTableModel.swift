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
  
  // 주차 정보(정의: 첫 주가 온전히 있는 주(7일을 차지하는)가 1주차)
  static func weekInfoText(from date: Date) -> String {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    
    // 해당 달의 1일과 마지막 날
    guard let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
          let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
      return "\(month)월 1주차"
    }
    
    // 해당 월의 모든 날짜에서 week 시작일을 구함
    let weekStartDatesInMonth: [Date] = range.compactMap { day -> Date? in
      let date = calendar.date(from: DateComponents(year: year, month: month, day: day))
      return date.flatMap { calendar.dateInterval(of: .weekOfYear, for: $0)?.start }
    }
    
    // 중복 제거, 정렬
    let uniqueWeekStarts = Array(Set(weekStartDatesInMonth)).sorted()
    
    // 현재 날짜가 속한 주의 시작일
    guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start else {
      return "\(month)월 1주차"
    }
    
    // 주 시작일이 현재 달에 속하는 것만 필터링
    let validWeekStarts = uniqueWeekStarts.filter {
      calendar.component(.month, from: $0) == month
    }
    
    // 현재 주가 해당 달에서 몇 번째인지 찾기
    if let index = validWeekStarts.firstIndex(of: currentWeekStart) {
      return "\(month)월 \(index + 1)주차"
    } else {
      return "\(month)월 1주차"
    }
  }
  // 해당 날짜를 기준으로 한 주의 일-토 날짜 배열 반환
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
