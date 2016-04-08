//
//  TrainViewController.swift
//  OCR
//
//  Created by Kevin Ayuque on 31/03/16.
//  Copyright © 2016 Kevin Ayuque. All rights reserved.
//

import UIKit

class TrainViewController: UIViewController {

    
    var b : [Int]!
    
    var w : [[Int]]!
    let threshold : Int = 0
    let categories : Int = 7
    var isLearning=true
    
    @IBOutlet weak var learnButton: UIButton!
    var chances = 3
    var category = 0
    
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var draw: DrawView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title="Perceptron"
        
        b = [Int](count: categories, repeatedValue: 0)
        
        w = [[Int]](count: 144, repeatedValue: [Int](count: categories, repeatedValue: 0))
        
        // print(w)
        
        //var inputN = 100
        //var outputN = 5
        
         //threshold = 0
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func clear(sender: AnyObject?) {
        draw.clear()
        draw.boundingBox = nil
    }
    @IBAction func learn(sender: AnyObject) {
        
        var pixelsArray = [Float]()
        
        
        // Extract drawing from canvas and remove surrounding whitespace
        let croppedImage = self.cropImage(draw.image!, toRect: draw.boundingBox!)
        // Scale character to max 20px in either dimension
        let scaledImage = self.scaleImage(croppedImage, maxLength: 10)
        // Center character in 28x28 white box
        let character = self.addBorderToImage(scaledImage)
        
        //let character = scaledImage
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(character.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerRow = CGImageGetBytesPerRow(character.CGImage)
        let bytesPerPixel = (CGImageGetBitsPerPixel(character.CGImage) / 8)
        var position = 0
        for _ in 0..<Int(character.size.height) {
            for _ in 0..<Int(character.size.width) {
                let alpha = Float(data[position + 3])
                pixelsArray.append(alpha / 255)
                position += bytesPerPixel
            }
            if position % bytesPerRow != 0 {
                position += (bytesPerRow - (position % bytesPerRow))
            }
        }
        //return pixelsArray

        
        print("hi")
        print(pixelsArray)
        print(bipolar(pixelsArray))
        self.clear(nil)
        
        if isLearning{
            var ogOutput = [Int](count: 7, repeatedValue: -1)
            var output = ogOutput
            output[category] = 1
            train(bipolar(pixelsArray),output: output)
            
            chances--
            if chances == 0{
                chances = 3
                category++
                switch(category){
                case 0:
                    self.exampleLabel.text="A"
                case 1:
                    self.exampleLabel.text="B"
                case 2:
                    self.exampleLabel.text="C"
                case 3:
                    self.exampleLabel.text="D"
                case 4:
                    self.exampleLabel.text="E"
                case 5:
                    self.exampleLabel.text="F"
                case 6:
                    self.exampleLabel.text="G"
                default:
                    learnButton.setTitle("Classify", forState: .Normal)
                    exampleLabel.text=""
                    isLearning = false
                    break
                    //STOP
                }
            }
        }else{
            let result = classify(bipolar(pixelsArray))
            print(result)
        }
        
    }
    
    func bipolar(array:[Float])->[Int]{
        var bipolarArray = [Int]()
        
        for i in array{
            if i == 0{
                bipolarArray.append(-1)
            }else{
                bipolarArray.append(1)
            }
        }
        return bipolarArray
    }
    
    func train(input:[Int], output:[Int]){
        
        print("Training starts")
        var stoppingCondition = false
        var x = input
        var y_in=[Int](count: output.count, repeatedValue: 0)
        var y : [Int]!
        y = [Int](count: categories, repeatedValue: 0)
        
        var weightChanges:Int
        var epochs=0
        while stoppingCondition == false{
            epochs++
            weightChanges=0
            for i in 0 ... input.count - 1{
                for j in 0 ... output.count - 1{
                    var sum = 0
                    //print(j)
                    for i2 in 0 ... input.count - 1{
                        sum = sum + x[i2] * w[i2][j]
                    }
                    y_in[j]=b[j] + sum
                    
                    //print(y_in[j])
                    switch(y_in[j]){
                    case _ where y_in[j] > threshold:
                        y[j] = 1
                        break
                    case _ where y_in[j] < -threshold:
                        y[j] = -1
                        break
                    default:
                        y[j] = 0
                        break
                    }
                    //print(y[j])
                    
                    //for j for i
                    if output[j] != y[j]{
                        weightChanges++
                        b[j] = b[j] + output[j]
                        w[i][j] = w[i][j] + output[j] * x[i]
                    }
                }
            }
            if weightChanges == 0 {
                stoppingCondition = true
            }
        }
        print("Training complete. \(epochs) epochs")
    }
    
    func classify(input:[Int])->[Int]{
        var x = input
        var y_in=[Int](count: 7, repeatedValue: 0)
        var y : [Int]!
        y = [Int](count: categories, repeatedValue: 0)
        
        
        
            for j in 0 ... 7 - 1{
                var sum = 0
                //print(j)
                for i2 in 0 ... input.count - 1{
                    sum = sum + x[i2] * w[i2][j]
                }
                y_in[j]=b[j] + sum
                
                //print(y_in[j])
                switch(y_in[j]){
                case _ where y_in[j] > threshold:
                    y[j] = 1
                    break
                case _ where y_in[j] < -threshold:
                    y[j] = -1
                    break
                default:
                    y[j] = 0
                    break
                }
            }
        //print(y_in)
        
        return y
    }
    
    private func cropImage(image: UIImage, toRect: CGRect) -> UIImage {
        let imageRef = CGImageCreateWithImageInRect(image.CGImage!, toRect)
        let newImage = UIImage(CGImage: imageRef!)
        return newImage
    }
    
    
    private func scaleImage(image:UIImage, maxLength:Int) -> UIImage{
        let size = CGSize(width: min(CGFloat(maxLength) * image.size.width / image.size.height, CGFloat(maxLength)), height: min(CGFloat(maxLength) * image.size.height / image.size.width, CGFloat(maxLength)))
        let newRect = CGRectIntegral(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.Medium)
        image.drawInRect(newRect)
        let newImageRef = CGBitmapContextCreateImage(context)! as CGImage
        let newImage = UIImage(CGImage: newImageRef, scale: 1.0, orientation: UIImageOrientation.Up)
        UIGraphicsEndImageContext()
        return newImage

    }
    
    private func addBorderToImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 12, height: 12))
        let white = UIImage(named: "white")!
        white.drawAtPoint(CGPointZero)
        image.drawAtPoint(CGPointMake((12 - image.size.width) / 2, (12 - image.size.height) / 2))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func convertToMatrix(image:UIImage){
        
    }
}
