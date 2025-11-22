/**
 * Mock inteligente para pruebas reales
 * Analiza el texto y devuelve sentimiento negativo por defecto
 * Útil para probar la creación de Tasks en entornos de desarrollo
 */
global class SentimentServiceMockIntelligent implements HttpCalloutMock {

    private Boolean alwaysNegative;
    private String defaultSentiment;

    /**
     * Constructor - Por defecto devuelve Negative
     * @param alwaysNegative Si es true, siempre devuelve Negative. Si es false, analiza el texto.
     */
    public SentimentServiceMockIntelligent(Boolean alwaysNegative) {
        this.alwaysNegative = alwaysNegative != null ? alwaysNegative : true;
        this.defaultSentiment = 'Negative';
    }

    /**
     * Constructor con sentimiento personalizado
     */
    public SentimentServiceMockIntelligent(String defaultSentiment) {
        this.alwaysNegative = false;
        this.defaultSentiment = defaultSentiment != null ? defaultSentiment : 'Negative';
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');

        String sentiment = defaultSentiment;
        Double score = 0.15; // Score bajo para negativo

        if (!alwaysNegative) {
            // Analizar el texto del request
            String requestBody = req.getBody();
            if (String.isNotBlank(requestBody)) {
                try {
                    Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                    String text = (String) bodyMap.get('text');
                    
                    if (String.isNotBlank(text)) {
                        sentiment = analyzeText(text);
                        score = calculateScore(sentiment, text);
                    }
                } catch (Exception e) {
                    // Si hay error, usar default negativo
                    System.debug('Error parsing request: ' + e.getMessage());
                }
            }
        }

        // Construir respuesta
        Map<String, Object> response = new Map<String, Object>{
            'sentiment' => sentiment,
            'score' => score
        };

        res.setBody(JSON.serialize(response));
        return res;
    }

    /**
     * Análisis básico de sentimiento basado en palabras clave
     */
    private String analyzeText(String text) {
        if (String.isBlank(text)) {
            return defaultSentiment;
        }

        String lowerText = text.toLowerCase();

        // Palabras negativas
        Set<String> negativeWords = new Set<String>{
            'horrible', 'terrible', 'awful', 'bad', 'worst', 'hate', 'angry',
            'frustrated', 'disappointed', 'poor', 'slow', 'broken', 'error',
            'problem', 'issue', 'complaint', 'refund', 'cancel', 'unhappy'
        };

        // Palabras positivas
        Set<String> positiveWords = new Set<String>{
            'great', 'excellent', 'amazing', 'wonderful', 'good', 'best',
            'love', 'happy', 'satisfied', 'perfect', 'awesome', 'fantastic',
            'thank', 'thanks', 'appreciate', 'pleased'
        };

        Integer negativeCount = 0;
        Integer positiveCount = 0;

        for (String word : negativeWords) {
            if (lowerText.contains(word)) {
                negativeCount++;
            }
        }

        for (String word : positiveWords) {
            if (lowerText.contains(word)) {
                positiveCount++;
            }
        }

        // Si hay más palabras negativas, devolver Negative
        if (negativeCount > positiveCount) {
            return 'Negative';
        } else if (positiveCount > negativeCount) {
            return 'Positive';
        } else {
            // Por defecto, devolver Negative para pruebas
            return defaultSentiment;
        }
    }

    /**
     * Calcula el score basado en el sentimiento
     */
    private Double calculateScore(String sentiment, String text) {
        if (sentiment == 'Negative') {
            // Score bajo para negativo (0.1 - 0.3)
            return 0.15;
        } else if (sentiment == 'Positive') {
            // Score alto para positivo (0.7 - 0.9)
            return 0.85;
        } else {
            // Score medio para neutral (0.4 - 0.6)
            return 0.50;
        }
    }
}

