//
//  CalendarManager.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI
import EventKit

class CalendarManager: ObservableObject {
  private let eventStore = EKEventStore()
  
  @Published var events: [EKEvent] = []
  
  init() {
    // EKEventStore에 변경이 있을 때 일정 자동 조회 (fetch)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(eventStoreChanged),
      name: .EKEventStoreChanged,
      object: eventStore
    )
  }
  
  // 권한 요청
  func requestAccess(completion: @escaping () -> Void) {
    eventStore.requestAccess(to: .event) { granted, error in
      print("granted: \(granted)")
      print("error: \(String(describing: error))")
      if granted {
        DispatchQueue.main.async {
          completion()
        }
      } else {
        print("캘린더 접근 거부됨")
      }
    }
  }
  
  // 앱 생성 캘린더 가져오기
  // title prefix 조건으로 필터링 (ex. pip~으로 시작하는 캘린더만)
  func getCalendars(prefix: String = "") -> [EKCalendar] {
    eventStore.calendars(for: .event).filter {
      $0.source == eventStore.defaultCalendarForNewEvents?.source &&
      (prefix.isEmpty || $0.title.hasPrefix(prefix))
    }
  }
  
  // 카테고리별 캘린더 생성, 반환
  func getOrCreateCalendar(for category: String) -> EKCalendar {
    // 이미 있는 캘린더가 있으면 그대로 반환
    if let existing = eventStore.calendars(for: .event).first(where: { $0.title == category }) {
      return existing
    }
    
    // 없으면 새로 생성
    let calendar = EKCalendar(for: .event, eventStore: eventStore)
    calendar.title = category
    calendar.source = eventStore.defaultCalendarForNewEvents?.source
    
    do {
      try eventStore.saveCalendar(calendar, commit: true)
      print("캘린더 생성됨: \(category)")
    } catch {
      print("캘린더 생성 실패: \(error)")
    }
    
    return calendar
  }
  
  // 일정 추가
  func addEvent(title: String, startDate: Date, endDate: Date, notes: String, category: String) {
    let calendar = getOrCreateCalendar(for: category)
    
    let event = EKEvent(eventStore: eventStore)
    event.title = title
    event.startDate = startDate
    event.endDate = endDate
    event.notes = notes
    event.calendar = calendar
    
    do {
      try eventStore.save(event, span: .thisEvent)
      print("일정 추가 완료 (카테고리: \(category))")
    } catch {
      print("일정 추가 실패: \(error)")
    }
  }
  
  // 일정 수정
  func updateEvent(_ event: EKEvent, title: String, startDate: Date, endDate: Date, notes: String) {
    event.title = title
    event.startDate = startDate
    event.endDate = endDate
    event.notes = notes
    
    do {
      try eventStore.save(event, span: .thisEvent)
      print("일정 수정 완료")
    } catch {
      print("일정 수정 실패: \(error)")
    }
  }
  
  // 일정 삭제
  func deleteEvent(_ event: EKEvent) {
    do {
      try eventStore.remove(event, span: .thisEvent)
      print("일정 삭제 완료")
    } catch {
      print("일정 삭제 실패: \(error)")
    }
  }
  
  // 일정 조회 (전체)
  func fetchEvents(startDate: Date, endDate: Date) {
    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
    let events = eventStore.events(matching: predicate)
    
    DispatchQueue.main.async {
      self.events = events
    }
  }
  
  // 일정 조회 (특정 카테고리만)
  func fetchEvents(for  category: String, startDate: Date, endDate: Date) {
    guard let calendar = eventStore.calendars(for: .event).first(where: { $0.title == category }) else {
      self.events = []
      return
    }
    
    let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
    let events = eventStore.events(matching: predicate)
    
    DispatchQueue.main.async {
      self.events = events
    }
  }
  
  // 이벤트 변경 감지 시 자동 재조회
  @objc private func eventStoreChanged() {
    print("Event store changed")
    
    // 기본: 오늘 ~ 7일 후 범위로 자동 갱신
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: 7, to: start)!
    fetchEvents(startDate: start, endDate: end)
  }
}
