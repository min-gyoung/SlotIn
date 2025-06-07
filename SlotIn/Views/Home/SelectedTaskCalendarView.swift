//
//  SelectedTaskCalendarView.swift
//  SlotIn
//
//  Created by 김민경 on 6/7/25.
//

import SwiftUI
import EventKit

struct SelectedTaskCalendarView: View {
  let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
  @State private var selectedSlots: Set<String> = [] // 요일-시간 형태로 저장
  @State private var currentWeekStartDate: Date
  @State private var currentStartDate: Date
  @State private var selectedStartSlot: (day: Int, hour: Int)? = nil
  @State private var events: [EKEvent] = []
  @State private var selectedStartDate: Date? = nil
  @State private var selectedEndDate: Date? = nil
  private let eventStore = EKEventStore()
  @State var event: EKEvent
  
  init(currentWeekStartDate: Date, currentStartDate: Date, event: EKEvent) {
    self._currentWeekStartDate = State(initialValue: currentWeekStartDate)
    self._currentStartDate = State(initialValue: currentStartDate)
    self._event = State(initialValue: event)
  }
  
  var weekDates: [Date] {
    TimeTableModel.currentWeekDates(reference: currentWeekStartDate)
  }
  
  var body: some View {
    VStack {
      Text("작업 선택 - 일정에서 보기")
      Text("캘린더에서 변경할 작업을 선택하세요.")
      
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
      
      Button(action: {}) {
        Text("작업 세부 정보 등록하기")
      }
    }
  }
}

#Preview {
  SelectedTaskCalendarView(
    currentWeekStartDate: Calendar.current.startOfDay(for: Date()),
    currentStartDate: Calendar.current.startOfDay(for: Date()),
    event: EKEvent(eventStore: EKEventStore())
  )
}
