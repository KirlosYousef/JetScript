//
//  Script.swift
//  JetScript
//
//  Created by Kirlos Yousef on 17/12/2020.
//

import Foundation

/// Class to manage scripts execution and running functions.
class Script: ObservableObject {
    @Published var output: [String] = []
    @Published var exitCode: Int32 = -1
    private let file: String = "JetScript.swift" // this is the file name which we will write to.
    private var fileURL: URL? = nil
    private var numberOfTimes: Int = 1
    private var errorOccured: Bool = false
    
    /**
     Executing the script will wirte it to a local file first, then run it
     
     - parameter scriptCode: Script code to be executed.
     - parameter times: Number of times for the script to be executed.
     */
    func executeScript(_ scriptCode: String, times numberOfTimes: Int){
        output.removeAll()
        errorOccured = false
        self.numberOfTimes = numberOfTimes
        
        // replace any wrong marks
        let fixedScript = scriptCode.replacingOccurrences(of: "“", with: "\"")
            .replacingOccurrences(of: "”", with: "\"")
            .replacingOccurrences(of: "…", with: "...")
        
        writeToFile(scriptCode: fixedScript)
    }
    
    /// Writes the script to a local file to execute it later.
    private func writeToFile(scriptCode: String){
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            fileURL = dir.appendingPathComponent(file)
            
            //writing
            do {
                try scriptCode.write(to: fileURL!, atomically: false, encoding: .utf8)
            }
            catch {
                self.output.append("Error occured while writing the script to a file!")
                self.output.append(error.localizedDescription)
                return
            }
        }
        
        for _ in 1...numberOfTimes{
            if !errorOccured{
                runScript()
            } else { break }
        }
    }
    
    /// Last step to run the script, handles any errors, gets the output and the exit code.
    private func runScript(){
        guard let fileURL = self.fileURL else { return }
        
        let args = ["swift", fileURL.path]
        let cmd = "/usr/bin/env"
        let task = Process()
        
        task.launchPath = cmd
        task.arguments = args
        
        // Output pipe
        let pipe = Pipe()
        task.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        
        // Error pipe
        let errpipe = Pipe()
        task.standardError = errpipe
        let errorHandle = errpipe.fileHandleForReading
        
        // Output handling
        outHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                if !line.isEmpty{
                    DispatchQueue.main.async {
                        self.output.append(line)
                    }
                }
            } else {
                self.output.append("Error decoding data: \(pipe.availableData)")
            }
        }
        
        // Error handling
        errorHandle.readabilityHandler = { pipe in
            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
                if !line.isEmpty{
                    DispatchQueue.main.async {
                        self.output.append(line)
                        self.errorOccured = true
                    }
                }
            } else {
                self.output.append("Error decoding data: \(pipe.availableData)")
            }
        }
        
        task.launch()
        
        task.waitUntilExit()
        
        let status = task.terminationStatus
        
        exitCode = status
    }
}
