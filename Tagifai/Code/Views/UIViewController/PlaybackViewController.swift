//
//  PlaybackViewController.swift
//  Tagifai
//
//  Created by Marc Brown on 9/27/15.
//  Copyright © 2015 creative mess. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import AVFoundation
import AVKit

class PlaybackViewController: UIViewController, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var avPlayerController: AVPlayerViewController?
    var tableView: UITableView?
    var tags = Array<Array<String>>()
    var probs = Array<Array<Double>>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.avPlayerController = AVPlayerViewController()
        self.avPlayerController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.avPlayerController!.view)
        
        self.tableView = UITableView()
        self.tableView?.registerClass(TagCell.classForCoder(), forCellReuseIdentifier: "TagCell")
        self.tableView?.dataSource = self
        self.tableView!.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(self.tableView!)
        
        self.captureVideo(self)
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
    
    @IBAction func captureVideo(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .Camera;
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: false, completion: {
                self.reset()
            })
        } else {
            print("Camera not available.")
        }
    }
    
    func reset() {
        self.tags = Array<Array<String>>()
        self.probs = Array<Array<Double>>()
        self.tableView?.reloadData()
        self.avPlayerController!.player = nil
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count > 0 ? tags[0].count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TagCell", forIndexPath: indexPath) as! TagCell
        cell.titleLbl!.text = tags[0][indexPath.row]
        cell.probabilityLbl!.text = NSString(format: "%.01f", probs[0][indexPath.row] * 100) as String
        
        return cell
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[String : AnyObject]) {
        
        let videoUrl = info[UIImagePickerControllerMediaURL] as! NSURL!
        UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.relativePath!, self, nil, nil)
        
        self.dismissViewControllerAnimated(false, completion: {})
    }
}

