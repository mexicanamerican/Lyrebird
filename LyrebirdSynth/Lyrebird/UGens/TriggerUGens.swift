//
//  TriggerUGens.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 6/29/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

public typealias LyrebirdTriggerValueBlock = (_ triggerValue: LyrebirdFloat, _ counter: LyrebirdInt) -> LyrebirdFloat

open class TriggerUGens: LyrebirdUGen {
    var currentTriggerValue: LyrebirdFloat = 0.0
    var currentOutput: LyrebirdFloat = 0.0
    internal var trigger: LyrebirdValidUGenInput
    internal var counter: LyrebirdInt = 0
    
    public required init(rate: LyrebirdUGenRate, trigger: LyrebirdValidUGenInput = 0.0){
        self.trigger = trigger
        super.init(rate: rate)
    }
    
    internal func checkForTriggerSamples() -> [LyrebirdFloat]? {
        let triggerSampleArray = trigger.calculatedSamples(graph: graph)
        guard triggerSampleArray.count > 0 else {
            return nil
        }
        return triggerSampleArray[0] // TODO: fix up for multi-channel
    }
}

open class TriggerWithBlock: TriggerUGens {
    var triggerBlock: LyrebirdTriggerValueBlock?
    
    public required init(rate: LyrebirdUGenRate, trigger: LyrebirdValidUGenInput = 0.0, triggerBlock: LyrebirdTriggerValueBlock?) {
        super.init(rate: rate, trigger: trigger)
        self.triggerBlock = triggerBlock
        self.currentTriggerValue = trigger.floatValue(graph: graph)
    }
    
    public required convenience init(rate: LyrebirdUGenRate, trigger: LyrebirdValidUGenInput) {
        self.init(rate: rate, trigger: trigger, triggerBlock: nil)
    }
    
    override open func next(numSamples: LyrebirdInt) -> Bool {
        let success = super.next(numSamples: numSamples)
        if let triggerSamples = checkForTriggerSamples() {
            for sampleIdx: LyrebirdInt in 0 ..< numSamples {
                let nextTriggerSample = triggerSamples[sampleIdx]
                if currentTriggerValue <= 0 {
                    if nextTriggerSample > 0.0 {
                        currentTriggerValue = nextTriggerSample
                        if let triggerBlock = self.triggerBlock {
                            currentOutput = triggerBlock(currentTriggerValue, counter)
                            counter = counter + 1 // watch for overflow!
                        }
                    }
                }
                currentTriggerValue = nextTriggerSample
                samples[sampleIdx] = currentOutput
            }
            return success
        }
        return false
    }
}
