//
//  DashBoardView.swift
//  Els
//
//  Created by 박성민 on 10/3/24.
//

import SwiftUI

struct DashBoardView: View {
    @StateObject var dashBoardViewModel = DashBoardViewModel()
    @State private var isGraphClick = false
    @Namespace private var animationNamespace
    var body: some View {
        ZStack{
            Color(.gray).opacity(0.1)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if isGraphClick{
                DashBoard_ExtendGraphView(isGraphClick: $isGraphClick)
                    .environmentObject(dashBoardViewModel)
                    .matchedGeometryEffect(id: "graph", in: animationNamespace)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.8), value: isGraphClick)
            }else{
                HStack{
                    VStack{
                        DashBoard_Live()
                            .frame(width: 190,height: 270)
                            .background(Color.white)
                            .cornerRadius(30)
                        
                        DashBoard_CharacterView()
                            .frame(width: 190,height: 270)
                            .background(Color.white)
                            .cornerRadius(30)
                    }
                    VStack{
                        HStack{
                            VStack{
                                HStack{
                                    DashBoard_CheckingView()
                                        .frame(width: 190,height: 160)
                                        .background(Color.white)
                                        .cornerRadius(30)
                                    
                                    
                                    DashBoard_ConnectTimeView()
                                        .frame(width: 190,height: 160)
                                        .background(Color.white)
                                        .cornerRadius(30)
                                }
                                
                                DashBoard_Graph(viewModel: dashBoardViewModel)
                                    .frame(width: 380,height: 208)
                                    .background(Color.black)
                                    .cornerRadius(30)
                                    .matchedGeometryEffect(id: "graph", in: animationNamespace)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isGraphClick = true
                                        }
                                    }
                            }
                            VStack{
                                DashBoardIctProfil()
                                    .frame(width: 190,height: 100)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                
                                DashBoardWatherView()
                                    .frame(width: 190,height: 265)
                                    .background(Color.red)
                                    .cornerRadius(30)
                            }
                        }
                        HStack{
                            DashBoard_Logo()
                                .frame(width: 190,height: 160)
                                .background(Color.white)
                                .cornerRadius(30)
                            
                            DashBoard_DailyView()
                                .frame(width: 380,height: 160)
                                .background(Color.white)
                                .cornerRadius(30)
                        }
                    }
                }
                .environmentObject(dashBoardViewModel)
            }
        }
    }
}

#Preview {
    DashBoardView()
        .frame(width: 850, height: 600)
}

