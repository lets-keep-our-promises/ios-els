//
//  DashBoard_CharacterView.swift
//  Els
//
//  Created by 박성민 on 10/14/24.
//

import SwiftUI

struct DashBoard_CharacterView: View {
    var body: some View {
        VStack{
            Spacer()
            Image("SchoolLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .padding(.leading,5)
            Spacer()
            
            Image("Character")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(.leading,5)
        }
    }
}

#Preview {
    DashBoard_CharacterView()
        .frame(width: 190,height: 270)
}
