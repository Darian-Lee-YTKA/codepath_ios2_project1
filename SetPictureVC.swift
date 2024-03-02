//
//  SetPictureVC.swift
//  scavangerhunt
//
//  Created by Darian Lee on 3/1/24.
//

import UIKit
import PhotosUI
import MapKit

class SetPictureVC: UIViewController, PHPickerViewControllerDelegate, MKMapViewDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        // Get the selected image asset (we can grab the 1st item in the array since we only allowed a selection limit of 1)
        let result = results.first

        // Get image location
        // PHAsset contains metadata about an image or video (ex. location, size, etc.)
        guard let assetId = result?.assetIdentifier,
              let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
            return
        }

        print("📍 Image location coordinate: \(location.coordinate)")
        guard let provider = result?.itemProvider,
              // Make sure the provider can load a UIImage
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        // Load a UIImage from the provider
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

            // Handle any errors
            if let error = error {
              DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
            
            }

            // Make sure we can cast the returned object to a UIImage
            guard let image = object as? UIImage else { return }

            print("🌉 We have an image!")

            // UI updates should be done on main thread, hence the use of `DispatchQueue.main.async`
            DispatchQueue.main.async { [weak self] in

                // Set the picked image and location on the task
                self?.task!.photo = image
                self?.task!.photoLocation = location
                self?.task!.done = true

                // Update the UI since we've updated the task
                self?.updateUI(picture: image)

                // Update the map view since we now have an image an location
                self?.updateMapView()
                self?.tasks![(self?.taskIndex)!].done = true
            }
        }
    }
    
    var task: Task?
    
    @IBOutlet var taskTitle: UILabel!
    
    @IBOutlet var completedImageView: UIImageView!
    @IBOutlet var attachPhoto: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var taskcom: UILabel!
    @IBOutlet var taskDes: UILabel!
    var tasks: [Task]?
    var taskIndex: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.layer.cornerRadius = 12
        mapView.layer.borderColor = UIColor.black.cgColor
        mapView.layer.borderWidth = 1.5
        taskTitle.text = task?.title
        if let taskDescription = task?.description {
            taskDes.text = taskDescription
        } else {
            taskDes.text = "Description: N/A"
        }
        
        taskDes.text = task?.description
        if task?.done == false{
            taskcom.text = "incomplete"
        }
        else{
            taskcom.text = "complete"
        }
        mapView.delegate = self

        // Do any additional setup after loading the view.
    }
    @IBAction func didTapAttachPhotoButton(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            // Request photo library access
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized:
                    // The user authorized access to their photo library
                    // show picker (on main thread)
                    DispatchQueue.main.async {
                        self?.presentImagePicker()
                    }
                default:
                    // show settings alert (on main thread)
                    DispatchQueue.main.async {
                        // Helper method to show settings alert
                        self?.presentGoToSettingsAlert()
                    }
                }
            }
        } else {
            // Show photo picker
            presentImagePicker()
        }
        
        

    }
    private func presentImagePicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

        // Set the filter to only show images as options (i.e. no videos, etc.).
        config.filter = .images

        // Request the original file format. Fastest method as it avoids transcoding.
        config.preferredAssetRepresentationMode = .current

        // Only allow 1 image to be selected at a time.
        config.selectionLimit = 1

        // Instantiate a picker, passing in the configuration.
        let picker = PHPickerViewController(configuration: config)

        // Set the picker delegate so we can receive whatever image the user picks.
        picker.delegate = self

        // Present the picker.
        present(picker, animated: true)
        // TODO: Create, configure and present image picker.

    }
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SetPictureVC {

    /// Presents an alert notifying user of photo library access requirement with an option to go to Settings in order to update status.
    func presentGoToSettingsAlert() {
        let alertController = UIAlertController (
            title: "Photo Access Required",
            message: "In order to post a photo to complete a task, we need access to your photo library. You can allow access in Settings",
            preferredStyle: .alert)

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }

        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    private func updateUI(picture: UIImage) {

        

  
        let completedImage = picture
        completedImageView.image = completedImage
        
        completedImageView.layer.cornerRadius = 40
        

        
        if task!.done {
            self.view.backgroundColor = UIColor(red: 150/255, green: 200/255, blue: 100/255, alpha: 1)
        }
        if task?.done == false{
            taskcom.text = "incomplete"
        }
        else{
            taskcom.text = "complete"
        }
        
        mapView.isHidden = !task!.done
        attachPhoto.isHidden = task!.done
    }
    
    /// Show an alert for the given error
    private func showAlert(for error: Error? = nil) {
        let alertController = UIAlertController(
            title: "Oops...",
            message: "\(error?.localizedDescription ?? "Please try again...")",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)

        present(alertController, animated: true)
    }
    func updateMapView() {
        guard let imageLocation = task!.photoLocation else { return }

        // Get the coordinate from the image location. This is the latitude / longitude of the location.
        // https://developer.apple.com/documentation/mapkit/mkmapview
        let coordinate = imageLocation.coordinate

        // Set the map view's region based on the coordinate of the image.
        // The span represents the maps's "zoom level". A smaller value yields a more "zoomed in" map area, while a larger value is more "zoomed out".
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? ViewController {
            destinationViewController.tasks = tasks

            }
        }
    }
    

