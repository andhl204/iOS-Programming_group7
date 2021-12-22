import SwiftUI
import Kingfisher


// 클릭했을 때 나오는 뷰
struct ModalView: View {
    @Binding var selectedPhoto: Result
    @Binding var showModal: Bool

    var body: some View {
        // 헤더
        ModalTopView(showModal: $showModal, name: selectedPhoto.user.name)
        Spacer()
        // 이미지
        KFImage(URL(string: selectedPhoto.urls.regular)!)
            .resizable()
            .aspectRatio(contentMode: .fit)
        Spacer()
        // 아래 왼쪽에 i 버튼, 클릭했을 때 나오는 뷰는 구현하지 않았습니다
        ModalFooterView()
            .padding(.bottom, 10) // yejinfix
            .padding(.leading, 15)
    }
}

struct ModalTopView: View {
    @Binding var showModal: Bool
    var name: String
    
    var body: some View {
        HStack {
            // x 버튼
            Button(action: {
                showModal = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("dark color"))
            }
            .padding(.top, 10)
            .padding(.bottom, 5)
            .padding(.leading, 15)
            Spacer()
            // 업로드한 사람 이름
            Text(name)
            .font(.system(size:15))
            .padding(.top, 10)
            .padding(.bottom, 5)
            Spacer()
            // 공유 버튼(기능 없음)
            Image(systemName: "square.and.arrow.up")
            .padding(.top, 10)
            .padding(.bottom, 5)
            .padding(.trailing, 15)
        }
    }
}

struct ModalFooterView: View {
    var body: some View {
        HStack {
            Image(systemName: "info.circle")
            Spacer()
        }
    }
}

struct ModalSwipeView: View {
    @ObservedObject var program = Program.shared
    
    var body: some View{
        ModalView(selectedPhoto: $program.selectedPhoto, showModal: $program.showModal)
            // 스와이프 기능
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onEnded({ value in
                        // 다음 사진으로 넘겼을 때
                        if value.translation.width < 0 {
                            // 마지막 사진일 경우
                            if program.selectedPhotoNum >= program.photoItems.count - 1 {
                                return
                            } else {
                                program.selectedPhotoNum += 1
                                program.selectedPhoto = program.photoItems[program.selectedPhotoNum]
                            }
                        }
                        // 이전 사진으로 넘겼을 때
                        if value.translation.width > 0 {
                            // 첫 사진일 경우
                            if program.selectedPhotoNum == 0 {
                                return
                            } else {
                                program.selectedPhotoNum -= 1
                                program.selectedPhoto = program.photoItems[program.selectedPhotoNum]
                            }
                        }
                    }
                )
            )
    }
}

struct SearchModalSwipeView: View{
    @ObservedObject var program = Program.shared
    
    var body: some View{
        ModalView(selectedPhoto: $program.selectedPhoto, showModal: $program.showModal)
        // 스와이프 기능
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded({ value in
                    // 다음 사진으로 넘겼을 때
                    if value.translation.width < 0 {
                        // 마지막 사진일 경우
                        if program.selectedPhotoNum >= program.searchedItems.count - 1 {
                            return
                        } else {
                            program.selectedPhotoNum += 1
                            program.selectedPhoto = program.searchedItems[program.selectedPhotoNum]
                        }
                    }
                    // 이전 사진으로 넘겼을 때
                    if value.translation.width > 0 {
                        // 첫 사진일 경우
                        if program.selectedPhotoNum == 0 {
                            return
                        } else {
                            program.selectedPhotoNum -= 1
                            program.selectedPhoto = program.searchedItems[program.selectedPhotoNum]
                        }
                    }
                }
            )
        )
    }
}
