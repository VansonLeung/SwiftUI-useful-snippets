//
//  GenericLottieView.swift
//  hkstp oneapp testing
//
//  Created by van on 22/6/2022.
//

import Foundation
import SwiftUI
import Lottie
 
struct GenericLottieView: UIViewRepresentable {
    @Binding var isStartNow: Bool
    @Binding var isPauseNow: Bool
    var onComplete: (Bool) -> Void

    @Binding var lottieFile: String
    @Binding var fromFrame: AnimationFrameTime?
    @Binding var toFrame: AnimationFrameTime?
    @Binding var loopMode: LottieLoopMode?
    @Binding var currentFrame: AnimationFrameTime?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(currentFrame: $currentFrame)
    }
    
    func makeUIView(context: UIViewRepresentableContext<GenericLottieView>) -> AnimationView {
        let animationView = AnimationView()
 
        animationView.animation = Animation.named(lottieFile)
        animationView.contentMode = .scaleAspectFill
        
        context.coordinator._tempAnimView = animationView
        
        return animationView
    }
 
    func updateUIView(_ uiView: AnimationView, context: UIViewRepresentableContext<GenericLottieView>) {
        context.coordinator.onUpdate(parent: self, animationView: uiView)
    }
    
    
    func dismantleUIView(_ uiView: AnimationView, context: UIViewRepresentableContext<GenericLottieView>) {
        context.coordinator.onUpdate(parent: self, animationView: uiView)
        context.coordinator.stopTimer()
    }
    
    
    class Coordinator: NSObject {
        var cur_isStartNow: Bool = false
        var cur_isPauseNow: Bool = false
        var cur_lottieFile: String?
        var cur_fromFrame: AnimationFrameTime?
        var cur_toFrame: AnimationFrameTime?
        var cur_loopMode: LottieLoopMode?
        
        var timer : Timer?
        var _tempAnimView : AnimationView?
        
        @Binding var currentFrame : AnimationFrameTime?
        
        init(currentFrame : Binding<AnimationFrameTime?>) {
            self._currentFrame = currentFrame
        }
        
        func startTimer()
        {
            timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(Coordinator.onUpdateTimer), userInfo: nil, repeats: true)
        }
        
        @objc func onUpdateTimer()
        {
            if let _tempAnimView = _tempAnimView
            {
                self.currentFrame = _tempAnimView.realtimeAnimationFrame
                if self.currentFrame == cur_toFrame
                {
                    
                }
//                print(_tempAnimView, _tempAnimView.realtimeAnimationFrame, _tempAnimView.realtimeAnimationProgress)
            }
        }
        
        func stopTimer()
        {
            timer?.invalidate()
            timer = nil
        }

        func onUpdate(parent: GenericLottieView, animationView: AnimationView)
        {
            _tempAnimView = animationView
            
            if parent.isStartNow && !cur_isStartNow
            {
                cur_isStartNow = true
                
                DispatchQueue.main.async {
                    parent.isStartNow = false
                    self.cur_isStartNow = false
                }
                
                // trigger start
                cur_lottieFile = parent.lottieFile
                cur_fromFrame = parent.fromFrame
                cur_toFrame = parent.toFrame
                cur_loopMode = parent.loopMode
                play(parent: parent, animationView: animationView)
            }

            if parent.isPauseNow && !cur_isPauseNow
            {
                cur_isPauseNow = true
                
                DispatchQueue.main.async {
                    parent.isPauseNow = false
                    self.cur_isPauseNow = false
                }
             
                pause(parent: parent, animationView: animationView)
            }
        }
        
        func play(parent: GenericLottieView, animationView: AnimationView)
        {
            stopTimer()
            startTimer()

            if let cur_fromFrame = cur_fromFrame,
               let cur_toFrame = cur_toFrame
            {
                print("play \(cur_fromFrame) \(cur_toFrame)")
                animationView.play(fromFrame: cur_fromFrame, toFrame: cur_toFrame, loopMode: cur_loopMode) { boo in
                    
                    if boo == true
                    {
                        parent.onComplete(boo)
                    }
                }
            }
            else
            {
                print("play")
                animationView.play(fromProgress: 0, toProgress: 1, loopMode: cur_loopMode) { boo in
                    
                    if boo == true
                    {
                        parent.onComplete(boo)
                    }

                }
            }
        }
        
        
        func pause(parent: GenericLottieView, animationView: AnimationView)
        {
            stopTimer()
            animationView.pause()
        }
    }
    
    
//    func playMe()
//    {
//        isUpdated = false
//
//        var _fromFrame : AnimationFrameTime? = nil
//        var _toFrame : AnimationFrameTime? = nil
//
//        if let fromFrame = fromFrame {
//            _fromFrame = fromFrame
//        }
//
//        if let toFrame = toFrame {
//            _toFrame = toFrame
//        }
//
//        if let _fromFrame = _fromFrame,
//           let _toFrame = _toFrame
//        {
//            animationView.play(fromFrame: _fromFrame, toFrame: _toFrame, loopMode: .playOnce, completion: { boo in
//                self.onComplete()
//            })
//        }
//        else
//        {
//            animationView.play { boo in
//                self.onComplete()
//            }
//        }
//    }
    
//    func onComplete()
//    {
//        if loopMode == .loop
//        {
//            playMe()
//        }
//    }
}
