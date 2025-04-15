//
//  AIService.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import Foundation

class AIService {
    static let shared = AIService()
    
    private init() {}
    
    // Use API endpoint for interpretation or mock in development
    func interpretDream(_ dream: Dream, completion: @escaping (Result<String, Error>) -> Void) {
        // For development purposes, we'll create a mock service
        // In production, this would use the ChatGPT API
        mockInterpretation(dream) { result in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                completion(result)
            }
        }
    }
    
    func getHoroscope(includingDream dream: Dream? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        // For development purposes, we'll create a mock service
        // In production, this would use the ChatGPT API
        mockHoroscope(dream) { result in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                completion(result)
            }
        }
    }
    
    // MARK: - Mock implementations
    
    private func mockInterpretation(_ dream: Dream, completion: @escaping (Result<String, Error>) -> Void) {
        let interpretations = [
            "Your dream about \(dream.title.lowercased()) suggests that you may be processing feelings of uncertainty in your waking life. The symbols in your dream point to a desire for clarity and resolution.",
            
            "The \(dream.title.lowercased()) in your dream represents transformation and change. This dream may be reflecting your current state of personal growth and evolution.",
            
            "Dreams involving \(dream.title.lowercased()) often symbolize hidden fears or desires. Consider what aspects of yourself might be represented by the elements in this dream.",
            
            "This dream suggests you're working through unresolved emotions related to \(dream.title.lowercased()). Pay attention to how you felt during the dream - these emotions may be key to understanding what your subconscious is processing.",
            
            "The imagery of \(dream.title.lowercased()) in your dream could be connected to your creative potential. Your subconscious may be encouraging you to explore new ideas or perspectives."
        ]
        
        let randomInterpretation = interpretations.randomElement() ?? "Your dream appears to contain significant symbolism that reflects your inner thoughts and emotions."
        
        completion(.success(randomInterpretation))
    }
    
    private func mockHoroscope(_ dream: Dream? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        var horoscopes = [
            "The stars align in your favor today. Be open to unexpected opportunities and trust your intuition when making decisions.",
            
            "A period of reflection will serve you well. Take time to consider your goals and the steps needed to achieve them.",
            
            "Communication is highlighted today. Express your thoughts clearly and be receptive to feedback from others.",
            
            "Focus on balance in your life. Ensure you're giving attention to both your responsibilities and personal well-being.",
            
            "Creativity flows strongly now. Channel this energy into projects that inspire you and bring joy."
        ]
        
        if let dream = dream {
            // If a dream is provided, include it in the horoscope for a more personalized reading
            horoscopes.append("Your recent dream about \(dream.title.lowercased()) suggests a period of transformation. Embrace change and remain adaptable as new opportunities emerge.")
        }
        
        let randomHoroscope = horoscopes.randomElement() ?? "The cosmic energies are shifting in your favor. Stay attentive to signs that guide you toward your true path."
        
        completion(.success(randomHoroscope))
    }
}