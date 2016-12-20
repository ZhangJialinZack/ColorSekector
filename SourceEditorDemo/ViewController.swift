//
//  ViewController.swift
//  SourceEditorDemo
//
//  Created by zhangjialin on 2016/12/12.
//  Copyright © 2016年 zhangjialin. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 直接执行简单的shell命令
//        Process.launchedProcess(launchPath: "/bin/sh", arguments: ["-c","count=10;count=`expr $count + 12`;echo $count"])

        // 首先找到脚本所在路径
        if let scriptPath = Bundle.path(forResource: "MtimeX_Pack", ofType: "sh", inDirectory: Bundle.main.resourcePath!) {
            // 创建任务
            let scriptTask = Process()
            // 创建pipe
            let pipe = Pipe()
            // 设置任务的错误和输出为pipe
            scriptTask.standardError = pipe
            scriptTask.standardOutput = pipe
            // 设置读取文件句柄
            let file = pipe.fileHandleForReading
            // 设置任务的启动路径 和 参数
            scriptTask.launchPath = "/bin/sh"
            scriptTask.arguments = [scriptPath]
            // 启动任务
            scriptTask.launch()
            // 将file中的内容读出并打印出来
            let data = file.readDataToEndOfFile()
            let resString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print(resString ?? "No result")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

