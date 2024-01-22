//
//  SearchDestinationView.swift
//  BaroMap
//
//  Created by 이소리 on 11/15/23.
//

import SwiftUI
import ComposableArchitecture
import Moya

struct SearchDestinationView: View {
    let store: StoreOf<SearchDestinationStore>
    
    @State var destination: String = "" // 사용자가 입력하는 값(서버에 전달)
    @State var places: [PlaceInfo] = [ // 최대 10개까지
        PlaceInfo(name: "세종대학교", address: "서울 광진구 능동로 209 세종대학교", distance: 800),
        PlaceInfo(name: "세종대학교광개토관", address: "서울 광진구 능동로 209", distance: 1200),
        PlaceInfo(name: "세종대학교 정문", address: "서울 광진구 군자동", distance: 1400),
        PlaceInfo(name: "세종대학교 대양홀", address: "서울 광진구 능동로 209 세종대학교", distance: 20000),
    ]


//    @EnvironmentObject var sharedModel: SharedModel
//    var placeholder: String = "장소"
//    var data: Data
//    var place: Place

    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                    VStack(alignment: .leading) {
                        HStack {
                            TextField("검색어 입력", text: $destination) // 비어있으면 검색어 입력, 값이 있으면 그 값 불러오기
                            
                            Spacer()
                            
                            if !destination.isEmpty {
                                Button(action: {
                                    self.destination = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.shapeQuaternaryColor) // shapeQuaternaryColor
                                }
                                .buttonStyle(.borderless) 
                            } else {
                                EmptyView()
                            }
                        }
                        .asTextField()

                        ScrollView {
                            HStack {
                                Text("검색 결과") // 안에 있는 게 더 자연스러움
                                    .bold()
                                    .padding(5)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 10) {
                                ForEach(places) { place in
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(height: 66)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.shapeColor)
                                        .shadow(radius: 1) // modifier 적용
                                        .padding(1) // infinity 때문에 살짝 잘려서
                                        .overlay( // -> frame 제거 못함(실패)
                                            HStack {
                                                VStack {
                                                    Image(systemName: "mappin.circle.fill")
                                                        .foregroundColor(.keyColor)
                                                        .font(.title3)
                                                    
                                                    Spacer()
                                                    
                                                    Text(formatDistance(place.distance))
                                                        .foregroundColor(.keyTertiaryColor)
                                                        .font(.caption)
                                                }
                                                VStack(alignment: .leading) {
                                                    Text(highlightMatchedText(place.name, destination))
                                                        .foregroundColor(.textColor)
                                                        .font(.subheadline)
                                                        .bold()
                                                    
                                                    Spacer()
                                                    
                                                    Text(highlightMatchedText(place.address, destination))
                                                        .foregroundColor(.textQuaternaryColor)
                                                        .font(.footnote)
                                                        .lineLimit(nil)
                                                }
                                                
                                                Spacer()
                                                
                                                // FIXME: 프로퍼티에 값 전달 안 됨
                                                NavigationStack {
                                                    NavigationLink(
                                                        destination: MapSearchResultView(store: self.store, locationName: place.name, locationAddress: place.address),
                                                        isActive: viewStore.binding(
                                                            get: \.isDetailViewActive,
                                                            send: SearchDestinationStore.Action.toggleDetailView
                                                        )
                                                    ) {
                                                        Text("지도 보기") // 선택시 locationName, locationAddress 전달
                                                            .font(.footnote)
                                                            .foregroundColor(.keyColor)
                                                    }
                                                }
                                            }
                                        )
                                }
                            }
                        }
                    }
                    .padding()
                    .navigationTitle("\(Destination.shared.placeholder) 검색") // "도착지"가 전달이 안 됨
                // back button -> keyColor
                    .toolbar {
                        Button(action: {
                            viewStore.send(.cancelButtonTapped)
                        }, label: {
                            Text("닫기")
                                .foregroundColor(.keyColor) // keyColor
                        })
                }
            }
        }
    }
}

func formatDistance(_ meters: Int) -> String {
    if meters < 1000 {
        return "\(meters)m"
    } else {
        let kilometers = Double(meters) / 1000.0
        return "\(String(format: "%.1f", kilometers))km"
    }
}

struct PlaceInfo: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let distance: Int
}

// FIXME: red -> keyColor
func highlightMatchedText(_ originalText: String, _ userInput: String) -> AttributedString {
    let attributedString = NSMutableAttributedString(string: originalText)
    let highlightedRange = originalText.lowercased().range(of: userInput.lowercased())

    if let range = highlightedRange {
        let nsRange = NSRange(range, in: originalText)
        attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: nsRange) // value: Any, Any에 Color 타입은 할당이 안 됨, UIColor는 됨. UIColor Color 차이? color->uicolor로 변경해야할까 다른 방법이 있나 더 찾아봐야 할 듯
    }

    return AttributedString(attributedString)
}

//#Preview {
//    SearchDestinationView()
//}
