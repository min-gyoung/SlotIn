//
//  SelectTaskView.swift
//  SlotIn
//
//  Created by Bora Yun on 6/2/25.
//
/*
 1. 텍스트
 2. 텍스트
 3. datepicker : $date
 4. 텍스트 : datepicker로 날짜를 선택한 이후에만 노출
 5. 작업 목록 box: eventkit 연결
 6. 버튼
 */

import SwiftUI
import EventKit

struct SelectTaskView: View {
    
    @State private var date = Date() //션택한 날짜 (기존 일정이 등록된 날짜)
    @State private var showPicker: Bool = false //datepicker 공개 여부
    @State private var dateSelect: Bool = false //날짜 선택 여부
    @State private var selectedEvent: Int? = nil //선택한 작업(인덱스)
    
    @State private var events: [EKEvent] = [] //불러온 이벤트들 저장
    @State private var showDetailInputView: Bool = false //navigate to DetailInputView
    
    
    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                ZStack{
                    Color.gray700
                        .ignoresSafeArea()
                    
                    VStack{
                        //1. "작업 선택" text
                        HStack{
                            Text("작업 선택")
                                .foregroundColor(.gray100)
                                .font(.system(size:28, weight: .bold))
                                .padding(.horizontal, geometry.size.width * 0.0407)
                                .padding(.vertical, geometry.size.height * 0.0117)
                            Spacer()
                        }
                        //2. "기존 일정이 등록된 날짜를 선택해주세요" text
                        HStack{
                            Text("기존 일정이 등록된 날짜를 선택해주세요")
                                .font(.system(size:17, weight:.semibold))
                                .foregroundColor(.gray100)
                                .padding(.horizontal, geometry.size.width * 0.0432)
                                .padding(.vertical, geometry.size.height * 0.0164)
                            Spacer()
                        }
                        //3. datepicker
                        HStack{
                            Spacer()
                            Button{
                                showPicker.toggle()
                                dateSelect = true
                                fetchEvents(for:date) //날짜 선택될 때마다 이벤트 불러오기
                            } label:{
                                Text(date.formatted(date:.long, time:.omitted))
                                    .frame(width:127, height: 34)
                                    .font(.system(size:16))
                                    .background(.gray500)
                                    .cornerRadius(6)
                            }
                            .padding(.horizontal, geometry.size.width * 0.0407)
                            .padding(.bottom, geometry.size.height * 0.0328)
                            
                        }
                        if showPicker{
                            DatePicker(
                                "",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .frame(width:361, height: 340)
                            .padding(.horizontal, geometry.size.width * 0.0127)
                            .padding(.bottom, geometry.size.height * 0.0058)
                            .background(.gray500)
                            .datePickerStyle(.graphical)
                            .cornerRadius(13)
                            .labelsHidden()
                            .onChange(of: date) {newDate in
                                fetchEvents(for:newDate) //날짜 바뀔때마다 이벤트 갱신(누를때마다 되어서 datepicker를 끄면 이미 변경됨)
                                selectedEvent = nil //이벤트(인덱스) 선택 초기화
                                showPicker = false // 자동으로 datepicker 닫힘
                            }
                            
                        }
                        //4. "date에 등록된 작업 목록" text : datepicker로 날짜를 고른 후 공개
                        if !showPicker && dateSelect{
                            VStack{
                                Text("\(date.formatted(date:.complete,time:.omitted))에 등록된 작업 목록")
                                    .foregroundColor(.gray100)
                                    .font(.system(size:17, weight: .semibold))
                                    .padding(.leading, -geometry.size.width * 0.1526)
                                
                                
                                
                                //5. 작업 목록들
                                
                                if !events.isEmpty{
                                    ForEach(events.indices, id: \.self){ index in //인덱스 기반으로 가져오기
                                        let event = events[index]
                                        // 항목 box들
                                        HStack{
                                            VStack(alignment: .leading,spacing: geometry.size.height * 0.0117) {
                                                Text(event.title)
                                                    .foregroundColor(
                                                        selectedEvent == index ? .green700 : .green100)
                                                    .font(.system(size: 16, weight: .semibold))
                                                Text("\(formattedTime(event.startDate)) – \(formattedTime(event.endDate))")
                                                    .foregroundColor(
                                                        selectedEvent == index ? .gray500: .gray100)
                                                    .font(.system(size: 14))
                                            }
                                            .padding()
                                            .frame(width:360, height: 80, alignment: .leading)
                                            .background(
                                                selectedEvent == index ? .green200 : .gray500
                                            )
                                            .onTapGesture { // 눌러서 선택
                                                if selectedEvent == index{ //해당 목록을 다시 누르면, 해제
                                                    selectedEvent = nil
                                                } else{
                                                    selectedEvent = index
                                                }
                                            }
                                            .cornerRadius(10)
                                            .padding(.horizontal, geometry.size.width * 0.0432)
                                            .padding(.top, geometry.size.height * 0.0047)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "checkmark")
                                                .padding(.leading, -geometry.size.width * 0.1526)
                                                .opacity(selectedEvent == index ? 1:0) // image가 자리를 찾이하고 있어서, 눌러도 크기 안 달라짐
                                        }
                                        
                                        
                                    }
                                } else if dateSelect {
                                    Text("해당 날짜에 등록된 작업이 없습니다")
                                        .foregroundColor(.gray300)
                                        .padding(.horizontal, geometry.size.width * 0.0508)
                                        .padding(.vertical, geometry.size.height * 0.0234)
                                    
                                }
                                
                                Spacer()
                                
                                Button {
                                    //navigate to RecommendView
                                    if selectedEvent != nil{
                                        showRecommendView = true
                                    }
                                } label: {
                                    Text("가능한 시간 추천 받기")
                                        .frame(width: 361, height: 46)
                                        .background(
                                            selectedEvent != nil  ? .green200 :
                                                    .gray400)
                                        .cornerRadius(8)
                                        .foregroundColor(
                                            selectedEvent != nil ? .green700 : .gray100)
                                        .font(.system(size: 17, weight: .medium))
                                        .padding(.horizontal, geometry.size.width * 0.0407)
                                        .padding(.bottom, geometry.size.height * 0.0234)
                                }
                            }
                            
                        }
                        Spacer()
                    }.padding(.vertical,geometry.size.height * 0.0645)
                }.navigationDestination(isPresented: $showRecommendView){
                    if let index = selectedEvent {
                        DetailInputView(startDate: events[index].startDate, endDate: events[index].endDate, event: events[index])
                    }
                }
                //일정 상세화면에 선택된 일정 인덱스로 넘겨 주기
                
            }
        }
    }
            
            // EventKit에서 이벤트 가져오는 함수
            func fetchEvents(for date: Date) {
                let store = EKEventStore() //캘린더 접근, 이벤트 조회 가능
                
                store.requestAccess(to: .event) { granted, error in
                    guard granted else {
                        print("캘린더 접근 권한 없음")
                        return
                    } //캘린더 접근 권한 확인
                    
                    let calendar = Calendar.current //현재 시스템의 달력 가져오기
                    let startOfDay = calendar.startOfDay(for: date) //date의 자정이 시작
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)! //date의 익일 자정에 끝 (11:59)으로 수정해야 함
                    
                    let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil) //위의 범위에 해당하는 모든 캘린더(nil)의 이벤트를 가져오겠다는 조건
                    
                    let matchedEvents = store.events(matching: predicate) //해당 이벤트들을 배열로 가져옴
                    
                    DispatchQueue.main.async {
                        self.events = matchedEvents
                    }
                }
            }
            //날짜 형식 변환(시간)
            func formattedTime(_ date: Date) -> String {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            }
    }




#Preview {
    SelectTaskView()
}
