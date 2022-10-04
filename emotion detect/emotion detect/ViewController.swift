import UIKit
import CoreML

enum Emotion {
    case Angry
    case Disgust
    case Fear
    case Happy
    case sad
    case Surprise
    case Neutral
}



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var modelOutputLabel: UILabel!
    private let model = ios2()
    @IBOutlet weak var imageView: UIImageView!
    private let trainedImageSize = CGSize(width: 48, height: 48)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func takePhotoClicked(_ sender: Any) {
    
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func predict(image: UIImage) -> Emotion? {
        do {
            if let resizedImage = resize(image: image, newSize: trainedImageSize), let pixelBuffer = resizedImage.toCVPixelBuffer() {
                let prediction = try model.prediction(image: pixelBuffer)
                let value = prediction.output[0].intValue
                print(value)
                
                if value == 1{
                    return .Angry
                }
                if value == 2 {
                    return .Disgust
                }
                if value == 3 {
                    return .Fear
                }
                if value == 4 {
                    return .Happy
                }
                if value == 5 {
                    return .sad
                }
                if value == 6 {
                    return .Surprise
                }
                else{
                    return .Neutral
                }
            }
        } catch {
            print("Error while doing predictions: \(error)")
        }

        return nil
    }

    func resize(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let emotion = self.predict(image: image)
                
                self.imageView.image = image
                

                if let emotion = emotion{
                    if emotion == .Angry{
                        self.modelOutputLabel.text = "Angry"
                    }
                    else if emotion == .Disgust{
                        self.modelOutputLabel.text = "Disgust"
                    }
                    else if emotion == .Fear{
                        self.modelOutputLabel.text = "Fear"
                    }
                    else if emotion == .Happy{
                        self.modelOutputLabel.text = "Happy"
                    }
                    else if emotion == .sad{
                        self.modelOutputLabel.text = "Sad"
                    }
                    else if emotion == .Surprise{
                        self.modelOutputLabel.text = "Surprise"
                    }
                    else if emotion == .Neutral{
                        self.modelOutputLabel.text = "Neutral"
                    }
                    
                }
                else{
                    self.modelOutputLabel.text = "No emotions"
                }
            }
        }
    }
}

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
