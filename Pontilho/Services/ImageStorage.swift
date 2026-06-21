//
//  ImageStorage.swift
//  Pontilho
//
//  Created by Isabela Hissa Pinto on 18/06/26.
//

///O ImageStorage é sem estado (stateless): cada função recebe o que precisa (a imagem, o nome do arquivo), faz o trabalho, e retorna.
///Não guarda nada entre uma chamada e outra.
///Um enum sem casos funciona como um agrupador de funções estáticas. Uma caixa de ferramentas que qualquer parte do codigo pode usar
///Nesse caso é melhor usar um enum em vez de struct ou class pois ele nao guarda estado (class) e nem tem valor (struct). Nao precisa ser instanciado

import UIKit

enum ImageStorage {
    ///pega a url da pasta padrão de documentos do app
    private static var directory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    ///salva a imagem comprimida e retorna o nome do arquivo gerado
    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
        let filename = "\(UUID().uuidString).jpg"
        let url = directory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            print("ERRO ao salvar imagem: \(error)")
            return nil
        }
    }

    ///carrega a imagem a partir do nome do arquivo
    static func load(_ filename: String) -> UIImage? {
        let url = directory.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }

    ///apaga o arquivo da imagem
    static func delete(_ filename: String) {
        let url = directory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
