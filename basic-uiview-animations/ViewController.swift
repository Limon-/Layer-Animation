//
//  ViewController.swift
//  basic-uiview-animations
//
//  Created by Marin Todorov on 8/11/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

// Basic Layer Animations

import UIKit
import QuartzCore



//
// Util delay function
//
func delay(#seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

class ViewController: UIViewController {
    
    // MARK: ui outlets
    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var heading: UILabel!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var cloud1: UIImageView!
    @IBOutlet var cloud2: UIImageView!
    @IBOutlet var cloud3: UIImageView!
    @IBOutlet var cloud4: UIImageView!
    
    // MARK: further ui
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    let status = UIImageView(image: UIImage(named: "banner"))
    let label = UILabel()
    let messages = ["Connecting ...", "Authorization ...", "Sending credentials ...", "Failed"]
    
    // MARK: view controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        
        //add the button spinner
        spinner.frame = CGRect(x: -20, y: 6, width: 20, height: 20)
        spinner.startAnimating()
        spinner.alpha = 0.0
        loginButton.addSubview(spinner)

        //add the status banner
        status.hidden = true
        status.center = loginButton.center
        view.addSubview(status)
        
        status.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "didTapStatus")
        status.addGestureRecognizer(tap)
        
        
        //add the status label
        label.frame = CGRect(x: 0, y: 0, width: status.frame.size.width, height: status.frame.size.height)
        label.font = UIFont(name: "HelveticaNeue", size: 18.0)
        label.textColor = UIColor(red: 228.0/255.0, green: 98.0/255.0, blue: 0.0, alpha: 1.0)
        label.textAlignment = .Center
        status.addSubview(label)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 这两个需要移动x值是因为需要delay，而heading不需delay
        username.layer.position.x -= view.bounds.width
        password.layer.position.x -= view.bounds.width
        
//        loginButton.layer.position.y += 100.0
//        loginButton.layer.opacity = 0.0
        
        
        

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let flyRight = CABasicAnimation(keyPath: "position.x")
        flyRight.fromValue = -view.bounds.size.width/2
        flyRight.toValue = view.bounds.size.width/2
        flyRight.duration = 0.5
        heading.layer.addAnimation(flyRight, forKey: nil)
        
        // fillMode的作用就是决定当前对象过了非active时间段的行为,而removedOnCompletion决定animation完成之后移不移除
        // 使用这两个属性，还有个BUG，UITextField点击之后不出现键盘
        // 这两个属性令username动画完成后，还存在render tree上，but not a real thing
//        flyRight.removedOnCompletion = false
//        flyRight.fillMode = kCAFillModeForwards
        
        // FIXED
        flyRight.delegate = self
        flyRight.setValue("form", forKey: "name")
        flyRight.setValue(username.layer, forKey: "layer")
        
        flyRight.beginTime = CACurrentMediaTime() + 0.3
        username.layer.addAnimation(flyRight, forKey: nil)

        
        flyRight.setValue(password.layer, forKey: "layer")
        flyRight.beginTime = CACurrentMediaTime() + 0.4
        password.layer.addAnimation(flyRight, forKey: nil)
        
        let loginButtonAnimation = CAKeyframeAnimation(keyPath: "position")
        loginButtonAnimation.duration = 0.6
        loginButtonAnimation.values = [
            NSValue(CGPoint: CGPoint(x: -view.frame.size.width/2, y: loginButton.layer.position.y+100)),
            NSValue(CGPoint: CGPoint(x: view.frame.size.width/2, y: loginButton.layer.position.y+100)),
            NSValue(CGPoint: CGPoint(x: view.frame.size.width/2, y: loginButton.layer.position.y))
        ]
        loginButtonAnimation.keyTimes = [0.0, 0.5, 1.0]
        loginButtonAnimation.additive = false // 注意，如果为true
        loginButton.layer.addAnimation(loginButtonAnimation, forKey: nil)
        
        // 动画组 loginButton
//        let flyUpAndFadeInGroup = CAAnimationGroup()
//        flyUpAndFadeInGroup.beginTime = CACurrentMediaTime() + 0.5
//        flyUpAndFadeInGroup.duration = 0.5
//        flyUpAndFadeInGroup.delegate = self
//        flyUpAndFadeInGroup.setValue("loginButton", forKey: "name")
//        
//        let flyUp = CABasicAnimation(keyPath: "position.y")
//        flyUp.toValue = loginButton.layer.position.y - 100
//        
//        let fadeIn = CABasicAnimation(keyPath: "opacity")
//        fadeIn.toValue = 1.0
//        
//        flyUpAndFadeInGroup.animations = [flyUp, fadeIn]
//        loginButton.layer.addAnimation(flyUpAndFadeInGroup, forKey: nil)
        
        // 云
        animateCloud(self.cloud1);
        animateCloud(self.cloud2);
        animateCloud(self.cloud3);
        animateCloud(self.cloud4);

    }
    
    func tintBackgroundColor(layer: CALayer, toColor: UIColor) {
        let tint = CABasicAnimation(keyPath: "backGround")
        tint.fromValue = layer.backgroundColor
        tint.toValue = toColor.CGColor
        tint.duration = 1.5
        tint.fillMode = kCAFillModeForwards
        layer.addAnimation(tint, forKey: nil)
        layer.backgroundColor = toColor.CGColor
    }
    
    func roundCorners(layer: CALayer, toRadius: CGFloat) {
        let roundRect = CABasicAnimation(keyPath: "cornerRadius")
        roundRect.toValue = toRadius
        roundRect.duration = 1.0
        roundRect.fillMode = kCAFillModeForwards
        layer.addAnimation(roundRect, forKey: nil)
        layer.cornerRadius = toRadius
    }
    
    // MARK: CABasicAnimation Delegate
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        let nameValue = anim.valueForKey("name") as? String
        if let name = nameValue {
            if name == "form" {
                let layer: CALayer = anim.valueForKey("layer") as! CALayer
                layer.position.x = view.bounds.width/2
                anim.setValue(nil, forKey: "layer")
            }
            
            if name == "cloud" {
                let cloud: UIImageView = anim.valueForKey("view") as! UIImageView
                cloud.frame.origin.x = -self.cloud1.frame.size.width
                delay(seconds: 0.1, {
                    self.animateCloud(cloud)
                })
            }
            
            if name == "loginButton" {
//                loginButton.layer.position.y -= 100
//                loginButton.layer.opacity = 1.0
            }
        }
    }
    
    @IBAction func login() {
        
        tintBackgroundColor(loginButton.layer, toColor: UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0))
        roundCorners(loginButton.layer, toRadius: 25.0)
        UIView.animateWithDuration(1, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, options: nil, animations: {
            let b = self.loginButton.bounds
            self.loginButton.bounds = CGRect(x: b.origin.x - 20, y: b.origin.y, width: b.size.width+80, height: b.size.height)
            
        }) { _ in
            self.showMessages(index: 0)
        }
        
        UIView.animateWithDuration(0.33, delay: 0.0, options: .CurveEaseOut, animations: {
            if self.status.hidden {
                self.loginButton.center.y += 60
            }
            self.spinner.alpha = 1.0
            self.spinner.center = CGPoint(x: 40, y: self.loginButton.frame.size.height/2)
            
        }, completion: nil)
        
    }
    
    private func showMessages(#index: Int){
        UIView.animateWithDuration(0.33, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .TransitionCurlDown, animations: { () -> Void in
            self.status.center.x += self.view.frame.size.width
        }) { _ in
            self.status.hidden = true
            self.status.center.x -= self.view.frame.size.width
            self.label.text = self.messages[index]
            
            UIView.transitionWithView(self.status, duration: 0.3, options: .CurveEaseOut | .TransitionCurlDown, animations: {
                self.status.hidden = false
                }, completion: {_ in
                    delay(seconds: 0.6, { () -> () in
                        if index < self.messages.count-1 {
                            self.showMessages(index: index+1)
                        }else {
                            self.resetButton()
                        }
                    })
            })
        }
    }
    
    // 弹簧收缩loginButton
    private func resetButton() {
        
        UIView.animateWithDuration(0.33, delay: 0.0, options: nil,
            animations: {
                
                self.spinner.center = CGPoint(x: -20, y: 16)
                self.spinner.alpha = 0.0
                
                
            }, completion: {_ in
                
                UIView.animateWithDuration(0.5, delay: 0.0,
                    usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options:
                    nil, animations: {
                        let b = self.loginButton.bounds
                        self.loginButton.bounds = CGRect(x: b.origin.x + 20, y:
                            b.origin.y, width: b.size.width - 80, height: b.size.height)
                        self.tintBackgroundColor(self.loginButton.layer, toColor: UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0))
                        self.roundCorners(self.loginButton.layer, toRadius: 10.0)
                        
                    }, completion:nil)
                
        })
        
        // 笔记： layer keyframe - 转动状态板
        let bounce = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        bounce.values = [0.0, -M_PI_4/2,0.0, M_PI_4/2,0.0]
        bounce.keyTimes = [0.0, 0.25, 0.5, 0.75]
        
        // 设置additive 属性为 YES 使 Core Animation 在更新 presentation layer 之前将动画的值添加到 model layer 中去。这使我们能够对所有形式的需要更新的元素重用相同的动画，且无需提前知道它们的位置
        bounce.additive = true
        bounce.repeatCount = 4
        
        status.layer.addAnimation(bounce, forKey: "wobble")
    }
    
    // 笔记：根据key，移除动画
    func didTapStatus() {
        if let wobble = status.layer.animationForKey("wobble") {
            status.layer.removeAnimationForKey("wobble")
        }
    }
    
    func animateCloud(cloud: UIImageView) {
        //animate clouds
        let cloudSpeed = 20.0 / Double(view.frame.size.width)
        let duration: NSTimeInterval = Double(view.frame.size.width - cloud.frame.origin.x) * cloudSpeed
        
        let cloudMove = CABasicAnimation(keyPath: "position.x")
        cloudMove.duration = duration
        cloudMove.toValue = self.view.bounds.size.width
        cloudMove.delegate = self
        cloudMove.setValue("cloud", forKey: "name")
        cloudMove.setValue(cloud, forKey: "view")
        cloud.layer.addAnimation(cloudMove, forKey: nil)
        
    }

    
}

