//
//  SampleSwipeableCard.swift
//  Swipeable-View-Stack
//
//  Created by Phill Farrugia on 10/21/17.
//  Copyright © 2017 Phill Farrugia. All rights reserved.
//

import UIKit
import CoreMotion
import Firebase
import FirebaseAuth
import FirebaseStorage

class SampleSwipeableCard: SwipeableCardViewCard {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var addButton: UIView!

    @IBOutlet weak var skillsLabel: UILabel!
    @IBOutlet weak var wantedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet private weak var availabilityLabel: UILabel!
    @IBOutlet private weak var coursesLabel: UILabel!
    @IBOutlet private weak var imageBackgroundColorView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var backgroundContainerView: UIView!
    
    var uid = ""

    /// Core Motion Manager
    private let motionManager = CMMotionManager()

    /// Shadow View
    private weak var shadowView: UIView?

    /// Inner Margin
    private static let kInnerMargin: CGFloat = 20.0

    var viewModel: User? {
        didSet {
            configure(forViewModel: viewModel)
        }
    }

    private func configure(forViewModel viewModel: User?) {
        if let viewModel = viewModel {
            titleLabel.text = viewModel.firstName
            subtitleLabel.text = viewModel.year
            imageBackgroundColorView.backgroundColor = viewModel.color
            availabilityLabel.text = viewModel.availability
            coursesLabel.text = viewModel.coursesTaken
            uid = viewModel.uid
            skillsLabel.text = viewModel.skills
            descriptionLabel.text = viewModel.description
            wantedLabel.text = viewModel.wantedCourses
            imageView.backgroundColor = UIColor.gray
            getProfilePic()

            backgroundContainerView.layer.cornerRadius = 14.0
            addButton.layer.cornerRadius = addButton.frame.size.height/4
        }
    }
    
    func getProfilePic() {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        
        // Reference to an image file in Firebase Storage
        let reference = storageRef.child((viewModel?.image)!)
        
        // Download in memory with a maximum allowed size of 4MB (4 * 1024 * 1024 bytes)
        reference.getData(maxSize: 4 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
                self.imageView.image = #imageLiteral(resourceName: "person-tab")
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.imageView.image = image
                // print(image)
                return
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        configureShadow()
    }

    // MARK: - Shadow

    private func configureShadow() {
        // Shadow View
        self.shadowView?.removeFromSuperview()
        let shadowView = UIView(frame: CGRect(x: SampleSwipeableCard.kInnerMargin,
                                              y: SampleSwipeableCard.kInnerMargin,
                                              width: bounds.width - (2 * SampleSwipeableCard.kInnerMargin),
                                              height: bounds.height - (2 * SampleSwipeableCard.kInnerMargin)))
        insertSubview(shadowView, at: 0)
        self.shadowView = shadowView

        // Roll/Pitch Dynamic Shadow
//        if motionManager.isDeviceMotionAvailable {
//            motionManager.deviceMotionUpdateInterval = 0.02
//            motionManager.startDeviceMotionUpdates(to: .main, withHandler: { (motion, error) in
//                if let motion = motion {
//                    let pitch = motion.attitude.pitch * 10 // x-axis
//                    let roll = motion.attitude.roll * 10 // y-axis
//                    self.applyShadow(width: CGFloat(roll), height: CGFloat(pitch))
//                }
//            })
//        }
        self.applyShadow(width: CGFloat(0.0), height: CGFloat(0.0))
    }

    private func applyShadow(width: CGFloat, height: CGFloat) {
        if let shadowView = shadowView {
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 14.0)
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowRadius = 8.0
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: width, height: height)
            shadowView.layer.shadowOpacity = 0.15
            shadowView.layer.shadowPath = shadowPath.cgPath
        }
    }

}
