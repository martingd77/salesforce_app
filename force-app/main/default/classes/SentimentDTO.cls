public with sharing class SentimentDTO {
    public class SentimentRequest {
        public String text;
        public SentimentRequest(String t){ text = t; }
    }

    public class SentimentResponse {
        public String sentiment;
        public Double score;
    }
}