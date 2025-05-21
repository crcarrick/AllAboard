//
//  TrainTimePickerView.swift
//  AllAboard
//
//  Created by Chris Carrick on 5/20/25.
//

import SwiftUI

struct TrainTimePickerView: View {
    @Binding var time: TrainTime
    
    var action: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Picker("Hour:", selection: hour) {
                ForEach(1...12, id: \.self) { h in
                    Text(String(format: "%02d", h)).tag(h)
                }
            }
            .labelsHidden()
            .frame(width: 50)
            .pickerStyle(.menu)
            
            Picker("Minute:", selection: minute) {
                ForEach(Array(stride(from: 0, through: 55, by: 5)), id: \.self) { m in
                    Text(String(format: "%02d", m)).tag(m)
                }
            }
            .labelsHidden()
            .frame(width: 50)
            .pickerStyle(.menu)
            
            Picker("AM/PM", selection: isAM) {
                Text("AM").tag(true)
                Text("PM").tag(false)
            }
            .labelsHidden()
            .frame(width: 50)
            .pickerStyle(.menu)
            
            Button("Add") {
                action()
            }
            .padding(.leading, 4)
            .keyboardShortcut(.defaultAction)
            .help("Add deploy time")
        }
    }
    
    private var hour: Binding<Int> {
        Binding(
            get: { time.hour % 12 == 0 ? 12 : time.hour % 12 },
            set: { val in
                time.hour = time.hour < 12
                    ? (val == 12 ? 0 : val)
                    : (val == 12 ? 12 : val + 12)
            }
        )
    }
    
    private var minute: Binding<Int> {
        Binding(
            get: { time.minute },
            set: { time.minute = $0 }
        )
    }
    
    private var isAM: Binding<Bool> {
        Binding(
            get: { time.hour < 12 },
            set: { val in
                let hour12 = time.hour % 12
                
                time.hour = val
                    ? (hour12 == 0 ? 0 : hour12)
                    : (hour12 == 0 ? 12 : hour12 + 12)
            }
        )
    }
}


private struct TrainTimePickerPreview: View {
    @State var time = TrainTime(hour: 0, minute: 0)
    @State var times: [TrainTime] = []

    private func appendTime() {
        times.append(time)
        time = TrainTime(hour: 0, minute: 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TrainTimePickerView(time: $time) {
                appendTime()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Formatted:").bold()
                    Text(time.formatted)
                }
                .font(.system(.body, design: .monospaced))
                HStack {
                    Text("Raw Value:").bold()
                    Text(String(format: "%02d:%02d", time.hour, time.minute))
                }
                .font(.system(.body, design: .monospaced))
            }
            
            List {
                ForEach(times, id: \.id) { t in
                    Text(t.formatted)
                }
            }
            .frame(height: 100)
        }
        .padding(30)
    }
}


#Preview {
    TrainTimePickerPreview()
}
