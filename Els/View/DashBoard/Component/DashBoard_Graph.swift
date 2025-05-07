//
//  DashBoard_Graph.swift
//  Els
//
//  Created by 박성민 on 12/29/24.
//

import SwiftUI
import Combine
import Charts

class DataModel: ObservableObject {
    @Published var dataPoints: [Double] = []

    func addDataPoint(_ newValue: Double) {
        dataPoints.append(newValue)
        if dataPoints.count > 5 {
            dataPoints.removeFirst()
        }
    }
}

struct DashBoard_Graph: View {
    @ObservedObject var viewModel: DashBoardViewModel

    @State private var previousNormalTime: Double = 0
    @State private var normalTimeForLast10Seconds: Double = 0

    var body: some View {
        LineChartView(dataModel: viewModel.graphDataModel)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        let currentNormalTime = viewModel.normalTime
                        normalTimeForLast10Seconds = currentNormalTime - previousNormalTime
                        previousNormalTime = currentNormalTime
                        let abnormalTimeForLast10Seconds = 10.0 - normalTimeForLast10Seconds

                        viewModel.graphDataModel.addDataPoint(abnormalTimeForLast10Seconds)
                    }
                }
            }
    }
}

private struct LineChartView: View {
    @ObservedObject var dataModel: DataModel

    var body: some View {
        Chart {
            ForEach(Array(dataModel.dataPoints.enumerated()), id: \ .offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(Color(red: 142/255, green: 120/255, blue: 255/255))
            }
        }
        .chartYScale(domain: -1...15)
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks() { value in
                AxisTick()
            }
        }
        .frame(width: 380, height: 208)
        .background(Color(red: 71/255, green: 71/255, blue: 79/255))
        .cornerRadius(10)
        .animation(.easeInOut(duration: 0.5), value: dataModel.dataPoints)
    }
}

#Preview {
    DashBoard_Graph(viewModel: DashBoardViewModel())
        .frame(width: 380, height: 208)
        .background(Color.black)
        .cornerRadius(30)
        .padding()
}
