//
//  TimeTableView.swift
//  SlotIn
//
// Created by 김민경 on 6/2/25.
//

import SwiftUI
import EventKit

struct TimeTableView: View {
  let startTime: Date
  let endTime: Date
  let startHour: Date
  let endHour: Date
  
  let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
  let columns = Array(repeating: GridItem(.flexible(), spacing: 40), count: 7)
  
  @State private var selectedSlots: Set<String> = [] // 요일-시간 형태로 저장
  @State private var currentWeekStartDate: Date
  @State private var currentStartDate: Date
  @State private var selectedStartSlot: (day: Int, hour: Int)? = nil
  @State private var showAlert = false
  @State private var alertTitle = ""
  @State private var alertDescription = ""
  @State private var showModal = false
  @State private var isValidSlotSelection = false
  @State private var events: [EKEvent] = []
  @State private var selectedStartDate: Date? = nil
  @State private var selectedEndDate: Date? = nil
  private let eventStore = EKEventStore()
  @State var event: EKEvent
  
  var startHourValue: Int {
    Calendar.current.component(.hour, from: startHour)
  }
  
  var endHourValue: Int {
    Calendar.current.component(.hour, from: endHour)
  }
  
  init(startTime: Date, endTime: Date, startHour: Date, endHour: Date, event: EKEvent) {
    self.startTime = startTime
    self.endTime = endTime
    self.startHour = startHour
    self.endHour = endHour
    self.event = event
    
    let calendar = Calendar.current
    let weekInterval = calendar.dateInterval(of: .weekOfYear, for: startTime)
    let weekStart = weekInterval?.start ?? startTime
    
    _currentWeekStartDate = State(initialValue: weekStart)
    _currentStartDate = State(initialValue: weekStart)
  }
  
  var body: some View {
    VStack {
      Text("시간 선택")
        .font(.system(size: 28, weight: .bold))
        .foregroundColor(Color.gray100)
        .padding(.bottom, 22)
        .padding(.top, 12)
        .padding(.horizontal, 16)
      
      Text(event.title)
        .font(.system(size: 17, weight: .semibold))
        .foregroundColor(Color.green100)
        .padding(.horizontal, 17)
        .padding(.bottom, 16)
      
      Text(model.durationText)
        .font(.system(size: 17, weight: .semibold))
        .foregroundColor(Color.gray200)
        .padding(.horizontal, 17)
        .padding(.bottom, 16)
      
      HStack {
        Button(action: {
            selectedSlots.removeAll()
          currentWeekStartDate = TimeTableModel.previousWeek(from: currentWeekStartDate)
        }) {
          Image(systemName: "chevron.left")
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(Color.gray200)
            .padding(.horizontal, 17)
            .padding(.bottom, 16)
        }
        
        Spacer()
        
        Text(TimeTableModel.weekInfoText(from: currentWeekStartDate))
          .font(.system(size: 17, weight: .semibold))
          .foregroundColor(Color.gray200)
          .padding(.horizontal, 17)
          .padding(.bottom, 16)
        
        Spacer()
        
        Button(action: {
            selectedSlots.removeAll()
          currentWeekStartDate = TimeTableModel.nextWeek(from: currentWeekStartDate)
            
        }) {
          Image(systemName: "chevron.right")
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(Color.gray200)
            .padding(.horizontal, 17)
            .padding(.bottom, 16)
        }
      }
      
      // 요일 헤더
      HStack(spacing: 3) {
        Spacer()
        ForEach(weekdays, id: \.self) { day in
          Text(day)
            .frame(width: 15)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.gray200)
            .padding(.horizontal, 17)
            .padding(.bottom, 16)
        }
      }
      
      Divider()
      
      // 날짜 숫자 헤더
      HStack(spacing: 3) {
        Spacer().frame(width: 36) // 시간 라벨 영역 확보
        
        ForEach(weekDates, id: \.self) { date in
          Text("\(Calendar.current.component(.day, from: date))")
            .frame(width: 44, height: 20)
            .font(.system(size: 14))
            .multilineTextAlignment(.center)
            .foregroundColor(Color.gray200)
        }
      }
      
      // 시간표
      ScrollView(.vertical) {
        HStack(alignment: .top, spacing: 3) {
          // 시간
          VStack(spacing: 3) {
            ForEach(startHourValue..<endHourValue, id: \.self) { hour in
              Text(String(format: "%02d", hour))
                .frame(width: 36, height: 44, alignment: .trailing)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(Color.gray200)
            }
          }
          
          // 요일, 시간 격자
          LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: 3), count: 7), spacing: 3) {
            ForEach(startHourValue..<endHourValue, id: \.self) { hour in
              ForEach(0..<7, id: \.self) { dayIndex in
                slotButton(dayIndex: dayIndex, hour: hour)
              }
            }
          }
        }
        .padding(.trailing, 8)
      }
    }
    .onAppear {
      fetchEventsForWeek()
    }
    .padding()
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text(alertTitle),
        message: Text(alertDescription),
        dismissButton: .default(Text("확인"), action: {
          if isValidSlotSelection {
            showModal = true
          }
        })
      )
    }
    .sheet(isPresented: $showModal) {
      if let start = selectedStartDate, let end = selectedEndDate {
        TimeTableViewModal(
          taskTitle: event.title,
          startTime: start,
          endTime: end,
          duration: end.timeIntervalSince(start)
        )
      }
    }
    .background(Color.gray700.edgesIgnoringSafeArea(.all))
  }
  
  var model: TimeTableModel {
      guard let start = event.startDate, let end = event.endDate else {
                // fallback: 현재 시간을 기준으로 임시 모델 리턴
                return TimeTableModel(startDate: Date(), endDate: Date().addingTimeInterval(3600))
            }
            return TimeTableModel(startDate: start, endDate: end)
  }
  
  var requiredSlotCount: Int {
    let diff = Calendar.current.dateComponents([.minute], from: event.startDate, to: event.endDate)
    let totalMinutes = diff.minute ?? 0
    return Int(ceil(Double(totalMinutes) / 60.0))
  }
  
  var weekDates: [Date] {
    TimeTableModel.currentWeekDates(reference: currentWeekStartDate)
  }
  
  // 버튼 뷰
  @ViewBuilder
  private func slotButton(dayIndex: Int, hour: Int) -> some View {
    let key = "\(dayIndex)-\(hour)"
    let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: weekDates[dayIndex])!
    
    let isAvailable = !hasEvent(at: date) && !isOverDate(at: date)
    let isSelected = selectedSlots.contains(key)
    
    Button(action: {
      if isAvailable {
        // 기존 slotButton 동작 유지
          selectedStartSlot = (day: dayIndex, hour: hour)
        if let start = selectedStartSlot {
            let range = start.hour...hour + requiredSlotCount - 1
            let slotCount = range.count
              print(range)
              print(slotCount)
            
              if hour + requiredSlotCount <= endHourValue {
              selectedSlots.removeAll()
              for h in range {
                  let tempDate = Calendar.current.date(bySettingHour: h, minute: 0, second: 0, of: weekDates[dayIndex])!
                  let isAble = !hasEvent(at: tempDate) && !isOverDate(at: tempDate)
                  if isAble {
                      selectedSlots.insert("\(dayIndex)-\(h)")
                      isValidSlotSelection = true
                      alertTitle = event.title
                      alertDescription = formattedTimeRange(for: dayIndex, from: range.lowerBound, to: range.upperBound)
                  } else {
                      isValidSlotSelection = false
                      alertTitle = "슬롯 선택 불가"
                      alertDescription = "중간에 존재하는 일정 존재"
                  }
              }
              
            } else {
              isValidSlotSelection = false
              alertTitle = "슬롯 선택 불가"
              alertDescription = "\(requiredSlotCount)시간 연속으로 선택해주세요."
            }
          selectedStartSlot = nil
          showAlert = true
        } else {
          
            print("오류")
            
        }
      }
    }) {
      Text("")
        .frame(width: 44, height: 44)
        .background(
          isSelected
          ? Color.green300
          : (isAvailable ? Color.green100 : Color.gray.opacity(0.2))
        )
        .cornerRadius(4)
    }
  }
  
  // 날짜 및 시간 범위 포맷 함수
  private func formattedTimeRange(for dayIndex: Int, from startHour: Int, to endHour: Int) -> String {
    let date = weekDates[dayIndex]
    showAlert = true
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일(E)"
    formatter.locale = Locale(identifier: "ko_KR")
    
    selectedStartDate = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: date)
    selectedEndDate = calendar.date(bySettingHour: endHour + 1, minute: 0, second: 0, of: date)
    
    let dateString = formatter.string(from: date)
    let startTime = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: date)!
    let endTime = calendar.date(bySettingHour: endHour + 1, minute: 0, second: 0, of: date)!
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    
    return "\(dateString) \(timeFormatter.string(from: startTime)) - \(timeFormatter.string(from: endTime))"
  }
  
  // 이벤트 호출
  private func fetchEventsForWeek() {
    let startOfWeek = currentWeekStartDate
    let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: startOfWeek)!
    let predicate = eventStore.predicateForEvents(withStart: startOfWeek, end: endOfWeek, calendars: nil)
    events = eventStore.events(matching: predicate)
  }
  
  // 이벤트가 있는지 확인하는 함수
  private func hasEvent(at date: Date) -> Bool {
    for event in events {
      if event.startDate <= date && date < event.endDate {
        return true
      }
    }
    return false
  }
    
    private func isOverDate(at date: Date) -> Bool {
        if startTime <= date && date <= endTime {
            return false
      }
      return true
    }
}

#Preview {
  TimeTableView(
    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endTime: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!,
    startHour: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endHour: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!, event: .init(eventStore: .init())
  )
}
