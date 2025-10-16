import SwiftUI
import Combine
import Charts

class DataModel: ObservableObject {
    @Published var dataPoints: [Double] = []

    func addDataPoint(_ newValue: Double) {
        dataPoints.append(newValue)
        if dataPoints.count > 60 {
            dataPoints.removeFirst()
        }
    }
}

struct DashBoard_Graph: View {
    @ObservedObject var viewModel: DashBoardViewModel
    @State private var timer: Timer?

    var body: some View {
        LineChartView(dataModel: viewModel.graphDataModel)
            .onAppear {
                startGraphUpdates()
            }
            .onDisappear {
                stopGraphUpdates()
            }
    }
    
    private func startGraphUpdates() {
        // 기존 타이머가 있다면 정리
        timer?.invalidate()
        
        // 10초마다 그래프 업데이트
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            updateGraph()
        }
    }
    
    private func stopGraphUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateGraph() {
        withAnimation(.easeInOut(duration: 0.5)) {
            // 🆕 실시간 구간별 비정상 시간 사용
            let abnormalTimeForLast10Seconds = viewModel.currentIntervalAbnormalTime
            
            // 그래프에 데이터 추가
            viewModel.graphDataModel.addDataPoint(abnormalTimeForLast10Seconds)
            
            // 🆕 다음 구간을 위해 초기화
            viewModel.resetCurrentInterval()
            
            print("📊 그래프 업데이트: 비정상 시간 = \(String(format: "%.1f", abnormalTimeForLast10Seconds))초")
        }
    }
}

private struct LineChartView: View {
    @ObservedObject var dataModel: DataModel

    var body: some View {
        Chart {
            ForEach(Array(dataModel.dataPoints.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Index", index),
                    y: .value("Value", value)
                )
                .foregroundStyle(Color(red: 142/255, green: 120/255, blue: 255/255))
                .interpolationMethod(.catmullRom) // 🆕 부드러운 곡선
            }
        }
        .chartYScale(domain: 0...10) // 🆕 0~10초 범위로 수정
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let index = value.as(Int.self) {
                        Text("")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 2.5, 5, 7.5, 10]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let seconds = value.as(Double.self) {
                        Text("\(Int(seconds))s")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
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
