import Foundation

public class IOComponent: NSObject {
    private(set) var mixer:AVMixer

    init(mixer: AVMixer) {
        self.mixer = mixer
    }
}