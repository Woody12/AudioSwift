//
//  ViewController.swift
//  AudioSwift
//
//  Created by Woody Lee on 11/3/15.
//  Copyright © 2015 Woody Lee. All rights reserved.
//

import UIKit
import AVFoundation

private let kFSVoiceBubbleShouldStopNotification = "FSVoiceBubbleShouldStopNotification"

private var audioPlayer: AVAudioPlayer?
private var asset: AVURLAsset?
private var audioURL: NSURL?

class ViewController: UIViewController, AVAudioPlayerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "bubbleShouldStop:", name: kFSVoiceBubbleShouldStopNotification, object: nil)
		
		loadAudio(NSBundle.mainBundle().URLForResource("Let It Go", withExtension: "mp3"))
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func recordClick(sender: AnyObject) {
		
		print("long gesture")
		
	}

	@IBAction func playClick(sender: AnyObject) {
	
		print("play")
		
		if let _ = audioPlayer,
			_ = audioPlayer?.playing {
				stop()
		}
		NSNotificationCenter.defaultCenter().postNotificationName(kFSVoiceBubbleShouldStopNotification, object: nil)
		play()
	
	}
	
	func bubbleShouldStop(notification: NSNotification) {
		
		stop()
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().postNotificationName(kFSVoiceBubbleShouldStopNotification, object: nil)
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
	
	// Play
	
	func play() {
		
		if let _ = audioPlayer {
			stop()
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
	
	func pause() {
		
		if let player = audioPlayer {
			if player.playing == true {
				player.pause()
			}

		}
	}
	
	func stop() {
		if let player = audioPlayer {
			if player.playing == true {
				player.stop()
				player.currentTime = 0
			}
			
		}
	}
}



