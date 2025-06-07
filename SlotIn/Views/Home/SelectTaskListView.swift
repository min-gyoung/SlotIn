//
//  SelectTaskListView.swift
//  SlotIn
//
//  Created by 김민경 on 6/7/25.
//

import SwiftUI
import EventKit

struct SelectTaskListView: View {
  @StateObject private var calendarManager = CalendarManager()
  @State private var selectedCalendarId: String = ""
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("작업 선택 - 영상별 보기")
      Text("영상 단위로 변경할 작업을 선택하세요.")
        .foregroundColor(.gray)
      
      // 캘린더 이름 기반 Picker
      Picker("카테고리 선택", selection: $selectedCalendarId) {
        Text("카테고리 선택").tag("") // 기본값
        ForEach(calendarManager.calendars, id: \.calendarIdentifier) { calendar in
          Text(calendar.title).tag(calendar.calendarIdentifier)
        }
      }
      .pickerStyle(MenuPickerStyle())
      .padding(.vertical)
      
      // 선택된 캘린더의 일정만 표시
      ForEach(0..<7, id: \.self) { offset in
        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        let dateKey = Calendar.current.startOfDay(for: date)
        
        let filteredEvents = calendarManager.events.filter {
          Calendar.current.isDate($0.startDate, inSameDayAs: dateKey) &&
          (selectedCalendarId.isEmpty || $0.calendar.calendarIdentifier == selectedCalendarId)
        }
        
        if !filteredEvents.isEmpty {
          VStack(alignment: .leading, spacing: 4) {
            Text(formattedDate(dateKey))
              .font(.headline)
              .padding(.top, 10)
            
            ForEach(filteredEvents, id: \.eventIdentifier) { event in
              HStack {
                Circle()
                  .fill(Color(event.calendar.cgColor ?? UIColor.systemGray.cgColor))
                  .frame(width: 10, height: 10)
                
                Text(event.title)
                  .font(.body)
                
                Spacer()
                
                if event.isAllDay {
                  Text("하루 종일")
                    .font(.caption)
                    .foregroundColor(.gray)
                } else {
                  Text("\(formattedTime(event.startDate)) - \(formattedTime(event.endDate))")
                    .font(.caption)
                    .foregroundColor(.gray)
                }
              }
            }
          }
        }
      }
    }
    .padding()
    .onAppear {
      calendarManager.loadCalendars()
      let start = Calendar.current.startOfDay(for: Date())
      let end = Calendar.current.date(byAdding: .day, value: 7, to: start)!
      calendarManager.fetchEvents(startDate: start, endDate: end)
    }
  }
  
  private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일 (E)"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
  }
  
  private func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
}

extension Color {
  init(cgColor: CGColor) {
    self = Color(UIColor(cgColor: cgColor))
  }
}

#Preview {
  SelectTaskListView()
}
