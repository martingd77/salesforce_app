@IsTest
public class SportsApiServiceTest {

    private class SportsApiMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        public SportsApiMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }

    @IsTest
    static void test_getUpcomingEvents_success() {
        String mockJson = '{ "events": [' +
                          '{ "idEvent": "12345",' +
                          ' "strEvent": "Lakers vs Bulls",' +
                          ' "dateEvent": "2025-02-05",' +
                          ' "strLeague": "NBA",' +
                          ' "strSeason": "2024-2025",' +
                          ' "strThumb": "https://example.com/img.png" }' +
                          '] }';

        Test.setMock(HttpCalloutMock.class, new SportsApiMock(200, mockJson));

        Test.startTest();
        SportsApiServiceDTO.EventResponse response = SportsApiService.getUpcomingEvents('123');
        Test.stopTest();

        System.assertNotEquals(null, response, 'La respuesta no debe ser null');
        System.assertEquals(1, response.events.size(), 'Debe devolver 1 evento');

        SportsApiServiceDTO.Event evt = response.events[0];
        System.assertEquals('Lakers vs Bulls', evt.strEvent);
        System.assertEquals('2025-02-05', evt.dateEvent);
        System.assertEquals('NBA', evt.strLeague);
        System.assertEquals('2024-2025', evt.strSeason);
        System.assertEquals('https://example.com/img.png', evt.strThumb);
    }

    @IsTest
    static void test_getUpcomingEvents_error() {
        Test.setMock(HttpCalloutMock.class, new SportsApiMock(500, 'Server Down'));

        Boolean errorThrown = false;
        Test.startTest();
        try {
            SportsApiService.getUpcomingEvents('123');
        } catch (Exception e) {
            errorThrown = true;
            System.assert(e.getMessage().contains('API error'), 'Debe contener mensaje de error de API');
        }
        Test.stopTest();

        System.assertEquals(true, errorThrown, 'Debe lanzar excepción si la API falla');
    }

    @IsTest
    static void test_getAllLeagues_success() {
        String mockJson = '{ "leagues": [' +
                          '{ "idLeague": "123", "strLeague": "NBA" },' +
                          '{ "idLeague": "456", "strLeague": "NFL" }' +
                          '] }';

        Test.setMock(HttpCalloutMock.class, new SportsApiMock(200, mockJson));

        Test.startTest();
        List<SportsApiServiceDTO.League> leagues = SportsApiService.getAllLeagues();
        Test.stopTest();

        System.assertEquals(2, leagues.size(), 'Debe devolver 2 ligas');
        System.assertEquals('NBA', leagues[0].strLeague);
        System.assertEquals('NFL', leagues[1].strLeague);
    }
}
