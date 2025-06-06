//
//  TaskDetailView.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI

struct TaskDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    let task: Task
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Color.gray700.ignoresSafeArea()
                VStack(alignment:.leading){
                    //1. Button : back button
                    HStack{
                        Button{
                            dismiss()
                        } label:{
                            Image(systemName: "chevron.left")
                                .foregroundColor(.green100)
                                .font(.system(size:22))
                            Text("보관함")
                                .font(.system(size:17))
                        }
                    }.foregroundColor(.green100)
                        .padding(.horizontal, geometry.size.width * 0.0203)
                        .padding(.bottom, geometry.size.height * 0.0093)
                    
                    //.padding(8)
                    //2. header: 작업 세부 정보
                    HStack{
                        Text("작업 세부 정보")
                            .foregroundColor(.gray100)
                            .font(.system(size: 28, weight: .bold))
                        Spacer()
                    }
                    .padding(.horizontal, geometry.size.width * 0.0407)
                    .padding(.bottom, geometry.size.height * 0.0187)
                    
                    //3. Content
                    
                    VStack(alignment: .leading){
                        Text("제목")
                            .font(.system(size: 15))
                            .foregroundColor(.gray300)
                            .padding(.horizontal,geometry.size.width * 0.0381)
                        
                        
                        Text("서강대학교 홍보영상 기획 회의")
                            .foregroundColor(.white)
                            .padding(.horizontal,geometry.size.width * 0.0407)
                            .font(.system(size:16, weight: .semibold))
                            .frame(width: 368, height: 44, alignment: .leading)
                            .background(.gray600)
                            .cornerRadius(8)
                        
                    }.padding(.horizontal,geometry.size.width * 0.0330)
                        .padding(.vertical,geometry.size.height * 0.0117)
                    
                    Text(task.title)
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                        
                        Text("3시간")
                            .foregroundColor(.white)
                            .padding(.horizontal,geometry.size.width * 0.0407)
                            .font(.system(size:16, weight: .semibold))
                            .frame(width: 368, height: 44, alignment: .leading)
                            .background(.gray600)
                            .cornerRadius(8)
                        
                    }.padding(.horizontal,geometry.size.width * 0.0330)
                        .padding(.vertical,geometry.size.height * 0.0117)
                    
                    Text(task.time)
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                        
                        Text("May 28, 2025")
                            .foregroundColor(.white)
                            .padding(.horizontal,geometry.size.width * 0.0407)
                            .font(.system(size:16, weight: .semibold))
                            .frame(width: 368, height: 44, alignment: .leading)
                            .background(.gray600)
                            .cornerRadius(8)
                        
                    }.padding(.horizontal,geometry.size.width * 0.0330)
                        .padding(.vertical,geometry.size.height * 0.0117)
                    
                    Text("\(task.startDate.formatted(date:.long, time:.omitted))")
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                        
                        Text("Jun 5, 2025")
                            .foregroundColor(.white)
                            .padding(.horizontal,geometry.size.width * 0.0407)
                            .font(.system(size:16, weight: .semibold))
                            .frame(width: 368, height: 44, alignment: .leading)
                            .background(.gray600)
                            .cornerRadius(8)
                        
                    }.padding(.horizontal,geometry.size.width * 0.0330)
                        .padding(.vertical,geometry.size.height * 0.0117)
                    
                    Text("\(task.endDate.formatted(date: .long, time:.omitted))")
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                        
                        Text("9:00 - 18:00")
                            .foregroundColor(.white)
                            .padding(.horizontal,geometry.size.width * 0.0407)
                            .font(.system(size:16, weight: .semibold))
                            .frame(width: 368, height: 44, alignment: .leading)
                            .background(.gray600)
                            .cornerRadius(8)
                        
                    }.padding(.horizontal,geometry.size.width * 0.0330)
                        .padding(.vertical,geometry.size.height * 0.0117)
                    
                    Text(task.preferredTime)
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                    } label:{
                        Text("가능한 시간 다시 보기")
                            .foregroundColor(.green700)
                            .font(.system(size:17, weight: .semibold))
                            .frame(width: 361, height: 46, alignment: .center)
                            .background(.green200)
                            .cornerRadius(8)
                            .padding(.horizontal, geometry.size.width * 0.0407)
                        
                        
                    }
                    .padding(.top,geometry.size.height * 0.0352)
                    
                    
                    Spacer()
                    
                    
                }
            }.navigationBarBackButtonHidden()
        }
    }
}

//#Preview {
//    TaskDetailView()
//}
