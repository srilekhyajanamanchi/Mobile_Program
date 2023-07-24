//
//  ContentView.swift
//  Dall_E_Integration
//
//  Created by Srilekhya Janamanchi on 06/07/23.
//

import OpenAIKit
import SwiftUI

final class ViewModel: ObservableObject {
    private var openai: OpenAI?
    
    func setup() {
        openai = OpenAI(Configuration(organizationId: "Personal", apiKey: "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"))
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        
        do {
            let params = ImageParameters(prompt: prompt,
                                         resolution: .medium,
                                         responseFormat: .base64Json
            )
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            
            let image = try openai.decodeBase64Image(data)
            return image
        } catch {
            print(String(describing: error))
            return nil
        }
    }
}

struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(width: 350, height: 500)
            }
            else {
                Text("Type Prompt to generate image!")
            }
            Spacer()
            TextField("Type prompt here ... ", text: $text)
                .padding()
            Button("Generator!") {
                
                if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                    Task{
                        let result = await viewModel.generateImage(prompt: text)
                        if result == nil {
                            print("Failed to get image")
                        }
                        self.image = result
                    }
                }
            }
            .navigationTitle("Image Generator")
            .onAppear {
                viewModel.setup()
            }
            .padding()
        }
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

