//
//  NextButton.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 24/06/2026.
//
import SwiftUI

struct NextButton: View {
   let title: String
   let action: () -> Void

   var body: some View {
       Button(action: action) {
           Text(title)
               .font(.system(size: 16, weight: .semibold))
               .foregroundColor(.white)
               .frame(maxWidth: .infinity)
               .padding(14)
               .background(Color.blue)
               .cornerRadius(12)
       }
       .padding(.horizontal)
       .padding(.bottom, 10)
   }
}

struct NextButton_Previews: PreviewProvider {
    static var previews: some View {
        NextButton(title: "Continue", action: {
        })
    }
}
