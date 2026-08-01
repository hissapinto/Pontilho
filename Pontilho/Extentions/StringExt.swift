//
//  StringExt.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//


extension String {
    var splitString: [String] {
        let parts = self.split(separator: ": ", maxSplits: 1)
        
        //formato inesperado - devolve o texto
        guard parts.count == 2 else {
                return [self]
        }
        
        let first = String(parts[0]).capitalized
        let second = String(parts[1])
        
        return [first, second]
    }
}
