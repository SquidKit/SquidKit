//
//  DispatchTimer.swift
//  SquidKit
//
//  Created by Mike Leavy on 9/7/18.
//  Copyright © 2018-2019 Squid Store, LLC. All rights reserved.
//

import Foundation

// callback parameters: TimeInterval - the current relative playback time;
// Bool - completed flag - true if a duration has been set by the caller, and the duration has been reached.
public typealias DispatchTimerFiredCallback = (TimeInterval, Bool) -> Void
public class DispatchTimer {
    
    private enum State {
        case idle
        case running
        case paused
    }
    
    private var state: State = .idle
    
    private var timer: DispatchSourceTimer!
    private var repeatInterval: TimeInterval?
    private var deadline: TimeInterval!
    private var deadlineReached = false
    private var callback: DispatchTimerFiredCallback?
    
    private var isRepeating: Bool {
        return repeatInterval != nil
    }
    
    public var timeOffset: TimeInterval = 0
    public var duration: TimeInterval?
    public var isRunning: Bool {
        return state == .running
    }
    public var isIdle: Bool {
        return state == .idle
    }
    
    deinit {
        callback = nil
        // timer doesn't like being destructed while in a suspended state, so...
        if !isRunning {
            start()
        }
    }
        
    public init(_ deadline: TimeInterval, repeatInterval: TimeInterval?, duration: TimeInterval?, callback: @escaping DispatchTimerFiredCallback) {
        self.repeatInterval = repeatInterval
        self.duration = duration
        self.deadline = deadline
        self.callback = callback
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue(label: "com.squidstore.dispatch.timer"))
        configure()
    }
    
    public func configure() {
        guard state == .idle else {return}
        deadlineReached = false
        
        timer.setEventHandler { [weak self] in
            guard let unwrapped = self else {return}
            if !unwrapped.deadlineReached {
                unwrapped.deadlineReached = true
                unwrapped.timeOffset += unwrapped.deadline
            }
            else {
                unwrapped.timeOffset += unwrapped.repeatInterval ?? 0
            }
            var completed = false
            if let duration = unwrapped.duration {
                completed = unwrapped.timeOffset >= duration
            }
            DispatchQueue.main.async {
                unwrapped.callback?(unwrapped.timeOffset, completed)
            }
        }
    }
    
    public func start() {
        switch state {
        case .idle:
            let dispatchDeadline: DispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(deadline * 1000))
            if isRepeating {
                let dispatchRepeatInterval = DispatchTimeInterval.milliseconds(Int((repeatInterval ?? 0) * 1000))
                timer.schedule(deadline: dispatchDeadline, repeating: dispatchRepeatInterval)
            }
            else {
                timer.schedule(deadline: dispatchDeadline)
            }
            timer.resume()
        case .paused:
            timer.resume()
        case .running:
            break
        }
        state = .running
    }
    
    public func pause() {
        guard state == .running else {return}
        timer.suspend()
        state = .paused
    }
    
    public func stop() {
        switch state {
        case .idle, .paused:
            break
        case .running:
            timer.suspend()
        }
        state = .idle
        timeOffset = 0
        deadlineReached = false
    }
}




















