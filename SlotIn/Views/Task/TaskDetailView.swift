//
//  TaskDetailView.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI

struct TaskDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
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
                }.foregroundColor(.green100).padding(8)
                //2. header: 작업 세부 정보
                HStack{
                    Text("작업 세부 정보")
                        .foregroundColor(.gray100)
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                }.padding(16)
                
                //3. Content
                
                VStack(alignment: .leading){
                    Text("제목")
                        .font(.system(size: 15))
                        .foregroundColor(.gray300)
                        .padding(.horizontal,15)
                        
                    
                    Text("서강대학교 홍보영상 기획 회의")
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                }.padding(.horizontal,13)
                    .padding(.vertical,10)
                
                
                VStack(alignment: .leading){
                    Text("소요시간")
                        .font(.system(size: 15))
                        .foregroundColor(.gray300)
                        .padding(.horizontal,15)
                        
                    
                    Text("3시간")
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                }.padding(.horizontal,13)
                    .padding(.vertical,10)
                
                VStack(alignment: .leading){
                    Text("작업 가능 시작일")
                        .font(.system(size: 15))
                        .foregroundColor(.gray300)
                        .padding(.horizontal,15)
                        
                    
                    Text("May 28, 2025")
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                }.padding(.horizontal,13)
                    .padding(.vertical,10)
                
                VStack(alignment: .leading){
                    Text("작업 마감일")
                        .font(.system(size: 15))
                        .foregroundColor(.gray300)
                        .padding(.horizontal,15)
                        
                    
                    Text("Jun 5, 2025")
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                }.padding(.horizontal,13)
                    .padding(.vertical,10)
                
                VStack(alignment: .leading){
                    Text("하루 중 선호 시간대")
                        .font(.system(size: 15))
                        .foregroundColor(.gray300)
                        .padding(.horizontal,15)
                        
                    
                    Text("9:00 - 18:00")
                        .foregroundColor(.white)
                        .padding(.horizontal,16)
                        .font(.system(size:16, weight: .semibold))
                        .frame(width: 368, height: 44, alignment: .leading)
                        .background(.gray600)
                        .cornerRadius(8)
                        
                }.padding(.horizontal,13)
                    .padding(.vertical,10)
                
                
                
                //4. Button
                Button{
                    
                } label:{
                    Text("가능한 시간 다시 보기")
                        .foregroundColor(.green700)
                        .font(.system(size:17, weight: .semibold))
                        .frame(width: 361, height: 46, alignment: .center)
                            .background(.green200)
                            .cornerRadius(8)
                            .padding(.horizontal, 16)
                            
                    
                }
                    .padding(.top,30)
                    
                
                Spacer()
                
                
            }
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    TaskDetailView()
}
