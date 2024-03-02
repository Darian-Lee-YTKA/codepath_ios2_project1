//
//  task.swift
//  scavangerhunt
//
//  Created by Darian Lee on 2/29/24.
//

import Foundation
import UIKit
import CoreLocation
struct Task {
    let title: String
    var done: Bool
    let description: String
    var photo: UIImage?
    var photoLocation: CLLocation?
}
                
