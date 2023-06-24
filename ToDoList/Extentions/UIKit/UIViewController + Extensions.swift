//
//  UIViewController + extensions.swift
//  First_App
//
//  Created by Alexey Shestakov on 14.03.2023.
//

import UIKit
import PhotosUI


extension UIViewController {
    
    func presentSimpleAlert(title: String, message: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    
    func presentAlertWithActions(title: String, message: String?, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Сохранить", style: .default) { _ in
            completionHandler()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    
    // Используем escaping, так как у нас кнопки на алерте и мы туда сохраняем действие
    // Замыкание принимает на вход камера/галлерея
    func presentAlertPhotoOrCamera(completionHandler: @escaping (UIImagePickerController.SourceType)->() ) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            completionHandler(.camera)
            
            /*
             Тут по сути написано это
             
             { source in
                SettingsViewController.chooseImage(source: source)
             }
             
             И это все сразу вызывается с подставлением АРГУМЕНТА .camera
             
             В source подставляется camera (то есть camera и есть source)
             */
        }
        let gallery = UIAlertAction(title: "gallery", style: .default) { _ in
            completionHandler(.photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(camera)
        alertController.addAction(gallery)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
