//
//  TimeTableViewModal.swift
//  SlotIn
//
//  Created by 김민경 on 6/4/25.
//

import SwiftUI
import EventKit

struct TimeTableViewModal: View {
  @Environment(\.presentationMode) var presentation
  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss
  @State private var startDate: Date
  @State private var showConfirmation = false
  @State private var events: [EKEvent] = []
  private let eventStore = EKEventStore()
  
  var recommendedSlot: DateInterval?
  var existingEvent: EKEvent?
  var taskTitle: String
  var startTime: Date
  var endTime: Date
  var duration: TimeInterval  // 초 단위 소요시간 (1시간 30분 = 5400)
  
  init(
    recommendedSlot: DateInterval? = nil,
    existingEvent: EKEvent? = nil,
    taskTitle: String,
    startTime: Date,
    endTime: Date,
    duration: TimeInterval = 5400  // 소요시간 임의 설정
  ) {
    self.recommendedSlot = recommendedSlot
    self.existingEvent = existingEvent
    self.taskTitle = taskTitle
    self.startTime = startTime
    self.endTime = endTime
    self.duration = duration
    _startDate = State(initialValue: startTime)
  }
  
  var calculatedEndDate: Date {
    return startDate.addingTimeInterval(duration)
  }
  
  var body: some View {
    ZStack {
      Color.gray700
        .ignoresSafeArea()
      VStack {
        Text("세부 시작 시간 설정")
          .font(.system(size: 17, weight: .semibold))
          .foregroundColor(Color.gray100)
          .padding(.bottom, 22)
          .padding(.top, 28)
          .padding(.horizontal, 16)
        
        // 제목
        Text(taskTitle)
          .font(.system(size: 17, weight: .semibold))
          .foregroundColor(Color.green100)
          .padding(.horizontal, 17)
          .padding(.bottom, 16)
        
        // 선택 날짜
        Text("\(formatted(startDate, dateOnly: true))")
          .font(.system(size: 17, weight: .semibold))
          .foregroundColor(Color.gray100)
          .padding(.horizontal, 17)
          .padding(.bottom, 16)
        
        // 소요 시간
        Text("소요 시간: \(formatted(duration))")
          .font(.system(size: 17, weight: .semibold))
          .foregroundColor(Color.gray300)
          .padding(.horizontal, 17)
          .padding(.bottom, 16)
        
        HStack {
          Text("시작 시간")
            .font(.system(size: 17))
            .foregroundColor(Color.gray100)
            .padding(.horizontal, 17)
            .padding(.bottom, 16)
          
          DatePicker(
            "",
            selection: $startDate,
            displayedComponents: [.hourAndMinute]
          )
          .datePickerStyle(.graphical)
          .tint(.white) // 임시
          .colorScheme(.dark) // 임시
          .onAppear {
            UIDatePicker.appearance().minuteInterval = 15
          }
          .onDisappear {
            UIDatePicker.appearance().minuteInterval = 1
          }
        }
        HStack {
          Text("종료 시간")
            .font(.system(size: 17))
            .foregroundColor(Color.gray100)
            .padding(.horizontal, 17)
            .padding(.bottom, 16)
          
          Text(formatted(calculatedEndDate, dateOnly: false))
            .font(.system(size: 17))
            .foregroundColor(Color.gray100)
            .padding(.horizontal, 17)
            .padding(.bottom, 16)
        }
        
        Button("이 시간으로 확정하기") {
          requestAccess {
            addEvent(
              title: taskTitle,
              startDate: startDate,
              endDate: calculatedEndDate,
              notes: "SlotIn에서 생성됨",
              category: "SlotIn"
            )
            showConfirmation = true
          }
        }
        .buttonStyle(FilledButtonStyle())
        
        // 애플캘린더에서 보기
        .alert("캘린더에 반영되었습니다.", isPresented: $showConfirmation) {
          Button("캘린더 열기") {
            // 애플 캘린더 앱 열기
            if let url = URL(string: "calshow://") {
              openURL(url)
            }
          }
          Button("작업 선택으로 돌아가기", role: .cancel) {
            dismiss()
          }
        } message: {
          if let slot = recommendedSlot {
            Text("확정된 일정: \(formatted(slot.start)) ~ \(formatted(slot.end))")
          } else {
            Text("추천 일정 정보가 없습니다.")
          }
        }
      }
    }
  }
  
  // 캘린더 접근 권한 요청
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
  
  // 카테고리별 EKCalendar 생성/가져오기
  func getOrCreateCalendar(for category: String) -> EKCalendar {
    if let existing = eventStore.calendars(for: .event).first(where: { $0.title == category }) {
      return existing
    }
    // 일정 등록 로직
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
  
  // 일정 조회
  func fetchEvents(startDate: Date, endDate: Date) {
    let start = Calendar.current.startOfDay(for: Date())
    let end = Calendar.current.date(byAdding: .day, value: 7, to: start)!
    
    let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
    let events = eventStore.events(matching: predicate)
    
    DispatchQueue.main.async {
      self.events = events
    }
  }
  
  private func formatted(_ date: Date, dateOnly: Bool = false) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = dateOnly ? "yyyy.MM.dd (E)" : "HH:mm"
    return formatter.string(from: date)
  }
  
  private func formatted(_ interval: TimeInterval) -> String {
    let minutes = Int(interval / 60)
    return "\(minutes / 60)시간 \(minutes % 60)분"
  }
  
  struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .font(.subheadline)
        .foregroundColor(Color.green700)
        .padding()
        .frame(maxWidth: .infinity, minHeight: 46)
        .background(Color.green200)
        .cornerRadius(10)
        .padding(.leading, 16)
        .padding(.trailing, 16)
    }
  }
}

#Preview {
  TimeTableViewModal(
    taskTitle: "서강대학교 홍보 영상 기획 회의",
    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endTime: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!,
    duration: 5400  // 1시간 30분
  )
}
