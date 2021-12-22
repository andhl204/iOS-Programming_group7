import SwiftUI
import Kingfisher
import CoreMedia

struct ContentView: View {
    @ObservedObject var program = Program.shared
    @State private var selected = 0
    
    var body: some View {

        ZStack(alignment: Alignment.bottom) {
            TabView(selection: $selected) {
                VStack {
                    Text("Unsplash")
                        .background(Color("white color"))
                        .foregroundColor(Color("dark color"))
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        .font(.headline)
                    PhotoListView()
                        .listStyle(.plain)
                        .fullScreenCover(isPresented: $program.showModal) {
                            ModalSwipeView() // 사진 클릭했을 때 모달처럼 나오는 뷰
                        }
                }
                .tabItem {
                    Text("")
                }.tag(0)
                
                // 검색 탭
                VStack (alignment: .center) {
                    HStack (alignment: .center, spacing:0) {// 검색 바
                        TextField("Search photos, collections, users", text: $program.searchInput)
                            .padding(.leading, 20)
                            .padding(.top, 7)
                            .padding(.bottom, 7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8.0)
                                    .strokeBorder(.gray, lineWidth: 1.5)
                                    .padding(.leading, 10)
                                    .padding(.trailing, 10)
                            )
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            .padding(.leading, 15)
                        
                        Spacer()
                        // 검색 버튼
                        Button(action: {
                            // 기존에 검색되었던 사진 목록을 비움
                            program.searchedItems = []
                            program.searchPageNum = 0
                            program.fetchSearchedPhoto()
                        })
                        {
                            Image(systemName: "magnifyingglass")
                                .padding(.top, 10)
                                .padding(.bottom, 5)
                                .padding(.trailing, 22)
                                .accentColor(Color("dark color")) // 검색 돋보기 색
                        }
                    }
                    
                    //검색결과 없을 때 메시지
                    if program.message == false {
                        Spacer()
                        Text ("No Photos")
                            .frame(width: 200, height: 100)
                        Spacer()
                            .font(.title2)
                    }
                    else {}
                    
                    SearchListView()
                        .listStyle(.plain)
                        .fullScreenCover(isPresented: $program.showModal) {
                            SearchModalSwipeView() // 사진 클릭했을 때 모달처럼 나오는 뷰
                        }
                }
                .tabItem {
                    Text("")
                }.tag(1)
                }.accentColor(Color("dark color"))
                HStack {
                    Button(action: { self.selected = 0 } ) {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .frame(width: 26.0, height: 22.0)
                            .foregroundColor(self.selected != 0 ? Color(UIColor.systemGray5) : Color("dark color"))
                            .padding(.bottom, 12)
                    }
                    .padding(.leading, 90)
                    Spacer()
                    Button(action: { self.selected = 1 } ) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 22.0, height: 22.0)
                            .foregroundColor(self.selected != 1 ? Color(UIColor.systemGray5) : Color("dark color"))
                            .padding(.bottom, 12)
                    }
                    .padding(.trailing, 90)
                }
                .onAppear(perform: program.fetchPhoto)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //ContentView()
            
        Group {
            ContentView()
                .previewLayout(.fixed(width: 320, height: 568))
            ContentView()
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 320, height: 568))
        }
    }
}

