import SwiftUI
import Kingfisher

struct PhotoListView: View {
    @ObservedObject var program = Program.shared
    
    // 메인 화면의 사진 리스트
    var body: some View {
        List(0..<program.photoItems.count, id: \.self) { item in
            ZStack(alignment: .bottomLeading){
                KFImage(URL(string: program.photoItems[item].urls.regular)!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .onTapGesture {
                        // 클릭했을 때 모달 뜨게 하기
                        program.selectedPhoto = program.photoItems[item]
                        program.selectedPhotoNum = item
                        program.showModal = true
                    }
                    .onAppear{
                        if item == program.pageNum * 10 - 6 {
                            // 사진 로딩 시간을 고려해서 마지막 사진이 나타나기 전에 다음 10장의 사진을 가져오도록 했습니다.
                            program.fetchPhoto()
                        }
                    }
                // 사진 업로드한 사람 이름
                Text(program.photoItems[item].user.name)
                    .font(.system(size:12))
                    .foregroundColor(.white)
                    .padding(.bottom, 12)
                    .padding(.leading, 12)
            }.listRowInsets(EdgeInsets())
        }
    }
}

struct SearchListView:View{
    @ObservedObject var program = Program.shared
    
    let columns = [GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 0)]
    
    // 검색 화면의 사진들을 그리드를 이용하여 두 column으로 나타나게 함
    var body: some View{
        GeometryReader{ metrics in // 사진의 가로, 세로 길이를 디바이스에 따라 변경되도록 하기 위함
            ScrollView{
                LazyVGrid(columns: columns, spacing: 0){
                    ForEach(0..<program.searchedItems.count, id: \.self) { item in
                        ZStack(alignment: .bottomLeading){
                            KFImage(URL(string: program.searchedItems[item].urls.regular)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                // 사진들의 세로 길이를 맞추기 위해 목록에는 정사각형 크기의 프레임에 맞는 부분만 나타나게 함
                                .frame(width: metrics.size.width * 0.5, height: metrics.size.width * 0.5) // 스크린 가로 길이의 절반을 가로 세로 길이로 만듦
                                .clipped()
                                .onTapGesture {
                                    // 클릭했을 때 모달 뜨게 하기
                                    program.selectedPhoto = program.searchedItems[item]
                                    program.selectedPhotoNum = item
                                    program.showModal = true
                                }
                                // 다음 사진들을 받아오기 위함
                                .onAppear{
                                    if item == program.searchPageNum * 10 - 6 {
                                        program.fetchSearchedPhoto()
                                    }
                                }
                            // 사진 업로드한사람 이름
                            Text(program.searchedItems[item].user.name)
                                .font(.system(size:12))
                                .foregroundColor(.white)
                                .padding(.bottom, 12)
                                .padding(.leading, 12)
                        }.listRowInsets(EdgeInsets())
                    }
                }
            }
        }
    }
}
