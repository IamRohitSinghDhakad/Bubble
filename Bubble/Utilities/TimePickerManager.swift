//
//  TimePickerManager.swift
//  CareTaker
//
//  Created by Dhakad on 11/07/23.
//

import Foundation
import UIKit

import UIKit

protocol TimePickerDelegate: AnyObject {
    func didSelectTime(time: String)
}

class TimePickerManager: NSObject {
    weak var delegate: TimePickerDelegate?
    private var viewController: UIViewController?
    private var selectedTime: String?
    
    func openTimePicker(from viewController: UIViewController) {
        self.viewController = viewController
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(handleTimePickerValueChanged(sender:)), for: .valueChanged)
        
        let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(timePicker)
        
        let doneAction = UIAlertAction(title: "Done", style: .default) { _ in
            if let time = self.selectedTime {
                self.delegate?.didSelectTime(time: time)
            }
            self.viewController = nil
        }
        
        alertController.addAction(doneAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc private func handleTimePickerValueChanged(sender: UIDatePicker) {
        print(sender.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.current // Set to local time zone
        let timeString = formatter.string(from: sender.date)
        
        selectedTime = timeString
    }
}
