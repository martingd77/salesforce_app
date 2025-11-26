public with sharing class SportsApiService {

    private static final String BASE_URL = 'https://www.thesportsdb.com/api/v1/json/123';

    // Devuelve todas las ligas
    @AuraEnabled(cacheable=true)
    public static List<SportsApiServiceDTO.League> getAllLeagues() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/all_leagues.php');
        req.setMethod('GET');

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != 200) {
            throw new CalloutException('API error: ' + res.getStatus());
        }

        SportsApiServiceDTO.LeagueResponse leagues =
            (SportsApiServiceDTO.LeagueResponse) JSON.deserialize(res.getBody(), SportsApiServiceDTO.LeagueResponse.class);

        return leagues.leagues != null ? leagues.leagues : new List<SportsApiServiceDTO.League>();
    }

    // Devuelve los próximos eventos de una liga por Id
    @AuraEnabled(cacheable=true)
    public static SportsApiServiceDTO.EventResponse getUpcomingEvents(String leagueId) {

        String url = BASE_URL + '/eventsnextleague.php?id=' + leagueId;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != 200) {
            throw new CalloutException('API error: ' + res.getStatus());
        }

        return (SportsApiServiceDTO.EventResponse) JSON.deserialize(
            res.getBody(),
            SportsApiServiceDTO.EventResponse.class
        );
    }
}

