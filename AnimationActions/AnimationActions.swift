//
//  AnimationActions.swift
//  CoreAnimation
//
//  Created by Franklyn on 25/02/2019.
//  Copyright © 2019 Franklyn. All rights reserved.
//

import UIKit


typealias AnimationBeganAction = () -> ()
typealias AnimationFinishedAction = (CAAnimation?, Bool) -> ()


private var stringAssociationKey: UInt8 = 0

extension CAAnimation {

    fileprivate var identifier: String? {
        get {
            return objc_getAssociatedObject(self, &stringAssociationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &stringAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var began: AnimationBeganAction? {
        set {
            guard let newValue = newValue else {
                AnimationActions.removeBeginAction(for: self)
                return
            }
            if identifier == nil {
                identifier = UUID().uuidString
            }
            AnimationActions.addBeginAction(newValue, for: self)
        }
        get {
            guard let identifier = identifier else {
                return nil
            }
            return AnimationActions.animationDelegates[identifier]?.beginAction
        }
    }

    var finished: AnimationFinishedAction? {
        set {
            guard let newValue = newValue else {
                AnimationActions.removeFinishAction(for: self)
                return
            }
            if identifier == nil {
                identifier = UUID().uuidString
            }
            AnimationActions.addFinishAction(newValue, for: self)
        }
        get {
            guard let identifier = identifier else {
                return nil
            }
            return AnimationActions.animationDelegates[identifier]?.finishAction
        }
    }
}


fileprivate class AnimationActions {

    static var animationDelegates: [String: AnimationDelegate] = [:]

    static func addBeginAction(_ action: @escaping AnimationBeganAction, for animation: CAAnimation) {
        guard let identifier = animation.identifier else { return }
        if let animationDelegate = animationDelegates[identifier] {
            animationDelegate.beginAction = action
        } else {
            let animationDelegate = AnimationDelegate(identifier)
            animation.delegate = animationDelegate
            animationDelegate.beginAction = action
            animationDelegates[identifier] = animationDelegate
        }
    }

    static func addFinishAction(_ action: @escaping AnimationFinishedAction, for animation: CAAnimation) {
        guard let identifier = animation.identifier else { return }
        if let animationDelegate = animationDelegates[identifier] {
            animationDelegate.finishAction = action
        } else {
            let animationDelegate = AnimationDelegate(identifier)
            animation.delegate = animationDelegate
            animationDelegate.finishAction = action
            animationDelegates[identifier] = animationDelegate
        }
    }

    static func removeBeginAction(for animation: CAAnimation) {
        guard let identifier = animation.identifier else { return }
        if let animationDelegate = animationDelegates[identifier] {
            animationDelegate.beginAction = nil
            if animationDelegate.finishAction == nil {
                animation.delegate = nil
                AnimationActions.removeDelegate(for: identifier)
            }
        }
    }

    static func removeFinishAction(for animation: CAAnimation) {
        guard let identifier = animation.identifier else { return }
        if let animationDelegate = animationDelegates[identifier] {
            animationDelegate.finishAction = nil
            if animationDelegate.beginAction == nil {
                animation.delegate = nil
                AnimationActions.removeDelegate(for: identifier)
            }
        }
    }

    fileprivate static func removeDelegate(for key: String) {
        animationDelegates.removeValue(forKey: key)
    }

    fileprivate class AnimationDelegate: NSObject, CAAnimationDelegate, Identifiable {

        var id: String

        var beginAction: AnimationBeganAction?
        var finishAction: AnimationFinishedAction?

        init(_ identifier: String) {
            id = identifier
            super.init()
        }

        func animationDidStart(_ anim: CAAnimation) {
            DispatchQueue.main.async {
                self.beginAction?()
            }
            if finishAction == nil {
                AnimationActions.removeDelegate(for: id)
            }
        }

        func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
            DispatchQueue.main.async {
                self.finishAction?(anim, flag)
            }
            AnimationActions.removeDelegate(for: id)
        }
    }
}
