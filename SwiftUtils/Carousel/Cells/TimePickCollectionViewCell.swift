//
//  TimePickCollectionViewCell.swift
//  Ma-Ligne-C
//
//  Created by Drion Marvin on 02/04/2021.
//  Copyright © 2021 VSCT. All rights reserved.
//

import UIKit

final class TimePickCollectionViewCell: CarouselCell<TimePickerValue> {

    @IBOutlet fileprivate weak var timeLabel: UILabel!
    
    override func setup(item: CarouselItem<TimePickerValue>) {
        guard let timePickerValue = item.value else {
            timeLabel.text = nil
            return
        }
        
        if timePickerValue.isActual {
            timeLabel.text = Date().dateToString(format: DateFormat.hourMinute.rawValue)
        } else {
            timeLabel.text = timePickerValue.date.dateToString(format: DateFormat.hourMinute.rawValue)
        }
        
        if timePickerValue.isPast {
            timeLabel.textColor = .tmlPrimaryActionInactive
        } else {
            timeLabel.textColor = .tmlTextTitle
            timeLabel.highlightedTextColor = .tmlTextAlternative
        }
    }
}
