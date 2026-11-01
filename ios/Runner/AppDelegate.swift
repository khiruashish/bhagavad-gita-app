import Flutter
import MediaPlayer
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "GitaNowPlaying") {
      NowPlaying.shared.attach(messenger: registrar.messenger())
    }
  }
}

/// Lock-screen and Control Centre controls for chapter audio (BackgroundAudio in Dart).
/// The "audio" background mode in Info.plist keeps speech going with the screen locked.
final class NowPlaying {
  static let shared = NowPlaying()
  private var channel: FlutterMethodChannel?

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "gita/audio", binaryMessenger: messenger)
    self.channel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "update":
        self?.update(call.arguments as? [String: Any] ?? [:])
        result(nil)
      case "stop":
        self?.clear()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let center = MPRemoteCommandCenter.shared()
    center.playCommand.addTarget { [weak self] _ in self?.send("play"); return .success }
    center.pauseCommand.addTarget { [weak self] _ in self?.send("pause"); return .success }
    center.togglePlayPauseCommand.addTarget { [weak self] _ in self?.send("toggle"); return .success }
    center.nextTrackCommand.addTarget { [weak self] _ in self?.send("next"); return .success }
    center.previousTrackCommand.addTarget { [weak self] _ in self?.send("previous"); return .success }
    center.stopCommand.addTarget { [weak self] _ in self?.send("stop"); return .success }
  }

  private func update(_ state: [String: Any]) {
    let playing = state["playing"] as? Bool ?? false
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
      MPMediaItemPropertyTitle: state["title"] as? String ?? "",
      MPMediaItemPropertyArtist: state["subtitle"] as? String ?? "",
      MPMediaItemPropertyAlbumTitle: state["album"] as? String ?? "",
      MPNowPlayingInfoPropertyPlaybackRate: playing ? 1.0 : 0.0,
    ]
    if #available(iOS 13.0, *) {
      MPNowPlayingInfoCenter.default().playbackState = playing ? .playing : .paused
    }
    let center = MPRemoteCommandCenter.shared()
    center.nextTrackCommand.isEnabled = state["hasNext"] as? Bool ?? false
    center.previousTrackCommand.isEnabled = state["hasPrevious"] as? Bool ?? false
  }

  private func clear() {
    MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    if #available(iOS 13.0, *) {
      MPNowPlayingInfoCenter.default().playbackState = .stopped
    }
  }

  private func send(_ action: String) {
    channel?.invokeMethod("action", arguments: action)
  }
}
