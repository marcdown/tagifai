//
//  PlaybackViewController.swift
//  Tagifai
//
//  Created by Marc Brown on 9/27/15.
//  Copyright © 2015 creative mess. All rights reserved.
//

import AVFoundation
import AVKit
import MobileCoreServices
import PKHUD

class PlaybackViewController: UIViewController, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var avPlayerController: AVPlayerViewController?
    var tableView: UITableView?
    var videoTimestamps = [VideoTimestamp]()
    var currentVideoTimestamp: VideoTimestamp?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.avPlayerController = AVPlayerViewController()
        self.avPlayerController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.avPlayerController!.view)
        
        self.tableView = UITableView()
        self.tableView?.rowHeight = 44
        self.tableView?.registerClass(TagCell.classForCoder(), forCellReuseIdentifier: "TagCell")
        self.tableView?.dataSource = self
        self.tableView!.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.tableView!)
        
        // Slight delay to allow vc to fully load before presenting the modal
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.captureVideo(nil)
        }
    }
    
    override func updateViewConstraints() {
        let views = ["avPlayer": self.avPlayerController!.view, "tableView": self.tableView]
        let metrics = ["avPlayerHeight": (CGRectGetWidth(self.view.bounds) * 9) / 16] // 16:9
        
        // Horizontal
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[avPlayer]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        // Vertical
        self.view.addConstraint(NSLayoutConstraint(item: self.avPlayerController!.view, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[avPlayer(avPlayerHeight)][tableView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        
        super.updateViewConstraints()
    }
    
    @IBAction func captureVideo(sender: AnyObject?) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .Camera;
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: false, completion: {})
        } else {
            print("Camera not available.")
        }
    }
    
    func recognizeVideo(url: NSURL) {
        let data = NSData(contentsOfURL: url)
        let client = ClarifaiClient()
        PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
        PKHUD.sharedHUD.show()
        client.recognizeVideo(data) { (result: [ClarifaiResult]!, error: NSError!) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    PKHUD.sharedHUD.contentView = PKHUDErrorView()
                    PKHUD.sharedHUD.hide(afterDelay: 2)
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                PKHUD.sharedHUD.hide()
                for (var i = 0; i < result[0].videoTimestamps.count; i++) {
                    let videoTimestamp = VideoTimestamp(timestamp: result[0].videoTimestamps[i] as NSNumber, tags: result[0].videoTags[i] as! [String], probabilities: result[0].videoProbabilities[i] as! [Double])
                    self.videoTimestamps.append(videoTimestamp)
                }
                // Sort timestamps by playback time
                self.videoTimestamps.sortInPlace({Float($0.timestamp) < Float($1.timestamp)})
                
                self.loadVideo(url)
            })
        }
    }
    
    func loadVideo(url: NSURL) {
        self.avPlayerController!.player = AVPlayer(URL: url)
        self.avPlayerController!.player?.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1) , queue: dispatch_get_main_queue(), usingBlock: { (time: CMTime) -> Void in
            let seconds: Int = Int(CMTimeGetSeconds(time))
            self.currentVideoTimestamp = self.videoTimestamps[seconds]
            self.tableView?.reloadData()
        })
        self.avPlayerController!.player!.play()
    }
    
    func reset() {
        self.videoTimestamps = [VideoTimestamp]()
        self.currentVideoTimestamp = nil
        self.tableView?.reloadData()
        self.avPlayerController!.player = nil
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.currentVideoTimestamp != nil) ? (self.currentVideoTimestamp?.videoTags.count)! : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagCell", forIndexPath: indexPath) as! TagCell
        let videoTagViewModel = VideoTagViewModel(model: (self.currentVideoTimestamp?.videoTags[indexPath.row])!)
        cell.titleLbl!.text = videoTagViewModel.displayName
        cell.probabilityLbl!.text = videoTagViewModel.displayProbability
        
        return cell
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : AnyObject]) {
        // Reset playback view
        self.reset()
        
        let videoUrl = info[UIImagePickerControllerMediaURL] as! NSURL
        self.recognizeVideo(videoUrl)
        UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.relativePath!, self, nil, nil)
        
        self.dismissViewControllerAnimated(false, completion: {})
    }
}

