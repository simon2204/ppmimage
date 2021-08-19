//
// Created by Richard on 19.08.2021.
//

import Foundation

/// Dieses Struct liefert Informationen zum übergebenen PPM Image.
public struct PPMImage {
    /// Format des Bildes.
    public let format: Format
    /// Breite des Bildes.
    public let width: Int
    /// Höhe des Bildes.
    public let height: Int
    /// Werteskala der Farbintensitäten.
    public let maxColorValue: Int
    /// Zwischenspeicher für Pixeldaten.
    fileprivate(set) var pixelData: Data

    public init(format: Format = .p6, width: Int, height: Int, maxColorValue: Int) {
        self.format = format
        self.width = width
        self.height = height
        self.maxColorValue = maxColorValue
        pixelData = Data(count: width * height * 3)
    }

    /// Erstellt ein neues `PPMImage` Objekt, aus übergebenen PPM Dateiformat.
    /// - Parameter data: PPM Image Data
    public init(_ data: Data) throws {
        let splitData = data.split(maxSplits: 4) { byte in
            return CharacterSet.whitespacesAndNewlines.contains(UnicodeScalar(byte))
        }
        
        guard splitData.count == 5 else {
            throw PPMImageError.unknownPPMImageFormat
        }
        
        let formatData = splitData[0]
        let widthData = splitData[1]
        let heightData = splitData[2]
        let maxColorValueData = splitData[3]
        let pixelData = Data(splitData[4])
        
        guard let formatString = String(data: formatData, encoding: .utf8) else {
            throw PPMImageError.unknownPPMImageFormat
        }
        
        guard let format = Format(rawValue: formatString) else {
            throw PPMImageError.unknownPPMImageFormat
        }
        
        guard let width = Int(widthData) else {
            throw PPMImageError.unknownImageWidth
        }
        
        guard let height = Int(heightData) else {
            throw PPMImageError.unknownImageWidth
        }
        
        guard let maxColorValue = Int(maxColorValueData) else {
            throw PPMImageError.unknownImageWidth
        }
        
        guard pixelData.count % 3 == 0 else {
            throw PPMImageError.unknownPPMImageFormat
        }
        
        self.format = format
        self.width = width
        self.height = height
        self.maxColorValue = maxColorValue
        self.pixelData = pixelData
    }
}

public extension PPMImage {
    enum Format: String {
        case p6 = "P6"
    }
}

public extension PPMImage {
    struct Pixel {
        let red: UInt8
        let green: UInt8
        let blue: UInt8
    }
}

public extension PPMImage {
    enum PPMImageError: Error {
        /// Wird geworfen, wenn das uebergebene Format nicht mit PPM uebereinstimmt.
        case unknownPPMImageFormat
        /// Wird geworfen, wenn die Breite des PPM Bildes nicht ermittelt werden konnte.
        case unknownImageWidth
        /// Wird geworfen, wenn die Höhe des PPM Bildes nicht ermittelt werden konnte.
        case unknownImageHeight
        /// Wird geworfen, wenn die Werteskala des PPM Bildes nicht ermittelt werden konnte.
        case unknownMaximumColorValue
    }
}

extension PPMImage: RandomAccessCollection {
    public var startIndex: Int {
        pixelData.startIndex
    }

    public var endIndex: Int {
        pixelData.endIndex / 3
    }
    
    public subscript(position: Int) -> Pixel {
        get {
            let offset = position * 3
            let red = pixelData[offset]
            let green = pixelData[offset + 1]
            let blue = pixelData[offset + 2]
            return Pixel(red: red, green: green, blue: blue)
        }

        set {
            let offset = position * 3
            pixelData[offset] = newValue.red
            pixelData[offset + 1] = newValue.green
            pixelData[offset + 2] = newValue.blue
        }
    }
}

extension PPMImage: CustomStringConvertible {
    public var description: String {
        "PPMImage(format: \(format.rawValue), width: \(width), height: \(height), maxColorValue: \(maxColorValue), pixels: \(pixelData.count / 3))"
    }
}

public extension Data {
    init(_ ppmImage: PPMImage) {
        var data = [ppmImage.format.rawValue,
                    "\n", "\(ppmImage.width)",
                    "\n", "\(ppmImage.height)",
                    "\n", "\(ppmImage.maxColorValue)",
                    "\n"]
                    .map { $0.data(using: .utf8)! }
                    .reduce(Data(), +)
        data.append(ppmImage.pixelData)
        self = data
    }
}
