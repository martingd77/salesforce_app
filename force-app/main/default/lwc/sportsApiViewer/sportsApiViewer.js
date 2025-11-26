import { LightningElement, track } from 'lwc';
import getAllLeagues from '@salesforce/apex/SportsApiService.getAllLeagues';
import getUpcomingEvents from '@salesforce/apex/SportsApiService.getUpcomingEvents';

export default class SportsApiViewer extends LightningElement {

    @track leagues = [];
    @track leagueOptions = [];
    @track selectedLeagueId;
    @track events = [];
    @track error;
    loading = false;

    connectedCallback() {
        this.loadLeagues();
    }

    loadLeagues() {
        getAllLeagues()
            .then(result => {
                this.leagues = result;
                this.leagueOptions = result.map(l => {
                    return { label: l.strLeague, value: l.idLeague };
                });
            })
            .catch(err => {
                this.error = 'Error loading leagues';
            });
    }

    handleLeagueChange(event) {
        this.selectedLeagueId = event.detail.value;
        if (this.selectedLeagueId) {
            this.loadEvents(this.selectedLeagueId);
        }
    }

    loadEvents(leagueId) {
        this.loading = true;
        this.events = [];
        this.error = null;

        getUpcomingEvents({ leagueId })
            .then(result => {
                this.events = result.events;
            })
            .catch(err => {
                this.error = 'Error loading events';
            })
            .finally(() => {
                this.loading = false;
            });
    }
}
