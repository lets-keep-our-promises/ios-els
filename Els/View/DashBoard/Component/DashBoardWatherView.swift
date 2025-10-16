//
//  DashBoardWatherView.swift
//  Els
//
//  Created by 박성민 on 10/6/25.

import SwiftUI

struct DashBoardWatherView: View {
    var body: some View {
        ZStack{
            //맑을때 -> sunny 비올때 rain
            Image("sunny")
                .resizable()
                .scaledToFill()
            VStack{
                Text("봉양면")
                    .foregroundStyle(.white)
                    .font(.system(size: 18,weight: .thin))
                
                Text("21°")
                    .foregroundStyle(.white)
                    .font(.system(size: 60,weight: .thin))
                
                Text("맑음\n최고:21°최저:17°")
                    .foregroundStyle(.white)
                    .font(.system(size: 10,weight: .thin))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 190,height: 265)
    }
}

#Preview {
    DashBoardWatherView()
}
