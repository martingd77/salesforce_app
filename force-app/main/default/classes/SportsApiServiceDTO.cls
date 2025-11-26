public class SportsApiServiceDTO {

    public class Event {
        @AuraEnabled public String idEvent;
        @AuraEnabled public String strEvent;
        @AuraEnabled public String dateEvent;
        @AuraEnabled public String strLeague;
        @AuraEnabled public String strSeason;
        @AuraEnabled public String strThumb;
    }

    public class EventResponse {
        @AuraEnabled public List<Event> events;
    }

    public class League {
        @AuraEnabled public String idLeague;
        @AuraEnabled public String strLeague;
    }

    public class LeagueResponse {
        @AuraEnabled public List<League> leagues;
    }
}