//
//  MediaPicker.swift
//  MizanEstateAgents
//
//  Created by Rohit Singh Dhakad on 07/04/23.
//

import Foundation
import UIKit
import AVFoundation
import Photos

class MediaPicker: NSObject {
    
    static let shared = MediaPicker()
    private override init() {}
    
    private var completion: ((UIImage?) -> Void)?
    
    func pickMedia(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        
        let alertController = UIAlertController(title: "Select media", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take photo", style: .default) { (_) in
            self.checkCameraPermission {
                DispatchQueue.main.async {
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.delegate = self
                    viewController.present(picker, animated: true, completion: nil)
                }
            }
        }
        let galleryAction = UIAlertAction(title: "Choose from library", style: .default) { (_) in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            viewController.present(picker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func checkCameraPermission(completion: @escaping () -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            completion()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    completion()
                }
            }
        case .denied, .restricted:
            let alertController = UIAlertController(title: "Camera permission required", message: "Please grant permission to access the camera", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            guard let topViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController?.topViewController() else {
                fatalError("Unable to get top view controller.")
            }
            topViewController.present(alertController, animated: true, completion: nil)
        @unknown default:
            break
        }
    }
}

extension MediaPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            completion?(nil)
            return
        }
        
        completion?(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        completion?(nil)
    }
}

extension UIViewController {
    func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
            let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topViewController: UIViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
}
