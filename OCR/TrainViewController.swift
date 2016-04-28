//
//  TrainViewController.swift
//  OCR
//
//  Created by Kevin Ayuque on 31/03/16.
//  Copyright © 2016 Kevin Ayuque. All rights reserved.
//

import UIKit

class TrainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    var b : [Int]!
    var w : [[Int]]!
    var character : [Int]!
    
    let threshold : Int = 0
    let categories : Int = 7
    var isLearning=true
    let inputWidth = 12
    let inputHeight = 12
    
    var chances = 3
    var category = 0
    
    @IBOutlet weak var learnButton: UIButton!
    @IBOutlet weak var exampleLabel: UILabel!
    
    @IBOutlet weak var characterCollectionView: UICollectionView!
    
    
    @IBOutlet weak var draw: DrawView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title="Perceptron"
        
        //STEP 0
        b = [Int](count: categories, repeatedValue: 0)
        w = [[Int]](count: inputWidth*inputHeight, repeatedValue: [Int](count: categories, repeatedValue: 0))
        characterCollectionView.delegate = self
        characterCollectionView.dataSource = self
        characterCollectionView.layer.borderColor=UIColor.blackColor().CGColor
        characterCollectionView.layer.borderWidth = 1
        character = [Int](count: inputWidth * inputHeight, repeatedValue: -1)
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
        
        let croppedImage = self.cropImage(draw.image!, toRect: draw.boundingBox!)
        //let scaledImage = self.scaleImage(croppedImage, maxLength: 11)
        let scaledImage = self.scaleImage(croppedImage, maxLength: inputWidth, equalRatio:true)
        //let character = self.addBorderToImage(scaledImage)
        
        let pixels = toArray(scaledImage)
        
        self.character = bipolar(pixels)
        self.characterCollectionView.reloadData()
        
        self.clear(nil)
        
        if isLearning{
            let ogOutput = [Int](count: categories, repeatedValue: -1)
            var output = ogOutput
            output[category] = 1
            train(bipolar(pixels),output: output)
            
            chances -= 1
            if chances == 0{
                chances = 3
                category += 1
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
                    
                    //See final weight and bias
                    print(b)
                    print(w)
                    break
                }
            }
        }else{
            let result = classify(bipolar(pixels))
            interpretResult(result)
            print(result)
        }
        
    }
    
    func bipolar(array:[Float])->[Int]{
        var bipolarArray = [Int]()
        
        for i in array{
            //Using 100/255 as threshold
            if i == 0{
                bipolarArray.append(-1)
            }else{
                bipolarArray.append(1)
            }
        }
        return bipolarArray
    }
    
    func interpretResult(result:[Int]){
        
        var results = ""
        for i in 0 ... result.count - 1{
            if result[i] == 1 {
                switch(i){
                case 0:
                    results=results + "A "
                case 1:
                    results=results + "B "
                case 2:
                    results=results + "C "
                case 3:
                    results=results + "D "
                case 4:
                    results=results + "E "
                case 5:
                    results=results + "F "
                default:
                    results=results + "G "
                }
            }
            self.exampleLabel.text=results
        }

    }
    
    func train(input:[Int], output:[Int]){
        
        print("Training starts")
        print(output)
        var stoppingCondition = false
        var x = input
        var y_in=[Int](count: output.count, repeatedValue: 0)
        var y : [Int]!
        y = [Int](count: categories, repeatedValue: 0)
        
        var weightChanges:Int
        var epochs=0
        
        // STEP 1
        
        while stoppingCondition == false{
            epochs += 1
            weightChanges=0
            //STEP 2
            
            for i in 0 ... input.count - 1{
                for j in 0 ... output.count - 1{
                    var sum = 0
                    //STEP 4
                    
                    for i2 in 0 ... input.count - 1{
                        sum = sum + x[i2] * w[i2][j]
                    }
                    y_in[j]=b[j] + sum
                    
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
                
                for j in 0 ... output.count - 1{
                    
                    
                    if output[j] != y[j]{
                        b[j] = b[j] + output[j]
                        for i2 in 0 ... input.count - 1{
                            let old_w = w[i2][j]
                            w[i2][j] = w[i2][j] + output[j] * x[i2]
                            weightChanges += 1
                            /*if old_w != w[i2][j]{
                             weightChanges += 1
                             }*/
                        }
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
        var y_in=[Int](count: categories, repeatedValue: 0)
        var y : [Int]!
        y = [Int](count: categories, repeatedValue: 0)
        
        
            for j in 0 ... categories - 1{
                var sum = 0
                for i2 in 0 ... input.count - 1{
                    sum = sum + x[i2] * w[i2][j]
                }
                y_in[j]=b[j] + sum
                
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
      
        
        return y
    }
    
    private func cropImage(image: UIImage, toRect: CGRect) -> UIImage {
        let imageRef = CGImageCreateWithImageInRect(image.CGImage!, toRect)
        let newImage = UIImage(CGImage: imageRef!)
        return newImage
    }
    
    
    private func scaleImage(image:UIImage, maxLength:Int, equalRatio:Bool) -> UIImage{
        var size = CGSize()
        if equalRatio == false{
            size = CGSize(width: min(CGFloat(maxLength) * image.size.width / image.size.height, CGFloat(maxLength)), height: min(CGFloat(maxLength) * image.size.height / image.size.width, CGFloat(maxLength)))
        }else{
            size = CGSize(width: maxLength, height: maxLength)
        }
        let newRect = CGRectIntegral(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        image.drawInRect(newRect)
        let newImageRef = CGBitmapContextCreateImage(context)! as CGImage
        let newImage = UIImage(CGImage: newImageRef, scale: 1.0, orientation: UIImageOrientation.Up)
        UIGraphicsEndImageContext()
        return newImage

    }
    
    private func addBorderToImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: inputWidth, height: inputHeight))
        let white = UIImage(named: "white")!
        white.drawAtPoint(CGPointZero)
        image.drawAtPoint(CGPointMake((CGFloat(inputWidth) - image.size.width) / 2, (CGFloat(inputHeight) - image.size.height) / 2))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func toArray(image:UIImage)->[Float]{
        var pixelsArray = [Float]()
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let bytesPerRow = CGImageGetBytesPerRow(image.CGImage)
        let bytesPerPixel = (CGImageGetBitsPerPixel(image.CGImage) / 8)
        var position = 0
        for _ in 0..<Int(image.size.height) {
            for _ in 0..<Int(image.size.width) {
                let alpha = Float(data[position + 3])
                pixelsArray.append(alpha / 255)
                position += bytesPerPixel
            }
            if position % bytesPerRow != 0 {
                position += (bytesPerRow - (position % bytesPerRow))
            }
        }
        return pixelsArray
    }
    
    //Character array
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputWidth
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return inputHeight
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = characterCollectionView.dequeueReusableCellWithReuseIdentifier("pixel", forIndexPath: indexPath)
        cell.layer.borderColor=UIColor.blackColor().CGColor
        cell.layer.borderWidth = 0.5
        if character[(indexPath.section * inputWidth) + indexPath.row] == 1{
            cell.backgroundColor=UIColor.blackColor()
        }else{
            cell.backgroundColor=UIColor.whiteColor()
        }
        return cell
    }
    
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        var cellWidth:CGFloat!
        var cellHeight:CGFloat!
        
        cellWidth=characterCollectionView.frame.width/CGFloat(inputWidth)
        cellHeight=characterCollectionView.frame.width/CGFloat(inputHeight)
        let cellSize:CGSize = CGSizeMake(cellWidth, cellHeight)
        return cellSize
    }
}
