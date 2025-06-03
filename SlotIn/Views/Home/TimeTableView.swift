//
//  TimeTableView.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI

struct TimeTableView: View {
  let selectedTask: String
  let startTime: Date
  let endTime: Date
  let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
  
  let columns = Array(repeating: GridItem(.flexible(), spacing: 40), count: 7)
  @State private var selectedSlots: Set<String> = [] // "요일-시간" 형태로 저장
  @State private var currentWeekStartDate: Date
  
  // 예시 시간대
  let preferredStartHour = 9
  let preferredEndHour = 15 // 15시는 포함 안 됨, 9~14시

  
  // 주간 날짜 계산
  var weekDates: [Date] {
    TimeTableModel.currentWeekDates(reference: currentWeekStartDate)
  }
  
  init(selectedTask: String, startTime: Date, endTime: Date) {
    self.selectedTask = selectedTask
    self.startTime = startTime
    self.endTime = endTime
    
    let calendar = Calendar.current
    let weekInterval = calendar.dateInterval(of: .weekOfYear, for: startTime)
    let weekStart = weekInterval?.start ?? startTime
    
    // currentWeekStartDate 초기값은 주차 시작일로 설정
    _currentWeekStartDate = State(initialValue: weekStart)
  }
  
  var body: some View {
    VStack {
      Text("시간 선택")
        .font(.title)
      
      Text(selectedTask)
      
      Text(TimeTableModel.durationText(start: startTime, end: endTime))
        .font(.subheadline)
        .foregroundColor(.gray)
      
      HStack {
        Button(action: {
          currentWeekStartDate = TimeTableModel.previousWeek(from: currentWeekStartDate)
        }) {
          Image(systemName: "chevron.left")
        }
        
        Spacer()
        
        // n월 n주차
        Text(TimeTableModel.weekInfoText(from: currentWeekStartDate))
        
        Spacer()
        
        Button(action: {
          currentWeekStartDate = TimeTableModel.nextWeek(from: currentWeekStartDate)
        }) {
          Image(systemName: "chevron.right")
        }
      }
      
      // 요일 헤더
      HStack {
        ForEach(weekdays, id: \.self) { day in
          Text(day)
            .frame(width: 45)
        }
      }
      
      Divider()
      
      HStack {
        ForEach(weekDates, id: \.self) { date in
          Text("\(Calendar.current.component(.day, from: date))")
            .frame(width: 20)
            .padding(.leading, 30)
          
        }
      }
      
      ScrollView {
        // 사용자가 설정한 선호 시간대만 보임(정시 단위로)
        // ex) 9시~3시 설정하면 밑에 칸들은 안보임
        HStack(alignment: .top) {
          // 왼쪽 시간 라벨
          VStack(spacing: 3) {
//            ForEach(0..<24, id: \.self) { hour in
            ForEach(preferredStartHour..<preferredEndHour, id: \.self) { hour in
              Text(String(format: "%02d", hour))
                .frame(maxWidth: .infinity)
                .font(.system(size: 15))
                .padding(.vertical, 15)
                .padding(.leading, -30)
            }
          }
          .frame(width: 20) // 시간 라벨 너비 고정
          .padding(.top, 1)
          
          // 요일, 시간 격자
          LazyVGrid(columns: columns, spacing: 3) {
//            ForEach(0..<24, id: \.self) { hour in
            ForEach(preferredStartHour..<preferredEndHour, id: \.self) { hour in
              ForEach(0..<7, id: \.self) { dayIndex in
                let key = "\(dayIndex)-\(hour)"
                Button(action: {
                  if selectedSlots.contains(key) {
                    selectedSlots.remove(key)
                  } else {
                    selectedSlots.insert(key)
                  }
                }) {
                  Text("")
                    .frame(width: 44, height: 44)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(selectedSlots.contains(key) ? Color.green.opacity(0.7) : Color.gray.opacity(0.2))
                    .cornerRadius(4)
                }
              }
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
      }
    }
    .padding()
  }
}

#Preview {
  TimeTableView(
    selectedTask: "서강대학교 홍보 영상 기획 회의",
    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endTime: Calendar.current.date(bySettingHour: 11, minute: 15, second: 0, of: Date())!
  )
}
