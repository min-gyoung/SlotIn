//
//  DetailInputView.swift
//  SlotIn
//
//  Created by 윤보라 on 6/3/25.
//

import SwiftUI
import EventKit
import SwiftData

struct DetailInputView: View {
    
    //뒤로가기
    @Environment(\.dismiss) var dismiss
    
    @Environment(\.modelContext) private var context //swiftdata

    // 어떤 피커(날짜/시간)가 현재 활성화되어 있는지를 나타내는 상태 변수
    // nil일 경우, 아무 피커도 열려 있지 않다는 뜻
    @State private var activePicker: PickerType? = nil
    
    //날짜 및 시간 피커
    @State private var calendar: Calendar = .current //새로운 변수 추가
    @State var startDate: Date
    @State var endDate: Date
    
    //하루 중 선호하는 시간대
    @State var startTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 9
        components.minute = 0
        return Calendar.current.date(from: components)!
    }()
    @State var endTime: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 23
        components.minute = 0
        return Calendar.current.date(from: components)!
    }()
    //시간 기본 값 설정(시작은 09:00, 종료는 23:00)
    
    //팝업창
    @State private var showPopover = false
    
    //다음 화면으로 이동하는 것을 관리하는 변수
    @State private var isGoingTimeTable: Bool = false
    @State private var showTaskView: Bool = false // navigate to TaskView
    
    //선택된 일정
    @State var event: EKEvent
    
    @State private var alertString: String = ""
    

    // 사용할 피커의 종류를 구분
    // 버튼을 눌렀을 때 어떤 피커를 열지 선택
    // 피커가 버튼 바로 아래에 뜨게 하는 것 구현 못함
    enum PickerType {
        case startDate, endDate, startTime, endTime
    }

    //작업 가능 시작일 - 날짜 길이 더 커지면 날짜 두줄되는거 수정
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                // < 작업선택
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .foregroundColor(Color.green100)
                    .font(.system(size: 22, weight: .medium))

                    Text("작업 선택")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green100)
                        .font(.system(size: 17, weight: .semibold))
                }
                .padding()

                //뷰 제목
                Text("세부 정보 입력")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.gray100)
                    .padding(.bottom, 22)
                    .padding(.top, 10)
                    .padding(.horizontal, 16)

                //이벤트 제목
                Text(event.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.green100)
                    .padding(.horizontal, 17)
                    .padding(.bottom, 16)

                //세부 정보 리스트 상자
                VStack {
                    HStack {
                        Text("작업 가능 시작일")
                            .padding(.leading, 44)
                            .padding(.vertical, 8)
                            .font(.system(size: 16))

                        Spacer()

                        Button(action: {
                            activePicker = .startDate
                        }) {
                            Text(formattedDate(startDate))
                                .font(.system(size: 17))
                                .foregroundColor(Color.green200)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray500)
                                .cornerRadius(6)
                        }
                        .frame(width: 127, height: 34)
                        .padding(.horizontal, 40)
                    }
                    .padding(.vertical, 0.5)

                    Divider()
                        .background(Color.gray300.frame(width: 361))

                    HStack {
                        Text("작업 마감일")
                            .font(.system(size: 16))
                            .padding(.leading, 5)
                            .padding(.vertical, 8)

                        Spacer()

                        Button(action: {
                            activePicker = .endDate
                        }) {
                            Text(formattedDate(endDate))
                                .font(.system(size: 17))
                                .foregroundColor(Color.green200)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray500)
                                .cornerRadius(6)
                        }.frame(width: 127, height: 34)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 0.5)

                    Divider()
                        .background(Color.gray300.frame(width: 361))

                    HStack {
                        Text("하루 중 선호 시간대")
                            .padding(.leading, 5)
                            .padding(.vertical, 8)
                            .font(.system(size: 16))

                        Spacer()

                        Text("시작")
                            .font(.system(size: 15))
                            .padding(.horizontal, 8)

                        Button(action: {
                            activePicker = .startTime
                        }) {
                            Text(formattedTime(startTime))
                                .font(.system(size: 17))
                                .foregroundColor(Color.green200)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray500)
                                .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 0.5)

                    Divider()
                        .background(Color.gray300.frame(width: 361))

                    HStack {
                        Spacer()

                        Text("종료")
                            .font(.system(size: 15))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)

                        Button(action: {
                            activePicker = .endTime
                        }) {
                            Text(formattedTime(endTime))
                                .font(.system(size: 17))
                                .foregroundColor(Color.green200)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray500)
                                .cornerRadius(6)
                        }
                    }
                   .padding(.horizontal, 40)
                }
                .foregroundColor(Color.gray100)
                .background(Color.gray600.frame(width: 361, height: 201).cornerRadius(12))
                //상자의 너비 수정 필요한가?

                Spacer()
                
                //아래의 두 버튼
                HStack(spacing: 24) {
                    Button(action: {
                        // 작업 보류하기 기능 추가
                        alertString = alertMessage(item: event)
                        showPopover = true
                    }) {
                        Text("작업 보류하기")
                            .frame(width: 144)
                    }
                    .buttonStyle(OutlinedButtonStyle())
                    .fontWeight(.semibold)
                    .alert("작업이 보류되었습니다.", isPresented: $showPopover) {
                            Button(action: {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm"
                                
                                //하루 중 선호 시간대(preferredTime)
                                let preferred = "\(formatter.string(from: startTime)) ~ \(formatter.string(from: endTime))"
                                
                                //소요 시간(time) 계산: 분 단위
                                let interval = event.endDate.timeIntervalSince(event.startDate)
                                let minutes = Int(interval/60)
                                
                                //소요 시간을 문자열로 변환
                                let durationFormatter = DateComponentsFormatter()
                                    durationFormatter.allowedUnits = [.hour, .minute]
                                    durationFormatter.unitsStyle = .full
                                    let durationString = durationFormatter.string(from: interval) ?? ""
                                
                                let historyTask = Task(
                                            title: event.title,
                                            time: durationString,
                                            startDate: event.startDate,
                                            endDate: event.endDate,
                                            preferredTime: preferred
                                )
                                context.insert(historyTask)
                                showTaskView = true
                                
                                print("보관함으로 넘어가기")
                            }, label: {
                                Text("보관함에서 보기")
                            })
                        } message: {
                            Text(alertString)
                        }
                    
                    Button(action: {
                        // 가능한 시간만 보기 기능 추가
                        print("가능한 시간만 보기")
                        isGoingTimeTable.toggle()
                    }) {
                        Text("가능한 시간만 보기")
                            .frame(width: 144)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(FilledButtonStyle())
                    .navigationDestination(isPresented: $showTaskView){
                        TaskView()
                    }
                    .navigationDestination(isPresented: $isGoingTimeTable) {
                        TimeTableView(startTime: startDate, endTime: endDate, startHour: startTime, endHour: endTime, event: event)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 43)
                .background(Color.gray700)
            }
            .background(Color.gray700.edgesIgnoringSafeArea(.all))
            

            // 현재 선택된 피커(activePicker)가 nil이 아닌 경우에만 뷰를 띄움
            if let picker = activePicker {
                
                // 전체 화면을 덮는 반투명한 검은 배경
                // 사용자가 배경을 탭하면 피커를 닫도록 설정
                Color.black.opacity(0.3).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            activePicker = nil
                        }
                    }

                VStack {
                    // 현재 선택된 picker 타입에 따라 각각 다른 DatePicker를 표시
                    switch picker {
                    case .startDate:
                        DatePicker("", selection: $startDate, displayedComponents: [.date])
                            .symbolRenderingMode(.multicolor)
                            .datePickerStyle(.graphical)
                            .tint(Color.green200)
                            .background(Color.gray500)
                            .cornerRadius(13)
                            .frame(width: 340, height: 320)
                            .preferredColorScheme(.dark)
                        //현재 날짜 피커 투명도 조절 추가
                        //달력 크기 및 비율 조절 추가
                    case .endDate:
                        DatePicker("", selection: $endDate, displayedComponents: [.date])
                            .symbolRenderingMode(.multicolor)
                            .datePickerStyle(.graphical)
                            .tint(Color.green200)
                            .background(Color.gray500)
                            .cornerRadius(13)
                            .frame(width: 340, height: 340)
                            .preferredColorScheme(.dark)
                        //현재 날짜 피커 투명도 조절 추가
                        //달력 크기 및 비율 조절 추가
                    case .startTime:
                        DatePicker("", selection: $startTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .shadow(color: Color.gray700.opacity(0.1), radius: 30, x: 0, y: 10)
                            .frame(width:219, height: 195)
                            .background(Color.gray500)
                            .cornerRadius(13)
                            .preferredColorScheme(.dark)
                        //시간휠 글씨 희게 만들기
                    case .endTime:
                        DatePicker("", selection: $endTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .shadow(color: Color.gray700.opacity(0.1), radius: 30, x: 0, y: 10)
                            .frame(width:219, height: 195)
                            .background(Color.gray500)
                            .cornerRadius(13)
                            .preferredColorScheme(.dark)
                        //시간휠 글씨 희게 만들기
                    }
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // 날짜 포맷
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }

    // 시간 포맷
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    func formattedAlertDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E) HH:mm"
        return formatter.string(from: date)
    }
    
    func formattedAlertTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func alertMessage(item: EKEvent) -> String {
        let title = event.title ?? "일정 제목 없음"
        let start = event.startDate.flatMap { formattedAlertDate($0) } ?? "날짜 미설정"
        let end = event.endDate.flatMap { formattedAlertTime($0) } ?? "시간 미설정"
        return "\(title)\n\(start)-\(end)"
    }
}

//버튼 스타일
struct OutlinedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(Color.gray100)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 1))
    }
}

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(Color.gray700)
            .padding()
            .background(Color.green200)
            .cornerRadius(10)
    }
}

//팝업뷰 코드
//패딩값 조정
//프레임 세로 길이 조정


#Preview {
    DetailInputView(startDate: Date(), endDate: Date() + 3600, event: .init(eventStore: .init()))
}


