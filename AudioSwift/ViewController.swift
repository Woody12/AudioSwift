//
//  ViewController.swift
//  AudioSwift
//
//  Created by Woody Lee on 11/3/15.
//  Copyright © 2015 Woody Lee. All rights reserved.
//

import UIKit
import AVFoundation

private let kPlayerStopNotification = "PlayerStopNotification"
private let kRecorderStopNotification = "RecorderStopNotification"

private var audioPlayer: AVAudioPlayer?
private var audioRecorder: AVAudioRecorder?
private var asset: AVURLAsset?
private var audioURL: NSURL?

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioPlayerStop:", name: kPlayerStopNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioRecorderStop:", name: kRecorderStopNotification, object: nil)
		
		loadAudio(NSBundle.mainBundle().URLForResource("Let It Go", withExtension: "mp3"))
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func recordClick(sender: AnyObject) {
		
		print("long gesture")
		
		if let _ = audioRecorder,
			_ = audioRecorder?.recording {
				stopRecorder()
		}
	
		NSNotificationCenter.defaultCenter().postNotificationName(kRecorderStopNotification, object: nil)
		record()
		
	}

	@IBAction func playClick(sender: AnyObject) {
	
		print("play")
		
		if let _ = audioPlayer,
			_ = audioPlayer?.playing {
				stopPlayer()
		}
		NSNotificationCenter.defaultCenter().postNotificationName(kPlayerStopNotification, object: nil)
		play()
	
	}
	
	func audioPlayerStop(notification: NSNotification) {
		
		stopPlayer()
	}
	
	func audioRecorderStop(notification: NSNotification) {
		
		stopRecorder()
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().postNotificationName(kPlayerStopNotification, object: nil)
		NSNotificationCenter.defaultCenter().postNotificationName(kRecorderStopNotification, object: nil)
	}
}

extension ViewController {
	
	func loadAudio(contentURL: NSURL?) {
		
		if let contentURL = contentURL {
			
			if audioURL != contentURL {
				
				audioURL = contentURL
				asset = AVURLAsset(URL: audioURL!)
				
				if let duration = asset?.duration {
					
					let seconds = CMTimeGetSeconds(duration)
					
					var error: NSError? = nil
					if seconds > 70 {
						error = NSError(domain: "A voice audio shouldn't last longer than 60 seconds", code: 300, userInfo: nil)
						
					}
					print("error: \(error?.localizedDescription)")
				}
				
			}
			
		}
		
	}

}

extension ViewController {

	// MARK: Play Audio
	
	func prepareToPlay() {
		
		if let player = audioPlayer {
			
			player.stop()
			audioPlayer = nil
		}
		
		// Load Player with throwability
		do {
			audioPlayer = try AVAudioPlayer(contentsOfURL: audioURL!)
			audioPlayer?.delegate = self
			audioPlayer?.prepareToPlay()
		} catch {
			print("Something went wrong!")
		}
		
	}
	
	func play() {
		
		if let _ = audioPlayer {
			stopPlayer()
			audioPlayer = nil
			
		}
		else {
			prepareToPlay()
			
			if let player = audioPlayer {
				if player.playing == false {
					player.play()
				}
				
			}
			
		}
	
	}
	
	func pausePlayer() {
		
		if let player = audioPlayer {
			if player.playing == true {
				player.pause()
			}

		}
	}
	
	func stopPlayer() {
		
		if let player = audioPlayer {
			if player.playing == true {
				player.stop()
				player.currentTime = 0
			}
			
		}
	}
}

extension ViewController {
	
	// MARK: Record Audio
	
	func prepareToRecord() {
		
		if let recorder = audioRecorder {
			
			recorder.stop()
			audioPlayer = nil
		}
		
		// Load Player with throwability
		do {
			audioRecorder = try AVAudioRecorder(URL: audioURL!, settings: nil)
			audioRecorder?.delegate = self
			audioRecorder?.prepareToRecord()
		} catch {
			print("Something went wrong!")
		}
		
	}
	
	func record() {
		
		if let _ = audioRecorder {
			stopRecorder()
			audioRecorder = nil
			
		}
		else {
			prepareToRecord()
			
			if let recorder = audioRecorder {
				if recorder.recording == false {
					recorder.record()
				}
				
			}
			
		}
		
	}
	
	func pauseRecorder() {
		
		if let recorder = audioRecorder {
			if recorder.recording == true {
				recorder.pause()
			}
			
		}
	}
	
	func stopRecorder() {
		
		if let recorder = audioRecorder {
			if recorder.recording == true {
				recorder.stop()
			}
			
		}
	}
}

