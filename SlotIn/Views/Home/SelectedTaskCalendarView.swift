//
//  SelectedTaskCalendarView.swift
//  SlotIn
//
//  Edited by One on 6/7/25.
//

import SwiftUI
import EventKit

struct SelectedTaskCalendarView: View {
  let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
  @State private var currentWeekStartDate: Date
  @State private var events: [EKEvent] = []
  private let eventStore = EKEventStore()
  @State var event: EKEvent
    
    @State private var isSelected: Bool = false
  
  init(currentWeekStartDate: Date, event: EKEvent) {
    self._currentWeekStartDate = State(initialValue: currentWeekStartDate)
    self._event = State(initialValue: event)
  }
  
  var calendar: Calendar {
    var cal = Calendar.current
    cal.timeZone = TimeZone.current
    return cal
  }
  
  var formatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "a h시 mm분"
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone.current
    return formatter
  }
  
  var weekDates: [Date] {
    TimeTableModel.currentWeekDates(reference: currentWeekStartDate)
  }
  
  var dailyEvents: [[EKEvent]] {
    weekDates.map { date in
      let startOfDay = calendar.startOfDay(for: date)
      let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
      
      return events.filter { event in
        guard let start = event.startDate, let end = event.endDate else { return false }
        return start < endOfDay && end > startOfDay
      }
    }
  }
  
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            titleView
            
            calendarView
            
            
            
            Spacer()
            
            
            buttonView
            
            
        }
        .onAppear {
            fetchEventsForWeek()
        }
        .background(Color.gray700)
        .safeAreaPadding(.top, 60)
    } //body
    
    
    //MARK: first
    
    var titleView: some View {
        VStack {
            Text("작업 선택 - 일정에서 보기")
                .foregroundStyle(Color.gray100)
                .font(.system(size: 28, weight: .bold))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
    
    //MARK: middle
    
    var calendarView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("캘린더에서 변경할 작업을 선택하세요.")
                .foregroundStyle(Color.gray100)
                .font(.system(size: 17, weight: .semibold))
            
            VStack {
                headerView
                
                calendarInfoView
                
                calendarSlotView
            }
            
            if isSelected {
                VStack(alignment: .leading, spacing: 14) {
                    Text("선택 작업")
                        .foregroundStyle(Color.gray100)
                        .font(.system(size: 17, weight: .semibold))
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.gray500)
                            .frame(height: 80)
                        
                        VStack(spacing: 4) {
                            Text("일정 제목")
                                .foregroundStyle(Color.green100)
                                .font(.system(size: 17, weight: .semibold))
                            Text("일정 날짜")
                                .foregroundStyle(Color.gray100)
                                .font(.system(size: 17, weight: .regular))
                        }
                        .padding(16)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        
    }
    
    var headerView: some View {
      HStack {
        Button(action: {
          currentWeekStartDate = TimeTableModel.previousWeek(from: currentWeekStartDate)
          fetchEventsForWeek()
        }) {
          Image(systemName: "chevron.left")
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.gray100)
            .padding(.horizontal, 17)
        }
        
        Spacer()
        
        Text(TimeTableModel.weekInfoText(from: currentWeekStartDate))
              .foregroundStyle(Color.gray100)
              .font(.system(size: 17, weight: .semibold))
        
        Spacer()
        
        Button(action: {
          currentWeekStartDate = TimeTableModel.nextWeek(from: currentWeekStartDate)
          fetchEventsForWeek()
        }) {
          Image(systemName: "chevron.right")
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.gray100)
            .padding(.horizontal, 17)
        }
      }
    }
    
    var calendarInfoView: some View {
        VStack(spacing: 4) {
            VStack(spacing: 2) {
                HStack {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        VStack(spacing: 2) {
                            Text(weekdays[dayIndex])
                                .frame(width: 46, height: 20)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.gray100)
                        }
                    }
                }
                
                Divider()
                    .foregroundStyle(Color.gray600)
            }
            
            HStack {
                ForEach(0..<7, id: \.self) { dayIndex in
                    let date = weekDates[dayIndex]
                    Text("\(calendar.component(.day, from: date))")
                        .frame(width: 46, height: 20)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.gray100)
                    
                }
            }
        }
    }
    
    var calendarSlotView: some View {
        ScrollView {
            HStack {
                ForEach(0..<7, id: \.self) { dayIndex in
                  let dayEvents = dailyEvents[dayIndex]
                  let range = hourRange(for: dayEvents) ?? [9] // 최소 하나는 보여줌
                  VStack(spacing: 3) {
                    
                    ForEach(range, id: \.self) { hour in
                      Button(action: {
                          print(hour)
                          isSelected = true
                      }, label: {
                          slotCell(for: dayIndex, hour: hour, events: dayEvents)
                      })
                    }
                  }
                }
            }
        }
    }
    
    //MARK: last
    
    var buttonView: some View {
        VStack {
            Button(action: {
                print("qwer")
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(isSelected ? Color.green200 : Color.gray400)
                        .frame(height: 46)
                    Text("작업 세부 정보 등록하기")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isSelected ? Color.gray700 : Color.gray100)
                }
            })
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 43)
    }
  
  
  
  func fetchEventsForWeek() {
    let startOfWeek = currentWeekStartDate
    let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
    let predicate = eventStore.predicateForEvents(withStart: startOfWeek, end: endOfWeek, calendars: nil)
    events = eventStore.events(matching: predicate)
    
    print("불러온 일정 개수: \(events.count)")
    events.forEach { print("\($0.title) \($0.startDate) \($0.endDate)") }
  }
  
  func hourRange(for events: [EKEvent]) -> [Int] {
    let hours = events.flatMap {
      if $0.isAllDay {
        return [0] // 하루종일 일정은 0시에만 하나 표시
      } else {
        let startHour = calendar.component(.hour, from: $0.startDate)
        let endHour = calendar.component(.hour, from: $0.endDate)
        return Array(startHour..<endHour)
      }
    }
    
    if hours.isEmpty {
      return [9] // 기본 표시 시간
    }
    
    let minHour = max(0, hours.min() ?? 9)
    let maxHour = min(23, hours.max() ?? 21)
    return Array(minHour...maxHour)
  }
  
  func slotCell(for dayIndex: Int, hour: Int, events: [EKEvent]) -> some View {
    guard let slotStart = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: weekDates[dayIndex]),
          let slotEnd = calendar.date(bySettingHour: hour + 1, minute: 0, second: 0, of: weekDates[dayIndex]) else {
      return AnyView(EmptyView())
    }
    
    let matchingEvents = events.filter {
      if $0.isAllDay {
        return calendar.isDate(weekDates[dayIndex], inSameDayAs: $0.startDate)
        || calendar.isDate(weekDates[dayIndex], inSameDayAs: $0.endDate)
        || (weekDates[dayIndex] >= $0.startDate && weekDates[dayIndex] <= $0.endDate)
      } else {
        return $0.startDate < slotEnd && $0.endDate > slotStart
      }
    }
      .sorted { ($0.title ?? "") < ($1.title ?? "") }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "a h시 mm분"
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone.current
    
    let cell = VStack(spacing: 2) {
      if matchingEvents.isEmpty {
        Text("")
      } else {
        ForEach(matchingEvents, id: \.eventIdentifier) { event in
          VStack(spacing: 1) {
            Text(event.title ?? "제목 없음")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(.white)
              .lineLimit(1)
            
            if event.isAllDay {
              Text("하루종일")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.8))
            } else {
              Text(formatter.string(from: event.startDate))
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.8))
            }
          }
          .padding(2)
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .cornerRadius(4)
        }
      }
    }
      .frame(width: 46, height: 46)
      .background(matchingEvents.isEmpty ? Color.gray.opacity(0.2) : Color.clear)
    
    return AnyView(cell)
  }
}

#Preview {
  SelectedTaskCalendarView(
    currentWeekStartDate: Calendar.current.startOfDay(for: Date()),
    event: EKEvent(eventStore: EKEventStore())
  )
}
