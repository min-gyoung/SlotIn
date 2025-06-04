////
////  TimeTableView.swift
////  SlotIn
////
////  Created by 김민경 on 6/2/25.
////
//

import SwiftUI
import EventKit

struct TimeTableView: View {
  let taskTitle: String
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
  
  // 예시 시간대
  let preferredStartHour = 9
  let preferredEndHour = 15
  
  init(taskTitle: String, startTime: Date, endTime: Date, startHour: Date, endHour: Date) {
    self.taskTitle = taskTitle
    self.startTime = startTime
    self.endTime = endTime
    self.startHour = startHour
    self.endHour = endHour
    
    let calendar = Calendar.current
    let weekInterval = calendar.dateInterval(of: .weekOfYear, for: startTime)
    let weekStart = weekInterval?.start ?? startTime
    
    _currentWeekStartDate = State(initialValue: weekStart)
    _currentStartDate = State(initialValue: weekStart)
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
        
        Text(TimeTableModel.weekInfoText(from: currentWeekStartDate))
        
        Spacer()
        
        Button(action: {
          currentWeekStartDate = TimeTableModel.nextWeek(from: currentWeekStartDate)
        }) {
          Image(systemName: "chevron.right")
        }
      }
      
      // 요일 헤더
      HStack(spacing: 3) {
        Spacer()
        ForEach(weekdays, id: \.self) { day in
          Text(day)
            .frame(width: 45)
            .font(.system(size: 14, weight: .medium))
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
        }
      }
      
      // 시간표
      ScrollView(.vertical) {
          HStack(alignment: .top, spacing: 3) {
            // 시간
            VStack(spacing: 3) {
              ForEach(preferredStartHour..<preferredEndHour, id: \.self) { hour in
                Text(String(format: "%02d", hour))
                  .frame(width: 36, height: 44, alignment: .trailing)
                  .font(.system(size: 14))
              }
            }
            
            // 요일, 시간 격자
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: 3), count: 7), spacing: 3) {
              ForEach(preferredStartHour..<preferredEndHour, id: \.self) { hour in
                ForEach(0..<7, id: \.self) { dayIndex in
                  slotButton(dayIndex: dayIndex, hour: hour)
                }
              }
            }
          }
          .padding(.trailing, 8)
        }
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
      TimeTableViewModal(
        taskTitle: taskTitle,
        startTime: startTime,
        endTime: endTime,
        duration: TimeInterval(requiredSlotCount * 60 * 60)
      )
    }
  }
  
  var model: TimeTableModel {
    TimeTableModel(startDate: startTime, endDate: endTime)
  }
  
  var requiredSlotCount: Int {
    let diff = Calendar.current.dateComponents([.minute], from: startTime, to: endTime)
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
            isValidSlotSelection = true
            // 선택 칸 수가 부족한 경우
            alertTitle = taskTitle
            alertDescription = formattedTimeRange(for: dayIndex, from: range.lowerBound, to: range.upperBound)
          } else {
            isValidSlotSelection = false
            alertTitle = "슬롯 선택 불가"
            alertDescription = "\(requiredSlotCount)시간 연속으로 선택해주세요."
          }
        } else {
          isValidSlotSelection = false
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
        .background(
          selectedSlots.contains(key)
          ? Color.green.opacity(0.7)
          : Color.gray.opacity(0.2)
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
  TimeTableView(
    taskTitle: "서강대학교 홍보 영상 기획 회의",
    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endTime: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!,
    startHour: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endHour: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!
  )
}

