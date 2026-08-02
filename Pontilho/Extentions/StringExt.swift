//
//  StringExt.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 01/08/26.
//


extension String {
    
    ///Retorna a String dividida pelo : em formato de array. <horario: 10:00>
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
    
    ///Transforma em Array de novo uma [String] que foi juntada e sinalizada com  "|"
    var joinString: [String] {
        
        if self == "Sem informações de horários" {
                    return [self]
        }
        
        return self.components(separatedBy: "|")
    }
}

extension Float {
    
    /// Retorna float formatado como rating
    var asRating: String {
        return "★ " + String(format: "%.2f", self)
    }
}
