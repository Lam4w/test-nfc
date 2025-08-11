import Foundation

// MARK: - TLV Data Types

/// Flat parsed tags storage
typealias QRTagMap = [String: String]

// MARK: - TLV Parser

struct TLVParser {
    
    /// Parse QR/NFC TLV data into a flat tag map
    /// - Parameter qrData: The TLV data string to parse
    /// - Returns: A dictionary mapping tag strings to their values
    static func parseQrDataFlat(_ qrData: String) -> QRTagMap {
        print("Parsing QR Data (flat): \(qrData)")
        var tagMap: QRTagMap = [:]
        var i = qrData.startIndex
        
        while i < qrData.endIndex {
            guard qrData.distance(from: i, to: qrData.endIndex) >= 4 else { break }
            
            let tag = String(qrData[i..<qrData.index(i, offsetBy: 2)])
            i = qrData.index(i, offsetBy: 2)
            
            let length = Int(qrData[i..<qrData.index(i, offsetBy: 2)]) ?? 0
            i = qrData.index(i, offsetBy: 2)
            
            guard qrData.distance(from: i, to: qrData.endIndex) >= length else { break }
            
            let value = String(qrData[i..<qrData.index(i, offsetBy: length)])
            i = qrData.index(i, offsetBy: length)
            
            tagMap[tag] = value
            
            // If these tags contain sub-TLV data, parse them flat as well
            if tag == "38" || tag == "62" || tag == "64" {
                let subTags = parseSubFieldsFlat(value, parentTag: tag)
                // Merge sub-tags into main map (key prefixed with parentTag)
                for (subTag, subValue) in subTags {
                    tagMap["\(tag)_\(subTag)"] = subValue
                }
            }
        }
        
        print("Parsed Flat Tag Map: \(tagMap)")
        return tagMap
    }
    
    /// Parse sub-fields within a TLV value
    /// - Parameters:
    ///   - data: The sub-field data to parse
    ///   - parentTag: The parent tag for context
    /// - Returns: A dictionary of sub-tag to value mappings
    static func parseSubFieldsFlat(_ data: String, parentTag: String = "") -> QRTagMap {
        var fields: QRTagMap = [:]
        var i = data.startIndex
        
        while i < data.endIndex {
            guard data.distance(from: i, to: data.endIndex) >= 4 else { break }
            
            let tag = String(data[i..<data.index(i, offsetBy: 2)])
            i = data.index(i, offsetBy: 2)
            
            let length = Int(data[i..<data.index(i, offsetBy: 2)]) ?? 0
            i = data.index(i, offsetBy: 2)
            
            guard data.distance(from: i, to: data.endIndex) >= length else { break }
            
            let value = String(data[i..<data.index(i, offsetBy: length)])
            i = data.index(i, offsetBy: length)
            
            fields[tag] = value
            
            // For deeply nested case: 38 -> 01
            if parentTag == "38" && tag == "01" {
                let deeperTags = parseSubFieldsFlat(value, parentTag: "38_01")
                for (subTag, subValue) in deeperTags {
                    fields["\(tag)_\(subTag)"] = subValue
                }
            }
        }
        
        return fields
    }
    
    /// Helper function to get value for a specific tag from the tag map
    /// - Parameters:
    ///   - tagMap: The parsed tag map
    ///   - tag: The tag to look up
    /// - Returns: The value associated with the tag, if found
    static func getTagValue(from tagMap: QRTagMap, tag: String) -> String? {
        return tagMap[tag]
    }
}
