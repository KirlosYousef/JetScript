//
//  ScriptVM.swift
//  JetScript
//
//  Created by Kirlos Yousef on 17/12/2020.
//

import Foundation

/// Class to manage scripts execution and running functions.
class ScriptVM: ObservableObject {
    // MARK: - Variables
    @Published var output: [String] = []
    @Published var exitCode: Int32 = -1
    @Published var errorLineIndex: Int = -1
    @Published var timeEstimate: Int = 0
    @Published var allTime: Int = 0
    
    private let file: String = "JetScript.swift" // this is the file name which we will write to.
    private var fileURL: URL? = nil
    private var numberOfRuns: Int = 1
    private var errorOccurred: Bool = false
    
    private var timer: Timer?
    private var currentTimeCounter: Int = 0
    private var timeCountersArray: [Int] = []
    private var remainingRuns: Int = 0 {
        didSet{
            updateTimeEstimate() // After every run, update the timeEstimate value.
        }
    }
    
    // MARK: - Script Methods
    /**
     Executing the script will write it to a local file first, then run it.
     
     - parameter scriptCode: Script code to be executed.
     - parameter times: Number of times for the script to be executed.
     */
    func executeScript(_ scriptCode: String, times numberOfTimes: Int){
        output.removeAll()
        timeCountersArray.removeAll()
        errorOccurred = false
        remainingRuns = numberOfTimes
        numberOfRuns = numberOfTimes
        
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
                output.append("Error occurred while writing the script to a file!")
                output.append(error.localizedDescription)
                return
            }
        }
        
        while remainingRuns > 0 {
            if !errorOccurred{
                runScript()
            } else { break }
        }
    }
    
    /// Last step to run the script, handles any errors, gets the output and the exit code.
    private func runScript(){
        guard let fileURL = fileURL else { return }
        startTimer()
        
        let args = ["swift", fileURL.path]
        let cmd = "/usr/bin/env"
        let task = Process()
        
        task.launchPath = cmd
        task.arguments = args
        
        // Output pipe
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        let outHandle = outputPipe.fileHandleForReading
        
        // Error pipe
        let errPipe = Pipe()
        task.standardError = errPipe
        let errorHandle = errPipe.fileHandleForReading
        
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
                        self.errorOccurred = true
                    }
                }
            } else {
                self.output.append("Error decoding data: \(pipe.availableData)")
            }
        }
        
        task.launch()
        
        task.waitUntilExit()
        killTimer(self)
        remainingRuns -= 1
        let status = task.terminationStatus
        
        exitCode = status
    }
    
    // MARK: - Timer Methods
    
    private func startTimer(){
        timer = Timer.scheduledTimer(timeInterval:1, target:self, selector:#selector(processTimer), userInfo: nil, repeats: true)
    }
    
    /**
     Should be called every one second.
     
     # Operations #
     1. Increases `currentTimeCounter`
     2. If `timeEstimate`  > 0, decreases it by 1
     */
    @objc private func processTimer(){
        currentTimeCounter += 1
        if timeEstimate > 0{
            timeEstimate -= 1
        }
    }
    
    /**
     Kills the current timer.
     
     # Operations #
     1. Adds it to the `timeCountersArray`.
     2. Resets the `currentTimeCounter`.
     */
    private func killTimer(_ sender: AnyObject){
        timer?.invalidate()
        timer = nil
        timeCountersArray.append(currentTimeCounter)
        currentTimeCounter = 0
    }
    
    /// Updates the `timeEstimate` to finish all the tasks
    private func updateTimeEstimate(){
        if !timeCountersArray.isEmpty{
            let sum = timeCountersArray.reduce(0, +)
            let avg = sum / timeCountersArray.count
            timeEstimate = avg * remainingRuns
            updateAllTime(avg)
        }
    }
    
    // Updates the all time estimated for the progress bar
    private func updateAllTime(_ avg: Int){
        allTime = avg * numberOfRuns
    }
}
