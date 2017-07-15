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
private let audioFilename = "audioSwift.caf"

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
		prepareToRecord()
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func recordClick(sender: AnyObject) {
		
		print("long gesture")
		
		//showSelection(sender as! UIButton)
		
		if let recognizer = sender as? UIGestureRecognizer {
			
			if recognizer.state == UIGestureRecognizerState.Began {
				record()
			}
			else if (recognizer.state == UIGestureRecognizerState.Ended) || (recognizer.state == UIGestureRecognizerState.Cancelled) {
				
				if let _ = audioRecorder,
					_ = audioRecorder?.recording {
						NSNotificationCenter.defaultCenter().postNotificationName(kRecorderStopNotification, object: nil)
				}
				
			}
		}
		
	}

	@IBAction func playClick(sender: AnyObject) {
	
		print("play")
		
		showSelection(sender as! UIButton)
		
		if let _ = audioPlayer,
			_ = audioPlayer?.playing {
				showSelection(sender as! UIButton)
				NSNotificationCenter.defaultCenter().postNotificationName(kPlayerStopNotification, object: nil)
		}
		
		play()
	
	}
	
	func showSelection(button: UIButton) {
		
		if button.tag == 0 {
			button.layer.borderColor = UIColor.redColor().CGColor
			button.layer.borderWidth = 2.0
			button.backgroundColor = UIColor.redColor()
			button.tag = 1
		}
		else {
			button.layer.borderColor = UIColor.whiteColor().CGColor
			button.layer.borderWidth = 2.0
			button.backgroundColor = UIColor.whiteColor()
			button.tag = 0
		}
		
	}
	func audioPlayerStop(notification: NSNotification) {
		
		stopPlayer()
	}
	
	func audioRecorderStop(notification: NSNotification) {
		
		stopRecorder()
	}
	
	func createFilePath(fileName: String) -> String {
		
		let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		
		// Convert to NSString since PathComponent is unavailable
		let path = paths[0] as NSString
		return path.stringByAppendingPathComponent(audioFilename)
	}
	
	func fileExist(fileName: String) -> String? {
		
		let path = createFilePath(fileName)
		return (NSFileManager.defaultManager().fileExistsAtPath(path) ? path : nil)
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
					else {
						print("error: \(error?.localizedDescription)")
					}
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
		
		let filePath = fileExist(audioFilename)
		let fileURL = ((filePath == nil) ? audioURL : NSURL(fileURLWithPath: filePath!))
		print("Play File url is \(fileURL)")
		
		// Load Player with throwability
		do {
			audioPlayer = try AVAudioPlayer(contentsOfURL: fileURL!)
			audioPlayer?.delegate = self
			audioPlayer?.prepareToPlay()
			audioPlayer?.volume = 1.0
			
		} catch {
			print("audio player issue!")
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
		
		let audioFilePath = createFilePath(audioFilename)
		
		let fileURL = NSURL(fileURLWithPath: audioFilePath)
		let recordSettings =
			[
				AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
				AVEncoderBitRateKey: 320000,
				AVNumberOfChannelsKey:  2,
				AVSampleRateKey: 44100.0]
//		let recordSettings = [AVSampleRateKey : NSNumber(float: Float(44100.0)),
//			AVFormatIDKey : NSNumber(int: Int32(kAudioFormatAppleLossless)),
//			AVNumberOfChannelsKey : NSNumber(int: 2),
//			AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Max.rawValue))];
		
//		var recordSettings = [
//			AVFormatIDKey: kAudioFormatAppleLossless,
//			AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
//			AVEncoderBitRateKey : 320000,
//			AVNumberOfChannelsKey: 2,
//			AVSampleRateKey : 44100.0
//		]
		
		let audioSession = AVAudioSession.sharedInstance()
		
		do {
			
			try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.AllowBluetooth)
			
			// Load Player with throwability
			do {
				audioRecorder = try AVAudioRecorder(URL: fileURL, settings: recordSettings as! [String : AnyObject])
				audioRecorder?.delegate = self
				let status = audioRecorder?.prepareToRecord()
				
				print("record start status: \(status)")
				
			} catch {
				print("audio recorder issue!")
			}
			
			
		} catch {
			print("Session Error")
		}
		
	}
	
	func record() {
		
		if let recorder = audioRecorder {
			if recorder.recording == false {
				recorder.record()
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
		
		print("Trying to stop recorder")
		
		if let recorder = audioRecorder {
			if recorder.recording == true {
				print("Stop recording")
				recorder.stop()
			}
			
		}
	}
}

extension ViewController {
	
	// MARK: Recorder / Player Delegate
	
	func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
		if flag {
			print("Finsh playing successfully.")
		}
	}
	
	func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
		if (error != nil) {
			print("Audio Play Decode Error: \(error?.localizedDescription)")

		}
	}
	
	func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
		if flag {
			print("Finsh recording successfully.")
		}

	}
	
	func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
		if (error != nil) {
			print("Audio Record Decode Error: \(error?.localizedDescription)")
			
		}
	}
}
