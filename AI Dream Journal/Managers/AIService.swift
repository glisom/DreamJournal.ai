//
//  AIService.swift
//  AI Dream Journal
//
//  Created by Grant Isom on 1/16/25.
//

import Foundation
import NaturalLanguage
import CoreML

enum AIServiceError: Error {
    case processingFailed
    case modelNotAvailable
}

class AIService {
    static let shared = AIService()
    
    private init() {}
    
    // Use on-device AI for interpretation when possible
    func interpretDream(_ dream: Dream, completion: @escaping (Result<String, Error>) -> Void) {
        // Check if we can use on-device processing
        if isOnDeviceProcessingAvailable() {
            processOnDevice(dream) { result in
                // Add slight delay to avoid UI flickering
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(result)
                }
            }
        } else {
            // Fall back to mock responses for development
            mockInterpretation(dream) { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    completion(result)
                }
            }
        }
    }
    
    func getHoroscope(includingDream dream: Dream? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        // Check if we can use on-device processing
        if isOnDeviceProcessingAvailable() && dream != nil {
            generateHoroscopeOnDevice(dream: dream!) { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(result)
                }
            }
        } else {
            // Fall back to mock responses for development
            mockHoroscope(dream) { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    completion(result)
                }
            }
        }
    }
    
    // MARK: - On-device processing
    
    private func isOnDeviceProcessingAvailable() -> Bool {
        // Check if NL embedding model is available
        if #available(iOS 17.0, *) {
            return NLEmbedding.wordEmbedding(for: .english) != nil
        } else {
            return false
        }
    }
    
    private func processOnDevice(_ dream: Dream, completion: @escaping (Result<String, Error>) -> Void) {
        // Extract key themes from dream content
        let themes = extractKeyThemes(from: dream.content)
        
        // Analyze sentiment of dream
        let sentiment = analyzeSentiment(of: dream.content)
        
        // Generate interpretation based on themes and sentiment
        let interpretation = generateInterpretation(themes: themes, sentiment: sentiment, dream: dream)
        
        if !interpretation.isEmpty {
            completion(.success(interpretation))
        } else {
            completion(.failure(AIServiceError.processingFailed))
        }
    }
    
    private func extractKeyThemes(from text: String) -> [String] {
        var themes: [String] = []
        
        // Use Natural Language framework to extract key topics
        if let tagger = try? NLTagger(tagSchemes: [.nameType, .lemma]) {
            tagger.string = text
            
            // Get nouns and verbs which often represent themes
            let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
            tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
                if let tag = tag, let word = tag.rawValue.lowercased() as String? {
                    // Filter for meaningful words (could be enhanced with a more sophisticated model)
                    if word.count > 3 && !commonWords.contains(word) {
                        themes.append(word)
                    }
                }
                return true
            }
        }
        
        // Return unique themes, limited to top 5
        return Array(Set(themes)).prefix(5).map { $0 }
    }
    
    private func analyzeSentiment(of text: String) -> String {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let sentiment = sentiment, let score = Double(sentiment.rawValue) {
            if score < -0.3 {
                return "negative"
            } else if score > 0.3 {
                return "positive"
            } else {
                return "neutral"
            }
        }
        
        return "neutral"
    }
    
    private func generateInterpretation(themes: [String], sentiment: String, dream: Dream) -> String {
        // Create a base template based on sentiment
        let sentimentText: String
        switch sentiment {
        case "positive":
            sentimentText = "Your dream has an overall positive emotional tone, which suggests feelings of hope or satisfaction in your waking life."
        case "negative":
            sentimentText = "Your dream has elements of concern or anxiety, which might reflect current challenges you're facing."
        default:
            sentimentText = "Your dream contains mixed emotions, suggesting you may be processing complex feelings."
        }
        
        // Add theme-based interpretations
        var themeInterpretation = ""
        if !themes.isEmpty {
            themeInterpretation = "The presence of " + themes.joined(separator: ", ") + " in your dream suggests "
            
            // Add a meaning based on themes
            if themes.contains(where: { $0.contains("water") || $0.contains("ocean") || $0.contains("river") }) {
                themeInterpretation += "you may be processing emotional changes or exploring your unconscious mind."
            } else if themes.contains(where: { $0.contains("fall") || $0.contains("flying") }) {
                themeInterpretation += "you might be experiencing feelings about control or freedom in your life."
            } else if themes.contains(where: { $0.contains("chase") || $0.contains("running") }) {
                themeInterpretation += "you could be avoiding a situation or feeling in your waking life."
            } else {
                themeInterpretation += "these elements hold symbolic meaning related to your current life circumstances."
            }
        }
        
        // Combine the interpretations
        let finalInterpretation = "Your dream about \(dream.title.lowercased()) reveals insights into your subconscious. \(sentimentText) \(themeInterpretation) Reflection on these elements may provide clarity about your thoughts and feelings."
        
        return finalInterpretation
    }
    
    private func generateHoroscopeOnDevice(dream: Dream, completion: @escaping (Result<String, Error>) -> Void) {
        // Extract sentiment and themes from dream
        let sentiment = analyzeSentiment(of: dream.content)
        let themes = extractKeyThemes(from: dream.content)
        
        // Generate a horoscope that incorporates elements from the dream
        let horoscope = createHoroscope(dream: dream, sentiment: sentiment, themes: themes)
        
        completion(.success(horoscope))
    }
    
    private func createHoroscope(dream: Dream, sentiment: String, themes: [String]) -> String {
        // Create different horoscope templates based on dream sentiment
        let intro: String
        switch sentiment {
        case "positive":
            intro = "The stars align positively today, reflecting the optimistic elements in your recent dream about \(dream.title.lowercased())."
        case "negative":
            intro = "Cosmic energies suggest a period of reflection, particularly regarding the concerns expressed in your dream about \(dream.title.lowercased())."
        default:
            intro = "The celestial patterns today connect with themes from your recent dream about \(dream.title.lowercased())."
        }
        
        // Add advice based on dream themes
        var advice = ""
        if !themes.isEmpty {
            if themes.contains(where: { $0.contains("water") || $0.contains("flow") }) {
                advice = "Allow your emotions to flow naturally today rather than resisting them."
            } else if themes.contains(where: { $0.contains("path") || $0.contains("journey") || $0.contains("road") }) {
                advice = "Consider your current path and whether it aligns with your true desires."
            } else if themes.contains(where: { $0.contains("light") || $0.contains("sun") || $0.contains("bright") }) {
                advice = "Seek clarity in situations that have seemed confusing recently."
            } else {
                advice = "Pay attention to recurring patterns in your thoughts and experiences today."
            }
        } else {
            advice = "Trust your intuition when making decisions today."
        }
        
        // Add conclusion
        let conclusion = "The coming days present an opportunity to integrate the messages from your dreams into conscious awareness."
        
        return "\(intro) \(advice) \(conclusion)"
    }
    
    // Common words to filter out of themes
    private let commonWords = ["the", "and", "was", "that", "have", "for", "with", "you", "this", "but", "his", "from", "they", "she", "will", "one", "all", "would", "there", "their", "what", "out", "about", "who", "get", "which", "when", "make", "can", "like", "time", "just", "him", "know", "take", "people", "into", "year", "your", "good", "some", "could", "them", "see", "other", "than", "then", "now", "look", "only", "come", "its", "over", "think", "also", "back", "after", "use", "two", "how", "our", "work", "first", "well", "way", "even", "new", "want", "because", "any", "these", "give", "day", "most", "been"]
    
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