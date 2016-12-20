//
//  SourceEditorExtension.swift
//  PluginNew
//
//  Created by zhangjialin on 2016/12/12.
//  Copyright © 2016年 zhangjialin. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    var colorArray: NSArray = []
    
    func extensionDidFinishLaunching() {
        let filePath = Bundle.main.path(forResource: "Colors", ofType:"plist")
        colorArray = NSArray(contentsOfFile: filePath!)!
    }
    
    
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        var resArray: [[XCSourceEditorCommandDefinitionKey: String]] = []
        for colorDict in colorArray{
            let dict = colorDict as! Dictionary<String, String>
            let element = [XCSourceEditorCommandDefinitionKey.identifierKey: dict["color"]!,
                         XCSourceEditorCommandDefinitionKey.classNameKey: "PluginNew.SourceEditorCommand",
                         XCSourceEditorCommandDefinitionKey.nameKey: dict["colorName"]!]
            resArray.append(element)
        }
        
        return resArray
    }
}
