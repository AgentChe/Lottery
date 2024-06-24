//
//  ScanPrintOptionsViewController.swift
//  Printer
//
//  Created by Niiaz Khasanov on 5/24/24.
//


import UIKit

class ScanPrintOptionsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var imageRenderers: [CustomScanPrintPageRenderer] = []
    var previews: [UIImage] = []
    var copies: Int = 1
    var pagesPerSheet: Int = 1
    var options = ["Printer", "Copy", "Pages per Sheet"]

    private let topBarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Grabber"))
        imageView.alpha = 1.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let printOptionsTitle: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("PrintOptions.Title", comment: "Print Options")
        label.font = ScreenSize.isIphoneXFamily ? Fonts.Inter.bold(size: 24.scale) : Fonts.Inter.bold(size: 20.scale)
        label.textColor = Appearance.mono200 // Use Appearance.mono200
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10.scale
        layout.minimumInteritemSpacing = 10.scale
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10.scale, bottom: 0, right: 10.scale)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Appearance.mono100 // Use Appearance.mono100
        collectionView.layer.cornerRadius = 20.scale
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("PrintOptions.Preview", comment: "Preview")
        label.font = ScreenSize.isIphoneXFamily ? Fonts.Inter.bold(size: 24.scale) : Fonts.Inter.bold(size: 20.scale)
        label.textColor = Appearance.mono200 // Use Appearance.mono200
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let previewCollectionView: UICollectionView = {
        let layout = CenteredFlowLayoutForPreviewsCollectionView()
        layout.minimumLineSpacing = 10.scale
        layout.minimumInteritemSpacing = 10.scale
        layout.sectionInset = ScreenSize.isIphoneXFamily ? UIEdgeInsets(top: 0, left: (UIScreen.main.bounds.width - 154.scale) / 2, bottom: 0, right: (UIScreen.main.bounds.width - 154.scale) / 2) : UIEdgeInsets(top: 0, left: (UIScreen.main.bounds.width - (154*0.9).scale) / 2, bottom: 0, right: (UIScreen.main.bounds.width - (154*0.9).scale) / 2)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let printButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("PrintOptions.PrintButton", comment: "Print"), for: .normal)
        button.titleLabel?.font = Fonts.Inter.medium(size: 17.scale)
        button.backgroundColor = Appearance.signatureBlue // Use Appearance.signatureBlue
        button.setTitleColor(Appearance.mono100, for: .normal) // Use Appearance.mono100
        button.layer.cornerRadius = ScreenSize.isIphoneXFamily ?  24.scale : 18.scale
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePrintButton), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePrintButton() {
        if let printer = PrinterManager.shared.getConnectedPrinter() {
            for imageRenderer in imageRenderers {
                imageRenderer.pagesPerSheet = self.pagesPerSheet
                imageRenderer.copies = self.copies
                
                var resizedPhotos: [UIImage] = []
                for photo in imageRenderer.photos {
                    let maxDimension = max(photo.size.width, photo.size.height)
                    let targetSize: CGFloat
                    
                    switch self.pagesPerSheet {
                    case 1:
                        targetSize = 3000
                    case 2:
                        targetSize = 2000
                    case 4:
                        targetSize = 1200
                    case 6:
                        targetSize = 900
                    case 9:
                        targetSize = 600
                    case 16:
                        targetSize = 300
                    default:
                        targetSize = 3000
                    }
                    
                    let newSize: CGSize
                    if maxDimension > targetSize {
                        let scale = targetSize / maxDimension
                        newSize = CGSize(width: photo.size.width * scale, height: photo.size.height * scale)
                    } else {
                        newSize = photo.size
                    }
                    
                    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                    photo.draw(in: CGRect(origin: .zero, size: newSize))
                    let resizedPhoto = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    if let resizedPhoto = resizedPhoto {
                        resizedPhotos.append(resizedPhoto)
                    } else {
                        resizedPhotos.append(photo) // In case resizing fails, use the original photo
                    }
                }
                
                PrinterManager.shared.directScanPhotoUsingRenderer(from: self, printer: printer, copies: self.copies, pagesPerSheet: self.pagesPerSheet, images: resizedPhotos, renderer: imageRenderer)
            }
        } else {
            print("Printer is not configured or unavailable.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.mainViewBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PrinterOptionCell.self, forCellWithReuseIdentifier: PrinterOptionCell.identifier)
        collectionView.register(CopiesOptionCell.self, forCellWithReuseIdentifier: CopiesOptionCell.identifier)
        collectionView.register(PagesPerSheetOptionCell.self, forCellWithReuseIdentifier: PagesPerSheetOptionCell.identifier)
        previewCollectionView.delegate = self
        previewCollectionView.dataSource = self
        previewCollectionView.register(PreviewCell.self, forCellWithReuseIdentifier: PreviewCell.identifier)
        
        setupUI()
        generatePreviews()
    }
    
    private func setupUI() {
        view.addSubview(printOptionsTitle)
        view.addSubview(collectionView)
        view.addSubview(previewLabel)
        view.addSubview(previewCollectionView)
        view.addSubview(printButton)
        view.addSubview(topBarImageView)
        
        NSLayoutConstraint.activate([
            topBarImageView.widthAnchor.constraint(equalToConstant: 36.scale),
            topBarImageView.heightAnchor.constraint(equalToConstant: 5.scale),
            topBarImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 4.scale),
            topBarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            printOptionsTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24.scale),
            printOptionsTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            printOptionsTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            printOptionsTitle.heightAnchor.constraint(equalToConstant: 30.scale)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: printOptionsTitle.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 20.scale : 10.scale),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.scale),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.scale),
            collectionView.heightAnchor.constraint(equalToConstant: 293.scale)
        ])
        
        NSLayoutConstraint.activate([
            previewLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 20.scale : 5.scale ),
            previewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewLabel.widthAnchor.constraint(equalToConstant: 96.scale),
            previewLabel.heightAnchor.constraint(equalToConstant: 29.scale)
        ])
        
        NSLayoutConstraint.activate([
            previewCollectionView.topAnchor.constraint(equalTo: previewLabel.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 20.scale : 5.scale ),
            previewCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewCollectionView.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 226.scale : 177.scale)
        ])
        
        NSLayoutConstraint.activate([
            printButton.topAnchor.constraint(equalTo: previewCollectionView.bottomAnchor, constant: ScreenSize.isIphoneXFamily ? 5.scale : 10.scale),
            printButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            printButton.widthAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 358.scale : 330.scale),
            printButton.heightAnchor.constraint(equalToConstant: ScreenSize.isIphoneXFamily ? 66.scale : 56.scale)
        ])
    }
    
    private func generatePreviews() {
        previews.removeAll() // Clear existing previews
        for imageRenderer in imageRenderers {
            imageRenderer.pagesPerSheet = self.pagesPerSheet
            for image in imageRenderer.photos {
                let individualImageRenderer = CustomPhotoPrintPageRenderer()
                individualImageRenderer.pagesPerSheet = imageRenderer.pagesPerSheet
                individualImageRenderer.copies = imageRenderer.copies
                individualImageRenderer.photos = [image]
                
                let imageName: String
                switch self.pagesPerSheet {
                case 1:
                    imageName = "ImagePreview.1"
                case 2:
                    imageName = "ImagePreview.2"
                case 4:
                    imageName = "ImagePreview.4"
                case 6:
                    imageName = "ImagePreview.6"
                case 9:
                    imageName = "ImagePreview.9"
                case 16:
                    imageName = "ImagePreview.16"
                default:
                    imageName = "ImagePreview.1"
                }

                if let previewImage = UIImage(named: imageName) {
                    previews.append(previewImage)
                }
            }
        }
        previewCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.collectionView ? options.count : previews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            switch indexPath.row {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PrinterOptionCell.identifier, for: indexPath) as? PrinterOptionCell else {
                    return UICollectionViewCell()
                }
                if let currentlyConnectedPrinterURL = PrinterManager.shared.currentlyConnectedPrinterURL {
                    if let printerName = PrinterManager.shared.getPrinterName(for: currentlyConnectedPrinterURL) {
                        let cleanedPrinterName = printerName.filter { $0 != "\"" }
                        let truncatedPrinterName = String(cleanedPrinterName.prefix(10))
                        cell.configure(with: NSLocalizedString("PrintOptions.Printer", comment: "Printer"), detail: "\(truncatedPrinterName)", showArrow: false)
                        return cell
                    }
                }
                cell.configure(with: NSLocalizedString("PrintOptions.Printer", comment: "Printer"), detail: NSLocalizedString("PrintOptions.PrinterNotSelected", comment: "not selected"), showArrow: true)
                return cell
                
            case 1:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CopiesOptionCell.identifier, for: indexPath) as? CopiesOptionCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: NSLocalizedString("PrintOptions.Copy", comment: "Copy"), count: 1)
                cell.delegate = self
                return cell
                
            case 2:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagesPerSheetOptionCell.identifier, for: indexPath) as? PagesPerSheetOptionCell else {
                    return UICollectionViewCell()
                }
                cell.delegate = self
                return cell
                
            default:
                return UICollectionViewCell()
            }
        } else if collectionView == self.previewCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewCell.identifier, for: indexPath) as? PreviewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: previews[indexPath.row], pageNumber: indexPath.item + 1, totalPages: previews.count)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            if indexPath.row == 0 {
                let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
                printerPicker.present(animated: true) { [weak self] (printerPickerController, userDidSelect, error) in
                    if userDidSelect {
                        if let printer = printerPickerController.selectedPrinter {
                            print("Printer name: \(printer.displayName)")
                            print("Printer URL: \(printer.url)")
                            
                            let isFirstTimeSaved = PrinterManager.shared.isFirstTimePrinterSaved(printer.url)
                            PrinterManager.shared.savePrinter(url: printer.url, displayName: printer.displayName)
                            
                            PrinterManager.shared.connectToPrinter(with: printer.url) { printer, error in
                                if let printer = printer {
                                    self?.collectionView.reloadData()
                    
                                }
                                if let error = error {
                                    PrinterManager.shared.showAlertForErrorWithPrinter(printer?.displayName ?? "Unknown", viewController: self!)
                                    
                                    print("Error: \(error.localizedDescription)")
                                }
                            }
                        }
                    } else {
                        
                    }
                }
            } else {
                print("Selected Option: \(options[indexPath.row])")
            }
        } else if collectionView == self.previewCollectionView {
            print("Selected Preview: \(previews[indexPath.row])")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: 326.scale, height: indexPath.row == 2 ? 136.scale : 64.scale)
        } else if collectionView == self.previewCollectionView {
            return ScreenSize.isIphoneXFamily ? CGSize(width: 154.scale, height: 200.scale) : CGSize(width: 154*0.9.scale, height: 200*0.9.scale)
        }
        return CGSize.zero
    }
}

extension ScanPrintOptionsViewController: CopiesOptionCellDelegate {
    func copiesOptionCell(cell: CopiesOptionCell, didChangeCopiesTo count: Int) {
        self.copies = count
        print("Updated copies to \(count)")
    }
}

extension ScanPrintOptionsViewController: PagesPerSheetOptionCellDelegate {
    func pagesPerSheetOptionCell(cell: PagesPerSheetOptionCell, didChangePagesPerSheetTo pages: Int) {
        self.pagesPerSheet = pages
        print("Updated pages per sheet to \(pages)")
        generatePreviews() // Regenerate previews when pages per sheet option changes
    }
}


//
//  CenteredFlowLayoutForPreviewsCollectionView.swift
//  Printer
//
//  Created by Niiaz Khasanov on 5/13/24.
//

import UIKit
class CenteredFlowLayoutForPreviewsCollectionView: UICollectionViewFlowLayout {

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        let collectionViewBounds = collectionView.bounds
        let halfWidth = collectionViewBounds.size.width * 0.5
        let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth
        
        let layoutAttributesArray = self.layoutAttributesForElements(in: collectionViewBounds)

        var candidateAttributes: UICollectionViewLayoutAttributes?
        for attributes in layoutAttributesArray ?? [] {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if fabs(attributes.center.x - proposedContentOffsetCenterX) < fabs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        //because blinking buggy efffect occurs
        if let candidateAttributes = candidateAttributes {
            var newOffset = CGPoint(x: candidateAttributes.center.x - halfWidth, y: proposedContentOffset.y)
            print("newOffset: \(newOffset)")

            if newOffset.x <= 0 {
                newOffset.x = 0
            }
            if newOffset.x + ScreenSize.width >= collectionView.contentSize.width {
                newOffset.x = collectionView.contentSize.width - ScreenSize.width
            }
            
            scrollToContentOffset(collectionView: collectionView, mass: 1.0, stiffness: 400.0, damping: 3000.0, initialVelocity: CGVector(dx: velocity.x, dy: 0), targetOffset: newOffset)
             return newOffset
        } else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
    }

    private func scrollToContentOffset(collectionView: UICollectionView, mass: CGFloat, stiffness: CGFloat, damping: CGFloat, initialVelocity: CGVector, targetOffset: CGPoint) {
        let timingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.0, timingParameters: timingParameters)

        propertyAnimator.addAnimations {
            collectionView.setContentOffset(targetOffset, animated: false)
        }

        propertyAnimator.startAnimation()
    }
}

import UIKit

protocol PagesPerSheetOptionCellDelegate: AnyObject {
    func pagesPerSheetOptionCell(cell: PagesPerSheetOptionCell, didChangePagesPerSheetTo pages: Int)
}

class PagesPerSheetOptionCell: UICollectionViewCell {
    static let identifier = "PagesPerSheetOptionCell"
    weak var delegate: PagesPerSheetOptionCellDelegate?
    
    // UI Components
    let layout = UICollectionViewFlowLayout()
    let pagesPerSheetLabel = UILabel()
    var pagesPerSheetCollectionView: UICollectionView!
    
    // Data Source for Collection View
    let pagesOptions = [1, 2, 4, 6, 9, 16]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupLabels()
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabels() {
        // Set up the 'Pages per sheet' label
        pagesPerSheetLabel.text = NSLocalizedString("PegesPerSheetOptionCell.Title", comment: "Pages per sheet")
        pagesPerSheetLabel.font = Fonts.SFProDisplay.medium(size: 17.scale) // Custom font with .scale
        pagesPerSheetLabel.textAlignment = .left
        pagesPerSheetLabel.textColor = Appearance.black // Set text color to Appearance.black
        pagesPerSheetLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pagesPerSheetLabel)
    }
    
    func setupCollectionView() {
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 44.scale, height: 68.scale)
        layout.minimumInteritemSpacing = 12.scale
        layout.minimumLineSpacing = 12.scale
        
        pagesPerSheetCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        pagesPerSheetCollectionView.backgroundColor = .clear
        pagesPerSheetCollectionView.allowsMultipleSelection = false
        pagesPerSheetCollectionView.register(PagesPerSheetCell.self, forCellWithReuseIdentifier: "PagesPerSheetCell")
        pagesPerSheetCollectionView.delegate = self
        pagesPerSheetCollectionView.dataSource = self
        
        pagesPerSheetCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
        addSubview(pagesPerSheetCollectionView)
    }
    
    func layoutUI() {
        // Disabling autoresizing mask translation and setting up constraints
        pagesPerSheetLabel.translatesAutoresizingMaskIntoConstraints = false
        pagesPerSheetCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Pages per sheet label constraints
            pagesPerSheetLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10.scale),
            pagesPerSheetLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            pagesPerSheetLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            pagesPerSheetLabel.heightAnchor.constraint(equalToConstant: 20.scale),
            
            // Collection view constraints updated to be below the label
            pagesPerSheetCollectionView.topAnchor.constraint(equalTo: pagesPerSheetLabel.bottomAnchor, constant: 20.scale),
            pagesPerSheetCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pagesPerSheetCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pagesPerSheetCollectionView.heightAnchor.constraint(equalToConstant: 70.scale)
        ])
    }
}

extension PagesPerSheetOptionCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pagesOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells {
            if let customCell = cell as? PagesPerSheetCell {
                customCell.isSelected = false
            }
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? PagesPerSheetCell {
            cell.isSelected = true
            let selectedPages = pagesOptions[indexPath.item]
            delegate?.pagesPerSheetOptionCell(cell: self, didChangePagesPerSheetTo: selectedPages)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PagesPerSheetCell {
            cell.isSelected = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PagesPerSheetCell", for: indexPath) as? PagesPerSheetCell else {
            return UICollectionViewCell()
        }
        
        switch indexPath.item {
        case 0:
            cell.label.text = "1"
            cell.imageView.image = UIImage(named: "PagesPerSheet.1")
        case 1:
            cell.label.text = "2"
            cell.imageView.image = UIImage(named: "PagesPerSheet.2")
        case 2:
            cell.label.text = "4"
            cell.imageView.image = UIImage(named: "PagesPerSheet.4")
        case 3:
            cell.label.text = "6"
            cell.imageView.image = UIImage(named: "PagesPerSheet.6")
        case 4:
            cell.label.text = "9"
            cell.imageView.image = UIImage(named: "PagesPerSheet.9")
        case 5:
            cell.label.text = "16"
            cell.imageView.image = UIImage(named: "PagesPerSheet.16")
        default:
            fatalError()
        }
        
        return cell
    }
}
