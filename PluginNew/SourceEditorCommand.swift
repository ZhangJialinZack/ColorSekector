//
//  SourceEditorCommand.swift
//  PluginNew
//
//  Created by zhangjialin on 2016/12/12.
//  Copyright © 2016年 zhangjialin. All rights reserved.
//

import Foundation
import XcodeKit

// 将hexColor 转换为 RGB数值
func colorWithHexString(hex: String) -> (red:Float, green: Float, blue: Float) {
    var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
    if (cString.characters.count != 6) {
        return (0.0, 0.0, 0.0)
    }

    let rString = cString.substring(to: cString.index(cString.startIndex, offsetBy: 2))

    let tempStr = cString.substring(from: cString.index(cString.startIndex, offsetBy: 2))
    let gString = tempStr.substring(to: tempStr.index(tempStr.startIndex, offsetBy: 2))
    
    let bString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 4))
    var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
    
    Scanner(string: rString).scanHexInt32(&r)
    Scanner(string: gString).scanHexInt32(&g)
    Scanner(string: bString).scanHexInt32(&b)

    return (Float(r) / 255.0, Float(g) / 255.0, Float(b) / 255.0)
}

// 将hexColor 转换为 Swift Literal颜色
func literalColorWithHexString(hex: String) -> String {
    let rjb = colorWithHexString(hex: hex)
    let resultStr = "#colorLiteral(red: \(rjb.red), green: \(rjb.green), blue: \(rjb.blue), alpha: 1.0)"
    
    //  #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0
    return resultStr
}

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    // 实现插件按钮方法
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // 选中区域
        let selection: XCSourceTextRange = invocation.buffer.selections.firstObject as! XCSourceTextRange
        // 要插入的Literal颜色字符串，格式为: “#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0”
        let colorStr = literalColorWithHexString(hex: invocation.commandIdentifier)
        // 选中区域首行
        let startLine = selection.start.line
        // 选中区域最后一行
        let endLine = selection.end.line
        // 如果选中区域在同一行
        if startLine == endLine {
            // 获取当前行的文本
            let lineStr: String = invocation.buffer.lines.object(at: startLine) as! String
            // 找到选中的开始和结束索引
            let startIndex = lineStr.index(lineStr.startIndex, offsetBy: selection.start.column)
            let endIndex = lineStr.index(lineStr.startIndex, offsetBy: selection.end.column)
            // 设置索引范围
            let strRange: Range<String.Index> = startIndex..<endIndex
            // 替换该范围的字符串为 Literal颜色字符串
            let subStr = lineStr.replacingCharacters(in: strRange, with: literalColorWithHexString(hex: invocation.commandIdentifier))
            // 替换掉该行的文本为上面的 subStr
            invocation.buffer.lines.replaceObject(at: startLine, with: subStr)
        } else { // 如果选中区域不在同一行
            // 设置变量currenLine为选中区域最后一行
            var currenLine = endLine
            // 找到最后一行文本
            let lastlineStr: String = invocation.buffer.lines.object(at: endLine) as! String
            // 保留非选中区域的字符串
            let lastlineSubStr = lastlineStr.substring(from: lastlineStr.index(lastlineStr.startIndex, offsetBy: selection.end.column))
            // 从选中区域最后一行遍历到首行
            for _ in 0..<(endLine - startLine + 1 ) {
                // 如果当前行指向选中区域第一行
                if (currenLine == startLine) {
                    // 找到当前行文本
                    let lineStr: String = invocation.buffer.lines.object(at: currenLine) as! String
                    // 保留非选中区域的字符串
                    let subStr = lineStr.substring(to: lineStr.index(lineStr.startIndex, offsetBy: selection.start.column))
                    // 插入Literal颜色字符串 和 最后一行保留的字符串
                    let resStr = subStr + colorStr + lastlineSubStr
                    // 替换掉首行文本为 resStr
                    invocation.buffer.lines.replaceObject(at: currenLine, with: resStr)
                } else { // 不是第一行的情况 直接在数组中remove掉
                    invocation.buffer.lines.removeObject(at: currenLine)
                }
                // 滚到上一行
                currenLine -= 1
            }
        }
        
        // 设置光标为当前行最后的位置
        let currentStartLineStr = invocation.buffer.lines.object(at: startLine) as! String
        selection.start.column = currentStartLineStr.characters.count - 1
        selection.end.column = currentStartLineStr.characters.count - 1
        
        completionHandler(nil)
    }
}
