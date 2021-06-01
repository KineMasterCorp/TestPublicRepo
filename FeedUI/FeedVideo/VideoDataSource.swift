//
//  VideoDataSource.swift
//  SeamlessSwitching
//
//  Created by JT3 on 2021/05/28.
//

import AVFoundation

class VideoDataInfo {
    enum LoadState: Int {
        case none = 0, loading, loaded
    }
    
    let title: String
    let tags: [String]
    let videoURL: URL
    let poster: String
    let category: String
    
    init(title: String, tags: [String], videoURL: URL, poster: String, category: String) {
        self.title = title
        self.tags = tags
        self.videoURL = videoURL
        self.poster = poster
        self.category = category
    }

    var asset: AVURLAsset?
    var loadState: LoadState = .none
    
    func load() {
        if loadState == .none {
            asset = AVURLAsset(url: videoURL)
            loadState = .loading
            let keys = ["playable","tracks","duration"]
            let loadStartTick = DispatchTime.now().uptimeNanoseconds
            asset?.loadValuesAsynchronously(forKeys: keys) { [weak self] in
                guard let self = self else { return }
                for key in keys {
                    let status = self.asset?.statusOfValue(forKey: key, error: nil)
                    if status == .failed {
                        NSLog("loading asset has failed. ")
                        return
                    }
                }
                let loadTime = Int(DispatchTime.now().uptimeNanoseconds - loadStartTick)
                NSLog("loading completed, elapsed: \(loadTime)")
                self.loadState = .loaded
            }
        } else {
            NSLog("load: already loading.. state: \(loadState.rawValue)")
        }
    }
}

class VideoDataSource {
    var videos: [VideoDataInfo]
    
    init(videos: [VideoDataInfo]) {
        self.videos = videos
    }
    
    var dataCount: Int {
        videos.count
    }
    
    func prepareSource(for index: Int) {
        videos[index].load()
    }
    
    func getVideo(of index: Int) -> AVURLAsset? {
        if videos[index].loadState == .none {
            videos[index].load()
        }
        return videos[index].asset
    }
    
    func getPhoto(of index: Int) -> Photo? {
        let photo = Photo(caption: videos[index].title, category: videos[index].category, image: videos[index].poster)
        return photo
    }
    
    static func allVideos() -> VideoDataSource {
        return VideoDataSource(videos: [
            VideoDataInfo(title: "화려한 댄스 타임", tags: ["인스타그램", "틱톡"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac66bc3330840317c277fa/1t0g4ZL0dL9Ij8QtNgBFM7BdwNb.mp4")!,
                          poster: "1t0g4VLxJqxFX1u1U8yxTN4L7kB",
                          category: "예능"),
            VideoDataInfo(title: "다이나믹 오프너 인트로", tags: ["유튜브", "다이나믹", "오프너"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac5b2a3330840317c277f0/1t0a4lKmBhe0LayPROW6MN1eoAU.mp4")!,
                          poster: "1t0a4oZlom8FwedLVilXlZLG6n1",
                          category: "인트로"),
            VideoDataInfo(title: "나의 데일리 브이로그", tags: ["유튜브", "데일리", "브이로그"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac5c303330840317c277f1/1t0qsmkUFZ9k5sJDa47jZ2EMy1W.mp4")!,
                          poster: "1t0qsnyl07h9IZYotZouJXdxsG7",
                          category: "브이로그"),
            VideoDataInfo(title: "파이어 타이틀 인트로", tags: ["유튜브", "파이어", "인트로", "불"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac5ce73330840317c277f2/1t0ayKzbcSZLIdljGVUXrv1LDQD.mp4")!,
                          poster: "1t0ayTcLUScBNHuM4YkZ9viSt9T",
                          category: "인트로"),
            VideoDataInfo(title: "폭발 텍스트 인트로", tags: ["폭발", "인트로", "유튜브"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac5d573330840317c277f3/1t0s1YXhEH1NfUUJ7bj07sR7367.mp4")!,
                          poster: "1t0bCGMCoJkHQfnbUHYUCT7klhV",
                          category: "인트로"),
            VideoDataInfo(title: "베스트 포토", tags: ["인스타그램", "릴스", "포토"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac5e723330840317c277f4/1t3sUCfJaEW5fLDZxDd35Z7JGq9.mp4")!,
                          poster: "1t0bloCu0cPacKyhpuVc9vbKg9c",
                          category: "비트"),
            VideoDataInfo(title: "시네마틱 필름", tags: ["유튜브", "인트로", "브이로그"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac5efa3330840317c277f5/1t0c2udETbKNMfTdtemVL1YJh3e.mp4")!,
                          poster: "1t0c2yZXFYzqqLhDkV99iLEwo0h",
                          category: "브이로그"),
            VideoDataInfo(title: "구독 인트로", tags: ["유튜브", "구독", "인트로"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac601a3330840317c277f6/1t0cd8UUbsr0pormCLGqBy2zjcC.mp4")!,
                          poster: "1t0cdAR1RFAcXUGo25nj39XcVgT",
                          category: "인트로"),
            VideoDataInfo(title: "시간 여행", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac60f83330840317c277f8/1t3sWpr1MlejkZ42yT1gYpB2AIf.mp4")!,
                          poster: "1t0d50MULbNM4WNFaEbOb2oolzT",
                          category: "비트"),
            VideoDataInfo(title: "오늘의 점심 메뉴는?", tags: ["인스타그램", "점심", "메뉴"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60ac620f3330840317c277f9/1t0de3fFqxOXSRTMAvAnctJIR6m.mp4")!,
                          poster: "1t0de5MhZoyIukKZ7N5sx06kQQ9",
                          category: "예능"),
            VideoDataInfo(title: "나의 즐겨찾기", tags: ["인스타그램", "틱톡"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/607e4d8733308402c8b63fbc/1rPubtJZPUzIGAwGosMaC82XZwJ.mp4")!,
                          poster: "1rPubvv16iiA05pUHMCt1YObCfu",
                          category: "심플"),
            VideoDataInfo(title: "러블리 채널 인트로", tags: ["유튜브", "다이나믹", "오프너"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/607e58b733308402c8b63fc6/1rQ0Pt2wtwarA5gbAcxPutymFw6.mp4")!,
                          poster: "1rQ0PsFK7dLRz42xULwkY14ZX4q",
                          category: "인트로"),
            VideoDataInfo(title: "여행 사진, 단 하나뿐인 엽서로", tags: ["유튜브", "데일리", "브이로그"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/607e487e33308402c8b63fb9/1rPs0AgufGanZUUImg6mTqLikYo.mp4")!,
                          poster: "1rPs0Fvt0nWRTgSocarssUkoeN7",
                          category: "심플"),
            VideoDataInfo(title: "스토리 포토앨범", tags: ["유튜브", "파이어", "인트로", "불"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/607e554233308402c8b63fc2/1rPycfA9vXvJHiwPUjbwqEPdqqy.mp4")!,
                          poster: "1rPyce4DFj1fDU2aT3nChwhkHT6",
                          category: "브이로그"),
            VideoDataInfo(title: "신비의 퍼즐", tags: ["폭발", "인트로", "유튜브"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/604df74301071402c972bb49/1qp3LwuU3vNykWyYjSKmqxe7qnD.mp4")!,
                          poster: "1qp3LsQKy1FLvwcjtTkehaxEl9K",
                          category: "예능"),
//            VideoDataInfo(title: "내가 빛나는 순간", tags: ["인스타그램", "릴스", "포토"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/604df00201071402c972bb2f/1qp1ZaAWFFy5KbkJUxAk2APENlg.mp4")!,
//                          poster: "1qp1Zbs8P9V8TcO3dhuSWzPphOw",
//                          category: "비트"),
            VideoDataInfo(title: "레인보우", tags: ["유튜브", "인트로", "브이로그"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/604df55701071402c972bb45/1qp3AeYWAbH9kn26SvRVMSWvBT2.mp4")!,
                          poster: "1qp3Acs04QMn0oxOmVAaTRNwhsN",
                          category: "인트로"),
            VideoDataInfo(title: "다이어리 꾸미기", tags: ["유튜브", "구독", "인트로"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/604df48a01071402c972bb41/1qp2VHAKaNLNYpURVdZ3dj08bF1.mp4")!,
                          poster: "1qp2VMG3ownGvdn17S4qYoqIZAH",
                          category: "인트로"),
            
            
            VideoDataInfo(title: "나의 청춘 기록", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/6087748233308402c8b63fcb/1rjpELf6SyxflmsOM8oBMZjOtwT.mp4")!,
                          poster: "1rjpEYJ0oZNNbkZ8OugMCtabwKW",
                          category: "심플"),
            
            VideoDataInfo(title: "거울아 거울아", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/604df35b01071402c972bb3c/1rmprEyi0Frv99noAJC2E0jGcJk.mp4")!,
                          poster: "1rmprMBNAQXr8oiOG0Dx5lHIB1c",
                          category: "예능"),
            
            VideoDataInfo(title: "동물 스케치", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60a1f83e33308402c8b63ff4/1seKOTFeUBZNxd8sEflEnVFVata.mp4")!,
                          poster: "1rmz3vIDf9maPExwHGRGEKdoRbk",
                          category: "레트로"),
            
            VideoDataInfo(title: "나만의 컬러 : 겨울", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/604e975001071402c972bb61/1rp0cILOCz1OIHLs4OCgavi7imN.mp4")!,
                          poster: "1rp0cKsUPutcHE8ZPJIaWm3CFWF",
                          category: "심플"),
            
            VideoDataInfo(title: "포토 더블 스크린", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/6090a91533308402c8b63fe1/1s3F8PPmQd6d9eCgyQ5W2h2o3l4.mp4")!,
                          poster: "1s3F8SEX2K8OYMkwxw5PMQXrT02",
                          category: "인트로"),
            
            VideoDataInfo(title: "구독과 좋아요 알림설정까지", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/604e04d301071402c972bb4c/1qp3VYVCKDy4JOkkpTlwZ8OIfOC.mp4")!,
                          poster: "1qp3VgsgQZ6FbVzxRSewOl2ktCh",
                          category: "레트로"),
            
            VideoDataInfo(title: "재즈 비트", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/6090aa8533308402c8b63fe2/1s3Fsk5xPoJdfHhBnoyaa3KMgTC.mp4")!,
                          poster: "1s3FsjCMygG0Z2ZNiAQ2qfXBpSh",
                          category: "비트"),
            
            VideoDataInfo(title: "비디오 캘린더", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/6090ab0733308402c8b63fe3/1s3G9Cj0IKp2rc2jByIAOzxXLuO.mp4")!,
                          poster: "1s3G9DtVhFewyPALJomJ0FExvvO",
                          category: "심플"),
            
            VideoDataInfo(title: "인 블루", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/6090ab6733308402c8b63fe4/1s3GLBHh7EsU2uijlJNka5arcRF.mp4")!,
                          poster: "1s3GL8lcCJg7UxWtqQAYoRmq3rH",
                          category: "브이로그"),
            
            VideoDataInfo(title: "심플 블랙", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/6090abc433308402c8b63fe5/1s3GWliIjer8UlSLiOv3AtWDM2u.mp4")!,
                          poster: "1s3GWnCzJAFHXrHeDeoh23u33SP",
                          category: "심플"),
            
            VideoDataInfo(title: "CITY OF LOVE", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/60a1f71733308402c8b63ff3/1seJnUdaawcOibQhZWwuznl6Ydf.mp4")!,
                          poster: "1seJnZ6TRv54soqkrx6VvLYKN3F",
                          category: "뮤직 비디오"),
            
            VideoDataInfo(title: "나만의 추억 저장 방법, 포토북", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/6087715033308402c8b63fca/1s3HsMFTxRGC0YZVfumCaTSZyWb.mp4")!,
                          poster: "1s3HsO95X5qEHxkhYvVzSNCE9VV",
                          category: "뮤직 비디오"),
            
            VideoDataInfo(title: "봄 청춘", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/609a3ecb33308402c8b63fef/1sNmKQsMNqGRWUhdugbs14klosO.mp4")!,
                          poster: "1sNmKQgXZSadhOzB1PcF0byTt6M",
                          category: "뮤직 비디오"),
            
            VideoDataInfo(title: "나랑 별 보러 가지 않을래?", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/609a231233308402c8b63fe9/1sNXwayep9s4suzxcC57iKOfHP6.mp4")!,
                          poster: "1sNXwaaVIXfb0pFXC3hfjMqXaw3",
                          category: "뮤직 비디오"),
            
            VideoDataInfo(title: "그린 하프톤 매거진", tags: ["인스타그램", "릴스", "여행", "시간"], videoURL: URL(string:"https://cdn-project-feed.kinemasters.com/projects/609a23c333308402c8b63fea/1sNYIgYnLN5W6KeaHnzTUTNmgjH.mp4")!,
                          poster: "1sNYIdmWnLkIi1PNMuISCMEtGVE",
                          category: "뮤직 비디오"),
        ])
    }
}
