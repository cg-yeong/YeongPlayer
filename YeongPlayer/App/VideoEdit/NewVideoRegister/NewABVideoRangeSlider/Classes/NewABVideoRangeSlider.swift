//
//  ABVideoRangeSlider.swift
//  selfband
//
//  Created by Oscar J. Irun on 26/11/16.
//  Copyright © 2016 appsboulevard. All rights reserved.
//

import UIKit

public protocol NewABVideoRangeSliderDelegate {
    func didChangeValue(videoRangeSlider: NewABVideoRangeSlider, startTime: Float64, endTime: Float64)
    func indicatorDidChangePosition(videoRangeSlider: NewABVideoRangeSlider, position: Float64)
    func indicatorSliderChangeEnded()
}

public class NewABVideoRangeSlider: UIView {
    
    public var delegate: NewABVideoRangeSliderDelegate? = nil
    
    var startIndicator      = NewABStartIndicator()
    var endIndicator        = NewABEndIndicator()
    var topLine             = NewABBorder()
    var bottomLine          = NewABBorder()
    var progressIndicator   = NewABProgressIndicator()
    var draggableView       = UIView()
    
    var startModelView      = UIView()
    var endModelView        = UIView()
    
    var startTimeView       = NewABTimeView()
    var endTimeView         = NewABTimeView()
    
    let thumbnailsManager   = NewABThumbnailsManager()
    var duration: Float64   = 0.0
    var videoURL            = URL(fileURLWithPath: "")

    var progressPercentage: CGFloat = 0         // Represented in percentage
    var startPercentage: CGFloat    = 0         // Represented in percentage
    var endPercentage: CGFloat      = 100       // Represented in percentage
    
    let topBorderHeight: CGFloat      = 6
    let bottomBorderHeight: CGFloat   = 6
    
    let indicatorWidth: CGFloat = 32.0
    
    public var minSpace: Float = 1              // In Seconds
    public var maxSpace: Float = 0              // In Seconds
    
    var isUpdatingThumbnails = false
    
    public enum NewABTimeViewPosition{
        case top
        case bottom
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup(){
        self.isUserInteractionEnabled = true
        
        // Setup Start Indicator
        let startDrag = UIPanGestureRecognizer(target:self, action: #selector(startDragged(_:)))
        
        startIndicator = NewABStartIndicator(frame: CGRect(x: -24,
                                                        y: -topBorderHeight,
                                                        width: indicatorWidth,
                                                        height: self.frame.size.height + bottomBorderHeight + topBorderHeight))
        startIndicator.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        startIndicator.addGestureRecognizer(startDrag)
        self.addSubview(startIndicator)
        
        // Setup End Indicator
        
        let endDrag = UIPanGestureRecognizer(target:self, action: #selector(endDragged(_:)))
        
        endIndicator = NewABEndIndicator(frame: CGRect(x: 0,
                                                    y: -topBorderHeight,
                                                    width: indicatorWidth,
                                                    height: self.frame.size.height + bottomBorderHeight + topBorderHeight))
        endIndicator.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        endIndicator.addGestureRecognizer(endDrag)
        self.addSubview(endIndicator)


        // Setup Top and bottom line
        topLine = NewABBorder(frame: CGRect(x: 0,
                                         y: -topBorderHeight,
                                         width: indicatorWidth,
                                         height: topBorderHeight))
        self.addSubview(topLine)
        
        bottomLine = NewABBorder(frame: CGRect(x: 0,
                                            y: self.frame.size.height,
                                            width: indicatorWidth,
                                            height: bottomBorderHeight))
        self.addSubview(bottomLine)
        
        self.addObserver(self,
                         forKeyPath: "bounds",
                         options: NSKeyValueObservingOptions(rawValue: 0),
                         context: nil)
        
        // Setup Progress Indicator
        
        let progressDrag = UIPanGestureRecognizer(target:self, action: #selector(progressDragged(_:)))
        
        progressIndicator = NewABProgressIndicator(frame: CGRect(x: 0, y: -8, width: 15, height: self.frame.height))
        progressIndicator.addGestureRecognizer(progressDrag)
        progressIndicator.imageView.isHidden = false
        self.addSubview(progressIndicator)
        
        // Setup Draggable View
        
        let viewDrag = UIPanGestureRecognizer(target:self, action: #selector(viewDragged(_:)))
        
        draggableView.addGestureRecognizer(viewDrag)
        self.draggableView.backgroundColor = UIColor.clear
        self.addSubview(draggableView)
        self.sendSubviewToBack(draggableView)
        
        // Setup time labels
        
        startTimeView = NewABTimeView(size: CGSize(width: 60, height: 30), position: 1)
        startTimeView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.addSubview(startTimeView)
        
        endTimeView = NewABTimeView(size: CGSize(width: 60, height: 30), position: 1)
        endTimeView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.addSubview(endTimeView)
        
        
        
        startModelView.backgroundColor = .black
        startModelView.alpha = 0.5
        
        self.insertSubview(startModelView, belowSubview: startIndicator)
        startModelView.translatesAutoresizingMaskIntoConstraints = false
        startModelView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0).isActive = true
        startModelView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        startModelView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        startModelView.trailingAnchor.constraint(equalTo: startIndicator.leadingAnchor, constant: 5.0).isActive = true
        
        
        endModelView.backgroundColor = .black
        endModelView.alpha = 0.5
        
        self.insertSubview(endModelView, belowSubview: endIndicator)
        endModelView.translatesAutoresizingMaskIntoConstraints = false
        endModelView.leadingAnchor.constraint(equalTo: endIndicator.trailingAnchor, constant: -5.0).isActive = true
        endModelView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0).isActive = true
        endModelView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0).isActive = true
        endModelView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0).isActive = true
        
    }

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds"{
            self.updateThumbnails(duration: duration)
        }
    }

    public func updateProgressIndicator(seconds: Float64){
        self.progressPercentage = self.valueFromSeconds(seconds: Float(seconds))
        layoutSubviews()
    }

    func setTimeView(view: NewABTimeView){
        self.startTimeView = view
        self.endTimeView = view
    }
    
    public func setTimeViewPosition(position: NewABTimeViewPosition){
        switch position {
        case .top:
            
            break
        case .bottom:
            
            break
        }
    }
    
    public func setMyVideoURL(videoURL: URL){
        self.duration = NewABVideoHelper.videoDuration(videoURL: videoURL)
        self.videoURL = videoURL
        self.superview?.layoutSubviews()
        self.updateThumbnails(duration: duration)
    }
    
    public func updateThumbnails(duration: Float64, startTime : Float = 0){
        if !isUpdatingThumbnails{
            self.isUpdatingThumbnails = true
            self.thumbnailsManager.updateThumbnails(view: self, videoURL: self.videoURL, duration: self.duration, startTime: startTime)
            self.isUpdatingThumbnails = false
        }
    }
    
    public func setStartPosition(seconds: Float){
        self.startPercentage = self.valueFromSeconds(seconds: seconds)
        self.progressPercentage = self.valueFromSeconds(seconds: seconds)
        layoutSubviews()
    }
    
    public func setEndPosition(seconds: Float){
        self.endPercentage = self.valueFromSeconds(seconds: seconds)
        layoutSubviews()
    }
    
    // MARK: Private functions
    private func positionFromValue(value: CGFloat) -> CGFloat{
        let position = value * self.frame.size.width / 100
        return position
    }
    
    @objc func startDragged(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self)
        
        var progressPosition = positionFromValue(value: self.progressPercentage)
        var position = positionFromValue(value: self.startPercentage)
        position = position + translation.x
        
        if position < 0{
            position = 0
        }
        
        if position > self.frame.size.width{
            position = self.frame.size.width
        }
        
        if progressPosition < position{
            progressPosition = position
        }
        
        let positionLimit = positionFromValue(value: self.endPercentage - valueFromSeconds(seconds: minSpace))
        
        if Float(self.duration) < self.minSpace {
            position = 0
        }else{
            if position > positionLimit {
                position = positionLimit
            }
        }
        
        let positionLimitMax = positionFromValue(value: self.endPercentage - valueFromSeconds(seconds: maxSpace))
        if Float(self.duration) > self.maxSpace && self.maxSpace > 0{
            if position < positionLimitMax{
                position = positionLimitMax
            }
        }
        
        
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        progressIndicator.center = CGPoint(x: progressPosition , y: progressIndicator.center.y)
        startIndicator.center = CGPoint(x: position , y: startIndicator.center.y)
        
        let percentage = startIndicator.center.x * 100 / self.frame.width
        let progressPercentage = progressIndicator.center.x * 100 / self.frame.width
        
        let startSeconds = secondsFromValue(value: startPercentage)
        let endSeconds = secondsFromValue(value: endPercentage)
        
        self.delegate?.didChangeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)
    
        if self.progressPercentage != progressPercentage{
            let progressSeconds = secondsFromValue(value: progressPercentage)
            self.delegate?.indicatorDidChangePosition(videoRangeSlider: self, position: progressSeconds)
        }
        
        self.startPercentage = percentage
        self.progressPercentage = progressPercentage
        
        layoutSubviews()
        
        // by ag315
        if recognizer.state == UIGestureRecognizer.State.ended {
            self.delegate?.indicatorSliderChangeEnded()
        }
    }
    
    
    @objc func endDragged(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self)
        
        var progressPosition = positionFromValue(value: self.progressPercentage)
        var position = positionFromValue(value: self.endPercentage)
        position = position + translation.x
        
        if position < 0{
            position = 0
        }
        
        if position > self.frame.size.width{
            position = self.frame.size.width
        }
        
        if progressPosition > position{
            progressPosition = position
        }
        
        let positionLimit = positionFromValue(value: valueFromSeconds(seconds: minSpace) + self.startPercentage)
        
        if Float(self.duration) < self.minSpace {
            position = self.frame.size.width
        }else{
            if position < positionLimit {
                position = positionLimit
            }
        }
        
        let positionLimitMax = positionFromValue(value: self.startPercentage + valueFromSeconds(seconds: maxSpace))
        if Float(self.duration) > self.maxSpace && self.maxSpace > 0{
            if position > positionLimitMax{
                position = positionLimitMax
            }
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        progressIndicator.center = CGPoint(x: progressPosition , y: progressIndicator.center.y)
        endIndicator.center = CGPoint(x: position , y: endIndicator.center.y)
        
        let percentage = endIndicator.center.x * 100 / self.frame.width
        let progressPercentage = progressIndicator.center.x * 100 / self.frame.width
        
        let startSeconds = secondsFromValue(value: startPercentage)
        let endSeconds = secondsFromValue(value: endPercentage)
        
        self.delegate?.didChangeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)
        
        if self.progressPercentage != progressPercentage{
            let progressSeconds = secondsFromValue(value: progressPercentage)
            self.delegate? .indicatorDidChangePosition(videoRangeSlider: self, position: progressSeconds)
        }
        
        self.endPercentage = percentage
        self.progressPercentage = progressPercentage

        layoutSubviews()
        
        // by ag315
        if recognizer.state == UIGestureRecognizer.State.ended {
            self.delegate?.indicatorSliderChangeEnded()
        }
    }
    
    @objc func progressDragged(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self)
        
        let positionLimitStart  = positionFromValue(value: self.startPercentage)
        let positionLimitEnd    = positionFromValue(value: self.endPercentage)
        
        var position = positionFromValue(value: self.progressPercentage)
        position = position + translation.x
        
        if position < positionLimitStart{
            position = positionLimitStart
        }
        
        if position > positionLimitEnd{
            position = positionLimitEnd
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        progressIndicator.center = CGPoint(x: position , y: progressIndicator.center.y)
        
        let percentage = progressIndicator.center.x * 100 / self.frame.width
        
        let progressSeconds = secondsFromValue(value: progressPercentage)
        
        self.delegate?.indicatorDidChangePosition(videoRangeSlider: self, position: progressSeconds)
        
        self.progressPercentage = percentage
        
        layoutSubviews()
        
        // by ag315
        if recognizer.state == UIGestureRecognizer.State.ended {
            self.delegate?.indicatorSliderChangeEnded()
        }
    }
    
    @objc func viewDragged(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self)
        
        var progressPosition = positionFromValue(value: self.progressPercentage)
        var startPosition = positionFromValue(value: self.startPercentage)
        var endPosition = positionFromValue(value: self.endPercentage)
        
        startPosition = startPosition + translation.x
        endPosition = endPosition + translation.x
        progressPosition = progressPosition + translation.x
        
        if startPosition < 0 {
            startPosition = 0
            endPosition = endPosition - translation.x
            progressPosition = progressPosition - translation.x
        }
        
        if endPosition > self.frame.size.width{
            endPosition = self.frame.size.width
            startPosition = startPosition - translation.x
            progressPosition = progressPosition - translation.x
        }
        
        recognizer.setTranslation(CGPoint.zero, in: self)
        
        progressIndicator.center = CGPoint(x: progressPosition , y: progressIndicator.center.y)
        startIndicator.center = CGPoint(x: startPosition , y: startIndicator.center.y)
        endIndicator.center = CGPoint(x: endPosition , y: endIndicator.center.y)
        
        let startPercentage = startIndicator.center.x * 100 / self.frame.width
        let endPercentage = endIndicator.center.x * 100 / self.frame.width
        let progressPercentage = progressIndicator.center.x * 100 / self.frame.width
        
        let startSeconds = secondsFromValue(value: startPercentage)
        let endSeconds = secondsFromValue(value: endPercentage)
        
        self.delegate?.didChangeValue(videoRangeSlider: self, startTime: startSeconds, endTime: endSeconds)

        if self.progressPercentage != progressPercentage{
            let progressSeconds = secondsFromValue(value: progressPercentage)
            self.delegate?.indicatorDidChangePosition(videoRangeSlider: self, position: progressSeconds)
        }

        self.startPercentage = startPercentage
        self.endPercentage = endPercentage
        self.progressPercentage = progressPercentage
        
        layoutSubviews()
        
        // by ag315
        if recognizer.state == UIGestureRecognizer.State.ended {
            self.delegate?.indicatorSliderChangeEnded()
        }
    }
    
    private func secondsFromValue(value: CGFloat) -> Float64{
        return duration * Float64((value / 100))
    }
    
    private func valueFromSeconds(seconds: Float) -> CGFloat{
        return CGFloat(seconds * 100) / CGFloat(duration)
    }
    
    // MARK:
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        startTimeView.timeLabel.text = self.secondsToFormattedString(totalSeconds: secondsFromValue(value: self.startPercentage))
        endTimeView.timeLabel.text = self.secondsToFormattedString(totalSeconds: secondsFromValue(value: self.endPercentage))
        
        let startPosition = positionFromValue(value: self.startPercentage)
        let endPosition = positionFromValue(value: self.endPercentage)
        let progressPosition = positionFromValue(value: self.progressPercentage)
        
        startIndicator.center = CGPoint(x: startPosition, y: startIndicator.center.y)
        endIndicator.center = CGPoint(x: endPosition, y: endIndicator.center.y)
        progressIndicator.center = CGPoint(x: progressPosition, y: progressIndicator.center.y)
        draggableView.frame = CGRect(x: startIndicator.frame.origin.x + startIndicator.frame.size.width,
                                     y: 0,
                                     width: endIndicator.frame.origin.x - startIndicator.frame.origin.x - endIndicator.frame.size.width,
                                     height: self.frame.height)

        
        topLine.frame = CGRect(x: startIndicator.frame.origin.x + startIndicator.frame.width,
                               y: -topBorderHeight,
                               width: endIndicator.frame.origin.x - startIndicator.frame.origin.x - endIndicator.frame.size.width,
                               height: topBorderHeight)
        
        bottomLine.frame = CGRect(x: startIndicator.frame.origin.x + startIndicator.frame.width,
                                  y: self.frame.size.height,
                                  width: endIndicator.frame.origin.x - startIndicator.frame.origin.x - endIndicator.frame.size.width,
                                  height: bottomBorderHeight)
        
        // Update time view
        startTimeView.center = CGPoint(x: startIndicator.center.x, y: startTimeView.center.y)
        endTimeView.center = CGPoint(x: endIndicator.center.x, y: endTimeView.center.y)
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let extendedBounds = CGRect(x: -startIndicator.frame.size.width,
                                    y: -topLine.frame.size.height,
                                    width: self.frame.size.width + startIndicator.frame.size.width + endIndicator.frame.size.width,
                                    height: self.frame.size.height + topLine.frame.size.height + bottomLine.frame.size.height)
        return extendedBounds.contains(point)
    }
    

    private func secondsToFormattedString(totalSeconds: Float64) -> String{
        let hours:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
}
