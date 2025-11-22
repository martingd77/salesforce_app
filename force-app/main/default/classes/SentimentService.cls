public with sharing class SentimentService {

    private static final String ENDPOINT = 'callout:SentimentAPI';
    
    // Flag para modo de desarrollo (usar mock local)
    // Configurar como Custom Metadata Type o Custom Setting en producción
    // Para pruebas reales, cambiar a true para que siempre devuelva Negative y crear Tasks
    private static final Boolean USE_MOCK_MODE = true; // Cambiar a true para usar mock local

    public static SentimentDTO.SentimentResponse callAPI(String text) {
        
        // Validate input
        if (String.isBlank(text)) {
            throw new SentimentException('Text cannot be empty');
        }

        // Modo mock para desarrollo/pruebas
        if (USE_MOCK_MODE || Test.isRunningTest()) {
            return callAPIMock(text);
        }
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Use DTO for request body
        SentimentDTO.SentimentRequest requestBody = new SentimentDTO.SentimentRequest(text);
        req.setBody(JSON.serialize(requestBody));

        Http http = new Http();
        HttpResponse res = http.send(req);

        // Check for HTTP errors
        if (res.getStatusCode() != 200) {
            throw new SentimentException(
                'API error: HTTP ' + res.getStatusCode() + ' - ' + res.getBody()
            );
        }

        // Deserialize response
        SentimentDTO.SentimentResponse response = 
            (SentimentDTO.SentimentResponse) JSON.deserialize(
                res.getBody(), 
                SentimentDTO.SentimentResponse.class
            );

        // Normalize sentiment to capitalize first letter (e.g., "negative" -> "Negative")
        if (response.sentiment != null && response.sentiment.length() > 0) {
            response.sentiment = response.sentiment.substring(0, 1).toUpperCase() + 
                                 response.sentiment.substring(1).toLowerCase();
        }

        return response;
    }

    /**
     * Mock local para desarrollo y pruebas
     * Devuelve Negative por defecto para probar creación de Tasks
     */
    private static SentimentDTO.SentimentResponse callAPIMock(String text) {
        // Por defecto devuelve Negative para pruebas
        // Puedes cambiar esto para devolver Positive o Neutral según necesites
        String sentiment = 'Negative';
        Double score = 0.15;

        // Análisis básico opcional basado en palabras clave
        if (String.isNotBlank(text)) {
            String lowerText = text.toLowerCase();
            
            // Si contiene palabras muy positivas, cambiar a Positive
            if (lowerText.contains('excellent') || lowerText.contains('amazing') || 
                lowerText.contains('wonderful') || lowerText.contains('perfect')) {
                sentiment = 'Positive';
                score = 0.90;
            } 
            // Si contiene palabras muy negativas, mantener Negative
            else if (lowerText.contains('horrible') || lowerText.contains('terrible') || 
                     lowerText.contains('awful') || lowerText.contains('worst')) {
                sentiment = 'Negative';
                score = 0.10;
            }
            // Por defecto: Negative para probar creación de Tasks
        }

        SentimentDTO.SentimentResponse response = new SentimentDTO.SentimentResponse();
        response.sentiment = sentiment;
        response.score = score;

        return response;
    }

    // Custom exception
    public class SentimentException extends Exception {}

}