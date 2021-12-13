//
//  ContentView.swift
//  Unsplash
//
//  Created by SWY on 2021/12/13.
//

import SwiftUI
import Kingfisher


struct ContentView: View {
    @State var photoItems: [Result] = []  // MediaResponse에서 정의
    @State var searchedItems: [Result] = []  // 분리된 search tab에서 사용할 사진 리스트
    @State var pageNum: Int = 0  // json 받아올 페이지 넘버
    @State var showModal = false  // Bullseye에서 PointsView와 동일한 로직입니다
    @State var selectedPhoto: Result = Result(id: "", urls: URLS(regular: ""), user: Username(name: "")) // 선택된 사진
    @State var selectedPhotoNum: Int = 0  // 선택된 사진의 index
    @State var searchInput = ""  // 검색 인풋
    
    init() {
        // 스크롤 안보이게 함
        UITableView.appearance().showsVerticalScrollIndicator = false
        UITabBar.appearance().backgroundColor = .black
    }

    var body: some View {
        TabView {
            // 기본 탭
            VStack {
                Text("Unsplash")
                    .font(.headline)
                    .bold()
                List(0..<photoItems.count, id: \.self) {
                    // 사진들을 리스트처럼 나타냄
                    item in
                        ZStack(alignment: .bottomLeading){
                            // 이미지 url을 사진으로 변환하는 방식이 복잡해서 Kingfisher 오픈소스를 사용했고, KFImage를 이용했습니다.. 이부분도 더 나은 방법이 있다면 바꿔주세요
                            KFImage(URL(string: photoItems[item].urls.regular)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    // 클릭했을 때 모달 뜨게 하기
                                    self.selectedPhoto = photoItems[item]
                                    self.selectedPhotoNum = item
                                    self.showModal = true
                                }
                                .onAppear{if item == self.pageNum * 10 - 4 {
                                    // 기존의 문제를 해결하기 위해 제일 마지막에서 5번째 사진이 화면에 보일 때 다음 10장의 사진을 가져오도록 했습니다. 사진 로딩 시간을 고려해서 마지막 사진이 나타나기 전에 새로 사진을 가져오도록 했어요
                                    fetchPhoto()
                                  }
                            }
                            // 사진 업로드한사람 이름
                            Text(photoItems[item].user.name)
                                .foregroundColor(.white)
                        }.listRowInsets(EdgeInsets())
                }.listStyle(.plain)
                .fullScreenCover(isPresented: $showModal) {
                    // 사진 클릭했을 때 모달처럼 나오는 뷰
                    ModalView(selectedPhoto: $selectedPhoto, showModal: $showModal)
                        // 스와이프 기능
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onEnded({ value in
                                    // 다음 사진으로 넘겼을 때
                                    if value.translation.width < 0 {
                                        // 마지막 사진일 경우
                                        if self.selectedPhotoNum >= self.photoItems.count - 1 {
                                            return
                                        } else {
                                            self.selectedPhotoNum += 1
                                            self.selectedPhoto = photoItems[selectedPhotoNum]
                                        }
                                    }
                                    // 이전 사진으로 넘겼을 때
                                    if value.translation.width > 0 {
                                        // 첫 사진일 경우
                                        if self.selectedPhotoNum == 0 {
                                            return
                                        } else {
                                            self.selectedPhotoNum -= 1
                                            self.selectedPhoto = photoItems[selectedPhotoNum]
                                        }
                                    }
                                }
                            )
                        )
                }
            }
                .tabItem {
                    Image(systemName: "photo.fill")
                        .foregroundColor(Color(UIColor.systemGray5))
                }
            VStack {
                // 검색 탭
                // 검색 바
                HStack {
                    TextField("Search", text: $searchInput)
                    Spacer()
                    Button(action: {
                        searchedItems = []
                        pageNum = 0
                        fetchSearchedPhoto()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                List(0..<searchedItems.count, id: \.self) {
                    // 사진들을 리스트처럼 나타냄
                    item in
                        ZStack(alignment: .bottomLeading){
                            KFImage(URL(string: searchedItems[item].urls.regular)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .onTapGesture {
                                    // 클릭했을 때 모달 뜨게 하기
                                    self.selectedPhoto = searchedItems[item]
                                    self.selectedPhotoNum = item
                                    self.showModal = true
                                }
                                .onAppear{if item == self.pageNum * 10 - 3 {
                                    // 기존의 문제를 해결하기 위해 제일 마지막에서 4번째 사진이 화면에 보일 때 다음 10장의 사진을 가져오도록 했습니다. 사진 로딩 시간을 고려해서 마지막 사진이 나타나기 전에 새로 사진을 가져오도록 했어요
                                    fetchSearchedPhoto()
                                  }
                            }
                            // 사진 업로드한사람 이름
                            Text(searchedItems[item].user.name)
                                .foregroundColor(.white)
                        }.listRowInsets(EdgeInsets())
                }.listStyle(.plain)
                .fullScreenCover(isPresented: $showModal) {
                    // 사진 클릭했을 때 모달처럼 나오는 뷰
                    ModalView(selectedPhoto: $selectedPhoto, showModal: $showModal)
                        // 스와이프 기능
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onEnded({ value in
                                    // 다음 사진으로 넘겼을 때
                                    if value.translation.width < 0 {
                                        // 마지막 사진일 경우
                                        if self.selectedPhotoNum >= self.searchedItems.count - 1 {
                                            return
                                        } else {
                                            self.selectedPhotoNum += 1
                                            self.selectedPhoto = searchedItems[selectedPhotoNum]
                                        }
                                    }
                                    // 이전 사진으로 넘겼을 때
                                    if value.translation.width > 0 {
                                        // 첫 사진일 경우
                                        if self.selectedPhotoNum == 0 {
                                            return
                                        } else {
                                            self.selectedPhotoNum -= 1
                                            self.selectedPhoto = searchedItems[selectedPhotoNum]
                                        }
                                    }
                                }
                            )
                        )
                }
                    
            }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(UIColor.systemGray5))
                }
        }
        .accentColor(.white)
        .onAppear(perform: fetchPhoto)
    }
    
    // 처음 앱을 켰을 때 실행되는 함수
    func fetchPhoto() {
        self.pageNum += 1
        print(pageNum)
        guard let url =  URL(string: "https://api.unsplash.com/photos?page=\(pageNum)&client_id=bMlyFGmZbPG596sYN9M7zpigQ7SD3B0stTg_HTvRjz8") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode([Result].self, from: data)
                DispatchQueue.main.async {
                    self.photoItems += jsonResult
                    
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    // 사진을 검색하면 실행되는 함수
    func fetchSearchedPhoto() {
        self.pageNum += 1
        print(pageNum)
        guard let url =  URL(string: "https://api.unsplash.com/search/photos?page=\(pageNum)&query=\(self.searchInput)&client_id=bMlyFGmZbPG596sYN9M7zpigQ7SD3B0stTg_HTvRjz8") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(MediaResponse.self, from: data)
                DispatchQueue.main.async {
                    self.searchedItems += jsonResult.results
                    
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

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
        // 아래 왼쪽에 i 버튼이 있던데 클릭했을 때 나오는 뷰는 구현하지 않았습니다
        ModalFooterView()
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
            }
            Spacer()
            // 업로드한 사람 이름
            Text(name)
            Spacer()
            // 공유 버튼(기능 없음)
            Image(systemName: "square.and.arrow.up")
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
