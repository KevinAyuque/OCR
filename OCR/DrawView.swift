//
//  DrawViewController.swift
//  OCR
//
//  Created by Kevin Ayuque on 30/03/16.
//  Copyright © 2016 Kevin Ayuque. All rights reserved.
//

import UIKit

class DrawView: UIImageView {

    //@IBOutlet weak var tempImageView: UIImageView!
    var lastPoint = CGPointZero
    //var red: CGFloat = 0.0
    //var green: CGFloat = 0.0
    //var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 10.0
    //var opacity: CGFloat = 1.0
    var swiped = false
    
    var boundingBox: CGRect?
    
    /*override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }*/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped=false
        guard let touch = touches.first else {
            return
        }
        
        lastPoint = touch.locationInView(self)
        let location = touch.locationInView(self)
        if self.boundingBox == nil {
            self.boundingBox = CGRect(x: location.x - self.brushWidth / 2,
                y: location.y - self.brushWidth / 2,
                width: self.brushWidth,
                height: self.brushWidth)
        }
        
        
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()
        self.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        // 2
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        // 4
        CGContextStrokePath(context)
        
        // 5
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        //tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            
            if currentPoint.x < self.boundingBox!.minX {
                self.updateRect(&self.boundingBox!, minX: currentPoint.x - self.brushWidth - 20, maxX: nil, minY: nil, maxY: nil)
            } else if currentPoint.x > self.boundingBox!.maxX {
                self.updateRect(&self.boundingBox!, minX: nil, maxX: currentPoint.x + self.brushWidth + 20, minY: nil, maxY: nil)
            }
            if currentPoint.y < self.boundingBox!.minY {
                self.updateRect(&self.boundingBox!, minX: nil, maxX: nil, minY: currentPoint.y - self.brushWidth - 20, maxY: nil)
            } else if currentPoint.y > self.boundingBox!.maxY {
                self.updateRect(&self.boundingBox!, minX: nil, maxX: nil, minY: nil, maxY: currentPoint.y + self.brushWidth + 20)
            }
            //self.lastDrawPoint = currentPoint
            
            // 7
            lastPoint = currentPoint
        }

    }
    
    private func updateRect(inout rect: CGRect, minX: CGFloat?, maxX: CGFloat?, minY: CGFloat?, maxY: CGFloat?) {
        rect = CGRect(x: minX ?? rect.minX,
            y: minY ?? rect.minY,
            width: (maxX ?? rect.maxX) - (minX ?? rect.minX),
            height: (maxY ?? rect.maxY) - (minY ?? rect.minY))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        /*
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: kCGBlendModeNormal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil*/

    }
    
    func clear(){
        self.image=nil
    }
    /*
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
