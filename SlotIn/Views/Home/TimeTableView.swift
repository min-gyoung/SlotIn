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
  let startHour: Date
  let endHour: Date
  let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
  
  let columns = Array(repeating: GridItem(.flexible(), spacing: 40), count: 7)
  @State private var selectedSlots: Set<String> = [] // 요일-시간 형태로 저장
  @State private var currentWeekStartDate: Date
  @State private var currentStartDate: Date
  @State private var selectedStartSlot: (day: Int, hour: Int)? = nil
  @State private var showAlert = false
  @State private var alertMessage = ""
  @State private var alertTitle = ""
  @State private var alertDescription = ""
  @State private var showModal = false
  
  // 예시 시간대
  let preferredStartHour = 9
  let preferredEndHour = 15 // 15시는 포함 안 됨, 9-14시
  
  // 주간 날짜 계산
  var weekDates: [Date] {
    TimeTableModel.currentWeekDates(reference: currentWeekStartDate)
  }
  
    init(selectedTask: String, startTime: Date, endTime: Date, startHour: Date, endHour: Date) {
  var model: TimeTableModel {
    TimeTableModel(startDate: startTime, endDate: endTime)
  }
  
  // 시작-종료 시간 계산
  var requiredSlotCount: Int {
    let diff = Calendar.current.dateComponents([.minute], from: startTime, to: endTime)
    let totalMinutes = diff.minute ?? 0
    return Int(ceil(Double(totalMinutes) / 60.0)) // 60분 기준으로 올림
  }
  
  init(selectedTask: String, startTime: Date, endTime: Date) {
    self.selectedTask = selectedTask
    self.startTime = startTime
    self.endTime = endTime
    self.startHour = startHour
    self.endHour = endHour
    
    let calendar = Calendar.current
    let weekInterval = calendar.dateInterval(of: .weekOfYear, for: startTime)
    let weekStart = weekInterval?.start ?? startTime
    
    // currentWeekStartDate 초기값은 주차 시작일로 설정
    _currentWeekStartDate = State(initialValue: weekStart)
    
    _currentStartDate = State(initialValue: Calendar.current.dateInterval(of: .weekOfYear, for: startTime)?.start ?? startTime)
  }
  
  var body: some View {
    VStack {
      Text("시간 선택")
        .font(.title)
      
      Text(model.durationText)
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
            ForEach(preferredStartHour..<preferredEndHour, id: \.self) { hour in
              ForEach(0..<7, id: \.self) { dayIndex in
                slotButton(dayIndex: dayIndex, hour: hour)
              }
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
      }
    }
    .padding()
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text(alertTitle),
        message: Text(alertDescription),
        dismissButton: .default(Text("확인"), action: {
          showModal = true
        })
      )
    }
    
    .sheet(isPresented: $showModal) {
      TimeTableViewModal(
        selectedTask: "서강대학교 홍보 영상 기획 회의",
        startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
        endTime: Calendar.current.date(bySettingHour: 11, minute: 15, second: 0, of: Date())!
      )
    }
  }
  // 버튼 뷰
  @ViewBuilder
  private func slotButton(dayIndex: Int, hour: Int) -> some View {
    let key = "\(dayIndex)-\(hour)"
    
    // 첫 번째 선택 후
    Button(action: {
      if let start = selectedStartSlot {
        // 같은 요일을 클릭했는지 확인
        if start.day == dayIndex {
          // 시간 범위 정렬
          let range = start.hour <= hour ? start.hour...hour : hour...start.hour
          let slotCount = range.count
          // 선택한 시간 범위 확인
          if slotCount == requiredSlotCount {
            // 정상적으로 선택된 경우
            // 기존 선택 제거 후 새로 선택
            selectedSlots.removeAll()
            for h in range {
              selectedSlots.insert("\(dayIndex)-\(h)")
            }
            alertTitle = selectedTask
            alertDescription = formattedTimeRange(for: dayIndex, from: range.lowerBound, to: range.upperBound)
          } else if slotCount < requiredSlotCount {
            // 선택 칸 수가 부족한 경우
            alertTitle = "슬롯 선택 불가"
            alertDescription = "작업시간(\(model.durationText))에 필요한 연속 시간이 부족해요. 다른 시간대를 선택해주세요."
          } else {
            alertTitle = "선택 불가"
            alertDescription = "\(requiredSlotCount)칸을 연속으로 선택해야 합니다."
          }
        } else {
          alertTitle = "선택 불가"
          alertDescription = "같은 요일 내에서만 선택 가능합니다."
        }
        // 초기화, 알림
        selectedStartSlot = nil
        showAlert = true
      } else {
        selectedStartSlot = (day: dayIndex, hour: hour)
      }
    }) {
      Text("")
        .frame(width: 44, height: 44)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
          selectedSlots.contains(key) ? Color.green.opacity(0.7) :
            (selectedStartSlot?.day == dayIndex && selectedStartSlot?.hour == hour ? Color.green.opacity(0.7) : Color.gray.opacity(0.2))
        )
        .cornerRadius(4)
    }
  }
  
  // 날짜 및 시간 범위 포맷 함수
  private func formattedTimeRange(for dayIndex: Int, from startHour: Int, to endHour: Int) -> String {
    let date = weekDates[dayIndex]
    let calendar = Calendar.current
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일(E)"
    formatter.locale = Locale(identifier: "ko_KR")
    
    let dateString = formatter.string(from: date)
    
    let startTime = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: date)!
    let endTime = calendar.date(bySettingHour: endHour + 1, minute: 0, second: 0, of: date)!
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm"
    
    return "\(dateString) \(timeFormatter.string(from: startTime)) - \(timeFormatter.string(from: endTime))"
  }
}

#Preview {
  TimeTableView(selectedTask: "서강대학교 홍보 영상 기획 회의", startTime: Date(), endTime: Date() + 86400, startHour: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!, endHour: Calendar.current.date(bySettingHour: 11, minute: 15, second: 0, of: Date())!)
}
