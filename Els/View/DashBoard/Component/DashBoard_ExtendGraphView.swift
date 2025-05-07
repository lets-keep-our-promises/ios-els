// DashBoard_ExtendGraphView.swift
// Els
// Created by 박성민 on 12/29/24.

import SwiftUI
import Charts

class ExtendedDataModel: ObservableObject {
    @Published var dataPoints: [Double] = [
        10.0, 20.0, 15.0, 25.0, 30.0, 35.0, 40.0, 50.0, 45.0, 55.0,
                60.0, 50.0, 45.0, 35.0, 30.0, 25.0, 20.0, 15.0, 10.0, 5.0,
                15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 60.0,
                55.0, 50.0, 45.0, 40.0, 35.0, 30.0, 25.0, 20.0, 15.0, 10.0,
                5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0, 45.0, 50.0,
                55.0, 60.0, 55.0, 50.0, 45.0, 40.0, 35.0, 30.0, 25.0, 20.0
    ]

    func addDataPoint(_ newValue: Double) {
        dataPoints.append(newValue)
        if dataPoints.count > 60 {
            dataPoints.removeFirst()
        }
    }
}

struct DashBoard_ExtendGraphView: View {
    @Binding var isGraphClick: Bool
    @EnvironmentObject var viewModel: DashBoardViewModel

    @State private var previousNormalTime: Double = 0
    @State private var normalTimeForLast60Seconds: Double = 0

    var body: some View {
        ZStack {
            Color(red: 71/255, green: 71/255, blue: 79/255).edgesIgnoringSafeArea(.all)
            VStack {
                HStack{
                    Spacer()
                        .frame(width: 20)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isGraphClick = false
                        }
                    }) {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 50)
                            .background(Color.clear)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text("Health Care")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding()
                    Spacer()
                }

                LineChartView(dataModel: viewModel.extendedGraphDataModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                            withAnimation(.easeInOut(duration: 1.0)) {
                                let currentNormalTime = viewModel.normalTime
                                normalTimeForLast60Seconds = currentNormalTime - previousNormalTime
                                previousNormalTime = currentNormalTime
                                let abnormalTimeForLast60Seconds = 60.0 - normalTimeForLast60Seconds

                                viewModel.extendedGraphDataModel.addDataPoint(abnormalTimeForLast60Seconds)
                            }
                        }
                    }
            }
            .padding()
        }
    }
}

private struct LineChartView: View {
    @ObservedObject var dataModel: ExtendedDataModel

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
        .chartYScale(domain: -1...60)
        .chartXAxis {
            AxisMarks(values: .stride(by: 10)) { value in
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks() { value in
                AxisTick()
            }
        }
        .background(Color(red: 71/255, green: 71/255, blue: 79/255))
        .cornerRadius(10)
    }
}

#Preview {
    DashBoard_ExtendGraphView(isGraphClick: .constant(true))
        .environmentObject(DashBoardViewModel())
}
