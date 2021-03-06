//
//  LyrebirdGraph.swift
//  Lyrebird
//
//  Created by Joshua Parmenter on 5/3/16.
//  Copyright © 2016 Op133Studios. All rights reserved.
//

import Foundation

public typealias LyrebirdGraphConstructionClosure = () -> Void

/**
 Represents a single model for a synthesis graph. Create LyrebirdNotes to play an instance of a graph
 */

open class LyrebirdGraph {
    static var currentBuildingGraph: LyrebirdGraph? = nil
    
    /// ---
    /// the graph's children.
    ///
    /// graphs will iterate over their children in order to calculate samples
    
    open var children        : [LyrebirdUGen] = []
    // parameters act as args in a SynthDef
    open var parameters       : [String: LyrebirdValidUGenInput] = [:]
//    public var mappedParameters :
    
    open var buildClosure    : LyrebirdGraphConstructionClosure?
    
    open var shouldRemoveFromTree: Bool = false
    
    open weak var note: LyrebirdNote?
    
    public init(){
    }
    
    func next(numSamples: LyrebirdInt){
        for ugen: LyrebirdUGen in children {
            ugen.next(numSamples: numSamples)
        }
        // set up for next run
        prepareChildren()
        if( shouldRemoveFromTree ){
            note?.shouldFree = true
        }
    }
    
    fileprivate func prepareChildren() {
        for child: LyrebirdUGen in children {
            child.needsCalc = true
        }
    }
    
    internal func addChild(child: LyrebirdUGen){
        children.append(child)
        //child.graph = self
    }
    
    // closure should refer to the graph, assign children and refer to args
    // TODO:: but a lock on currentGraphBuilding
    open func build (closure: @escaping LyrebirdGraphConstructionClosure) {
        buildClosure = closure
        LyrebirdGraph.currentBuildingGraph = self
        closure()
        LyrebirdGraph.currentBuildingGraph = nil
    }
    
    open func copyGraph() -> LyrebirdGraph {
        let copy: LyrebirdGraph = LyrebirdGraph()
        if let buildClosure: LyrebirdGraphConstructionClosure = buildClosure {
            copy.build(closure: buildClosure)
        }
        return copy
    }

}
