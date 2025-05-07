//
//  DashBoardIctProfil.swift
//  Els
//
//  Created by 박성민 on 10/9/24.
//

import SwiftUI

struct DashBoardIctProfil: View {
    var body: some View {
        HStack{
            ZStack{
                Image("BSLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
            }
            
            VStack(alignment:.leading){
                Text("손보석")
                    .font(.system(size: 20,weight: .bold))
                
                Spacer()
                    .frame(height: 5)
                
                Text(verbatim: "dyacode@pmh.codes")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    DashBoardIctProfil()
        .frame(width: 190,height: 100)
        .cornerRadius(20)
}
