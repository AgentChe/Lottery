//
//  ScanTicketRecongnizeDigitsDelegate.swift
//  Lottery
//
//  Created by Niiaz Khasanov on 7/2/24.
//

import UIKit
import VisionKit
import Vision
import CoreImage

extension CheckScanTicketViewController: EditTicketViewControllerDelegate {
    func updateSizeOfEditCell(numbersStringArray: [[String]]) {
        self.numbersStringArray = numbersStringArray
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension CheckScanTicketViewController: RecognizedTextDataSource {
    func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }
    
    func addRecognizedText(recognizedText: [VNRecognizedTextObservation]) {
        let maximumCandidates = 1
        for observation in recognizedText {
            guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
            let numbersOnly = candidate.string.filter { "0123456789".contains($0) }
            if !numbersOnly.isEmpty {
                transcript += numbersOnly
            }
        }
        print("Text recognized is:", transcript)
        if let ticket = ticket {
            fullfillNumbersStringArray(transcript: transcript, ticket: ticket)
        }
    }
}

extension CheckScanTicketViewController {
    func fullfillNumbersStringArray(transcript: String, ticket: Ticket) -> [[Int]] {
        if ticket.id != 6 {
            let numbersArray = convertStringToIntArray(transcript)
            if isDivisible(numbersArray.count, by: 12) {
                let numberOfRows = numbersArray.count / 12
                let twoDigitsArray = convertToTwoDigitArray(numbersArray)
                if ticket.id != 3 {
                    let numberTwoDimeArray = reshapeArray6CaseVert(twoDigitsArray, numberOfRows: numberOfRows)
                    print("Text recognized is: \(convertToFormattedStringArray(intArray: numberTwoDimeArray!)) ")
                    if let numberTwoDimeArray = numberTwoDimeArray {
                        self.ticket?.numbers = numberTwoDimeArray
                        numbersStringArray = convertToFormattedStringArray(intArray: numberTwoDimeArray)
                    } else {
                        presentRecognitionErrorAlert(on: self)
                    }
                } else {
                    let numberTwoDimeArray = reshapeArray6CaseHor(twoDigitsArray, numberOfRows: numberOfRows)
                    print("Text recognized is: \(convertToFormattedStringArray(intArray: numberTwoDimeArray!)) ")
                    if let numberTwoDimeArray = numberTwoDimeArray {
                        self.ticket?.numbers = numberTwoDimeArray
                        numbersStringArray = convertToFormattedStringArray(intArray: numberTwoDimeArray)
                    } else {
                        presentRecognitionErrorAlert(on: self)
                    }
                }
            } else {
                presentRecognitionErrorAlert(on: self)
            }
        }
        if ticket.id == 6 {
            let numbersArray = convertStringToIntArray(transcript)
            if isDivisible(numbersArray.count, by: 8) {
                let digitsStringArray = convertToTwoDigitArray(numbersArray)
                self.ticket?.numbers = [digitsStringArray.compactMap { Int($0) }]
                print("2by2 array: \(convertToFormattedStringArray(stringArray: digitsStringArray))")
                numbersStringArray = [convertToFormattedStringArray(stringArray: digitsStringArray)]
            } else {
                presentRecognitionErrorAlert(on: self)
            }
        }
        collectionView.reloadData()
        return [[]]
    }
    
    func convertToFormattedStringArray(stringArray: [String]) -> [String] {
        return stringArray.map { string in
            if let intValue = Int(string), intValue >= 0 && intValue < 10 {
                return String(format: "%02d", intValue)
            }
            return string
        }
    }
    
    func convertToFormattedStringArray(intArray: [[Int]]) -> [[String]] {
        return intArray.map { row in
            row.map { String(format: "%02d", $0) }
        }
    }
    
    func convertStringToIntArray(_ str: String) -> [Int] {
        return str.compactMap { $0.wholeNumberValue }
    }
    
    func isDivisible(_ dividend: Int, by divisor: Int) -> Bool {
        return dividend % divisor == 0
    }
    
    func presentRecognitionErrorAlert(on viewController: UIViewController) {
        let alert = UIAlertController(
            title: "ScanTicketRecongnizeDigitsDelegate.RecognitionError.Title".localized,
            message: "ScanTicketRecongnizeDigitsDelegate.RecognitionError.Message".localized,
            preferredStyle: .alert
        )
        
        let tryAgainAction = UIAlertAction(title: "ScanTicketRecongnizeDigitsDelegate.TryAgain".localized, style: .default) { _ in
            print("User tapped Try Again")
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(tryAgainAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func convertToTwoDigitArray(_ inputArray: [Int]) -> [String] {
        var resultArray: [String] = []
        
        if inputArray.count % 2 != 0 {
            print("The input array does not have an even number of elements.")
            return resultArray
        }
        
        for i in stride(from: 0, to: inputArray.count, by: 2) {
            let combinedNumber = String(format: "%d%d", inputArray[i], inputArray[i + 1])
            resultArray.append(combinedNumber)
        }
        
        return resultArray
    }
    
    func reshapeArray6CaseVert(_ input: [String], numberOfRows: Int) -> [[Int]]? {
        let integers = input.compactMap { Int($0) }
        let expectedNumberOfElements = numberOfRows * 6
        if integers.count != expectedNumberOfElements {
            print("Input array does not contain the correct number of elements.")
            return nil
        }
        var output = [[Int]]()
        for i in 0..<numberOfRows {
            var row = [Int]()
            for k in 0..<6 {
                row.append(k)
            }
            output.append(row)
        }
        for j in 0..<numberOfRows {
            for k in 0..<6 {
                output[j][k] = integers[k * numberOfRows + j]
                print(integers[k * numberOfRows + j], j, k, numberOfRows)
            }
        }
        return output
    }
    
    func reshapeArray6CaseHor(_ input: [String], numberOfRows: Int) -> [[Int]]? {
        let integers = input.compactMap { Int($0) }
        let expectedNumberOfElements = numberOfRows * 6
        if integers.count != expectedNumberOfElements {
            print("Input array does not contain the correct number of elements.")
            return nil
        }
        var output = [[Int]]()
        for i in 0..<numberOfRows {
            var row = [Int]()
            for k in 0..<6 {
                row.append(k)
            }
            output.append(row)
        }
        for i in 0..<numberOfRows {
            for j in 0..<6 {
                output[i][j] = integers[i * 6 + j]
            }
        }
        return output
    }
}
