import AVFoundation

extension AVPlayer {
    static let sharedDecidePlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "decidemp3-14575", withExtension:
                                            "mp3") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
    static let sharedSlashPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "slash", withExtension:
                                            "mp3") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
    static let sharedLosePlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "game-over", withExtension:
                                            "mp3") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
    static let sharedWinPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "success", withExtension:
                                            "mp3") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
    
    func playFromStart() {
        seek(to: .zero)
        play()
    }
    static var bgQueuePlayer = AVQueuePlayer()
    
    static var bgPlayerLooper: AVPlayerLooper!
    
    static func setupBgMusic() {
        guard let url = Bundle.main.url(forResource: "gamemusic",
                                        withExtension: "mp3") else { fatalError("Failed to find sound file.") }
        let item = AVPlayerItem(url: url)
        bgPlayerLooper = AVPlayerLooper(player: bgQueuePlayer, templateItem: item)
    }
}
