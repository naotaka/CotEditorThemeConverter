//
//  CotEditorThemeConverter
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Naotaka Morimoto
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa

// MARK: Constants

let outputFolderName = "Converted Themes"
let cotEditorThemeExtension = "cottheme"
let xcodeThemeExtension = "dvtcolortheme"

// MARK: Theme keys

let cotEditorThemeKeys: [String] = [
    "attributesColor",
    "backgroundColor",
    "charactersColor",
    "commandsColor",
    "commentsColor",
    "insertionPointColor",
    "invisiblesColor",
    "keywordsColor",
    "lineHighlightColor",
    "numbersColor",
    "selectionColor",
    "stringsColor",
    "textColor",
    "typesColor",
    "valuesColor",
    "variablesColor",
]

let xcodeThemeKeys: [String] = [
    "DVTSourceTextSyntaxColors/xcode.syntax.attribute",             // attributesColor
    "DVTSourceTextBackground",                                      // backgroundColor
    "DVTSourceTextSyntaxColors/xcode.syntax.character",             // charactersColor
    "DVTSourceTextSyntaxColors/xcode.syntax.identifier.class",      // commandsColor
    "DVTSourceTextSyntaxColors/xcode.syntax.comment",               // commentsColor
    "DVTSourceTextInsertionPointColor",                             // insertionPointColor
    "DVTSourceTextInvisiblesColor",                                 // invisiblesColor
    "DVTSourceTextSyntaxColors/xcode.syntax.keyword",               // keywordsColor
    "DVTSourceTextBackground",                                      // lineHighlightColor
    "DVTSourceTextSyntaxColors/xcode.syntax.number",                // numbersColor
    "DVTSourceTextSelectionColor",                                  // selectionColor
    "DVTSourceTextSyntaxColors/xcode.syntax.string",                // stringsColor
    "DVTSourceTextSyntaxColors/xcode.syntax.plain",                 // textColor
    "DVTSourceTextSyntaxColors/xcode.syntax.identifier.type",       // typesColor
    "DVTSourceTextSyntaxColors/xcode.syntax.identifier.constant",   // valuesColor
    "DVTSourceTextSyntaxColors/xcode.syntax.identifier.variable",   // variablesColor
]

// MARK: Extensions

/*
* This extension was originally written by
* NSColor+WFColorCode at https://github.com/1024jp/WFColorCode by 1024jp
*/
public enum WFColorCodeType {
    case WFColorCodeInvalid   // nil
    case WFColorCodeHex       // #ffffff
    case WFColorCodeShortHex  // #fff
    case WFColorCodeCSSRGB    // rgb(255,255,255)
    case WFColorCodeCSSRGBa   // rgba(255,255,255,1)
    case WFColorCodeCSSHSL    // hsl(0,0%,100%)
    case WFColorCodeCSSHSLa   // hsla(0,0%,100%,1)
}

extension NSColor {
    public func colorCodeWithType(codeType: WFColorCodeType) -> String? {
        var code: String? = nil

        let r: UInt8 = UInt8(roundf(Float(255 * self.redComponent)))
        let g: UInt8 = UInt8(roundf(Float(255 * self.greenComponent)))
        let b: UInt8 = UInt8(roundf(Float(255 * self.blueComponent)))
        let alpha: Double = Double(self.alphaComponent)

        switch codeType {
        case .WFColorCodeHex:
            code = String(format:"#%02x%02x%02x", r, g, b)
        case .WFColorCodeShortHex:
            // Not implemented
            break
        case .WFColorCodeCSSRGB:
            // Not implemented
            break
        case .WFColorCodeCSSRGBa:
            // Not implemented
            break
        case .WFColorCodeCSSHSL:
            // Not implemented
            break
        case .WFColorCodeCSSHSLa:
            // Not implemented
            break
        case .WFColorCodeInvalid:
            break
        default:
            break
        }

        return code
    }
}


/*
* This extension was originally written by
* NSColor+M3Extensions at https://github.com/mcubedsw/M3AppKit by Martin Pilkington
*/
extension NSColor {
    public func colorByAdjustingBrightness(brightness: CGFloat) -> NSColor {
        return NSColor(deviceHue: self.hueComponent, saturation: self.saturationComponent, brightness: self.brightnessComponent + brightness, alpha: self.alphaComponent)
    }
}


// MARK: Functions

func adjustColorBrightness(color: NSColor) -> NSColor {
    var brightness: CGFloat = 0.15
    
    if color.brightnessComponent > 0.5 {
        brightness *= -1
    }
    
    return color.colorByAdjustingBrightness(brightness)
}

func loadThemeFile(filePath: String) -> NSDictionary? {
    var error: NSError?
    let themePath = filePath.stringByExpandingTildeInPath
    let fileManager = NSFileManager()
    let isExist: Bool = fileManager.fileExistsAtPath(themePath)
    
    if isExist == false {
        println("No theme file was found.")
        return nil
    }
    
    let data: NSData? = NSData(
        contentsOfFile: themePath,
        options: NSDataReadingOptions.DataReadingUncached,
        error: &error)
    
    if data == nil {
        println("Failed to read the file: \(error)")
        return nil
    }
    
    let pList: NSDictionary? = NSPropertyListSerialization.propertyListWithData(
        data!,
        options: 0,
        format: nil,
        error: &error) as? NSDictionary
    
    if pList == nil {
        println("Failed to read the file: \(error)")
        return nil
    }
    
    return pList
}

func saveTheme(theme: Dictionary<String, AnyObject>, toPath path: String) -> Bool {
    var error: NSError?
    let serializedData: NSData? = NSJSONSerialization.dataWithJSONObject(
        theme,
        options: NSJSONWritingOptions.PrettyPrinted,
        error: &error)
    
    if serializedData == nil {
        println("Failed to serialize data: \(error)")
        return false
    }
    
    let destinationPath = path.stringByExpandingTildeInPath
    return serializedData!.writeToFile(destinationPath, atomically: true)
}

func convertXcodeThemeToCotEditor(xcodeTheme: NSDictionary) -> Dictionary<String, AnyObject>? {
    let syntaxColors = xcodeTheme["DVTSourceTextSyntaxColors"] as? [String:NSString]
    
    if syntaxColors == nil {
        println("This is not a valid xcode theme file.")
        return nil
    }
    
    var newTheme = [String:AnyObject]()
    newTheme["usesSystemSelectionColor"] = false
    
    for (index, key) in enumerate(cotEditorThemeKeys) {
        var xcodeKey = xcodeThemeKeys[index]
        var source = xcodeTheme
        let components = xcodeKey.componentsSeparatedByString("/")
        
        switch components.count {
        case 1:
            break
        case 2:
            xcodeKey = components[1] as String
            source = syntaxColors!
        default:
            println("This is not a valid xcode theme file.")
            return nil
        }
        
        let colorString: NSString = source[xcodeKey] as NSString
        let color = convertColorStringToColor(colorString)
        
        if color == nil {
            return nil
        }
        
        var hexColorCode = color!.colorCodeWithType(WFColorCodeType.WFColorCodeHex)

        if hexColorCode == nil {
            return nil
        }
        
        if key == "lineHighlightColor" {
            hexColorCode = adjustColorBrightness(color!).colorCodeWithType(WFColorCodeType.WFColorCodeHex)
        }
        
        newTheme[key] = hexColorCode
    }
    
    return newTheme
}

func convertColorStringToColor(colorString: NSString) -> NSColor? {
    let channelValues = colorString.componentsSeparatedByString(" ") as [NSString]
    
    var rgba: [CGFloat] = channelValues.map({
        (value:NSString) -> CGFloat in
        // 'String' does not have a member named 'doubleValue'
        return CGFloat(value.doubleValue)
    })
    
    switch rgba.count {
    case 3:
        rgba.append(CGFloat(1))
    case 4:
        // expected
        break
    default:
        println("Invalid color data format.")
        return nil
    }
    
    let color = NSColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3])
    
    return color
}

func setupOutputFolder() -> String? {
    var outputFolder = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
    outputFolder = outputFolder.stringByAppendingPathComponent(outputFolderName)
    
    let fileManager = NSFileManager()
    var isDirectory: ObjCBool = false
    
    if fileManager.fileExistsAtPath(outputFolder, isDirectory: &isDirectory) {
        if !isDirectory {
            println("\(outputFolderName) is not a directory.")
            return nil
        }
    }
    else {
        var error: NSError?
        let success: Bool = fileManager.createDirectoryAtPath(outputFolder, withIntermediateDirectories: true, attributes: nil, error: &error)
        
        if success == false {
            println("Failed to create output directory '\(outputFolderName)': \(error)")
            return nil
        }
    }
    
    return outputFolder
}

// MARK: - main

// MARK: Setup

let outputFolderPath: String? = setupOutputFolder()

if outputFolderPath == nil {
    exit(EXIT_FAILURE)
}

// MARK: Input

let arguments = Process.arguments

if arguments.count < 2 {
    let processInfo = NSProcessInfo.processInfo()
    println("Invalid number of arguments passed.\nUsage: \(processInfo.processName) </path/to/theme/file>")
    exit(EXIT_FAILURE)
}

for arg in dropFirst(arguments) {
    let sourceFilePath = arg
    let lastPathComponent = sourceFilePath.lastPathComponent
    let pathExtension = lastPathComponent.pathExtension
    
    println("Converting: \(lastPathComponent) ...")
    
    if pathExtension.caseInsensitiveCompare(xcodeThemeExtension) != NSComparisonResult.OrderedSame {
        println("'\(lastPathComponent)' is not a supported file type. Theme files must be end with '.\(xcodeThemeExtension)' extension.")
        continue
    }
    
    let fileName = lastPathComponent.stringByDeletingPathExtension
    let theme: NSDictionary? = loadThemeFile(sourceFilePath)
    
    if theme == nil {
        println("Failed to load the theme file.")
        continue
    }
    
    // MARK: Convert
    
    let convertedTheme: Dictionary? = convertXcodeThemeToCotEditor(theme!)
    
    if convertedTheme == nil || convertedTheme!.count < 1 {
        println("Failed to convert the theme.")
        continue
    }
    
    // MARK: Output
    
    let destinationPath = outputFolderPath!.stringByAppendingPathComponent("\(fileName).\(cotEditorThemeExtension)")
    let success: Bool = saveTheme(convertedTheme!, toPath: destinationPath)
    
    if success == false {
        println("Failed to save the theme file.")
        continue
    }
}

println("Done.")
