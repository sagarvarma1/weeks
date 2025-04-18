//
//  BirthdayInputView.swift
//  weeks
//
//  Created by Sagar Varma on 4/12/25.
//

import SwiftUI

struct BirthdayInputView: View {
    @AppStorage("userBirthday") private var birthdayString: String = ""
    @State private var selectedDate = Date()
    @Binding var showBirthdayInput: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Life in Weeks")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Please enter your birthday")
                .font(.title2)
            
            DatePicker("Birthday", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
            
            Button(action: {
                // Save the date first
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                birthdayString = formatter.string(from: selectedDate)
                
                // Animate the state change to help trigger the view switch
                withAnimation {
                    showBirthdayInput = false
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            // If returning to update birthday, use the existing one
            if !birthdayString.isEmpty {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: birthdayString) {
                    selectedDate = date
                }
            }
        }
    }
}

#Preview {
    BirthdayInputView(showBirthdayInput: .constant(true))
} 