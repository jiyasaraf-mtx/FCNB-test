import { LightningElement, track } from 'lwc';
import searchTrials from '@salesforce/apex/ClinicalTrialsController.searchTrials';

export default class ClinicalTrialsSearch extends LightningElement {
    @track condition = '';
    @track status = '';
    @track data = [];
    @track error;
    @track isLoading = false;

    // Filter parameters defined by ClinicalTrials API v2
    statusOptions = [
        { label: 'Any Status', value: '' },
        { label: 'Recruiting', value: 'RECRUITING' },
        { label: 'Not Yet Recruiting', value: 'NOT_YET_RECRUITING' },
        { label: 'Active, Not Recruiting', value: 'ACTIVE_NOT_RECRUITING' },
        { label: 'Completed', value: 'COMPLETED' },
        { label: 'Terminated', value: 'TERMINATED' }
    ];

    // Data table columns
    columns = [
        { label: 'NCT ID', fieldName: 'nctId', type: 'text', initialWidth: 150 },
        { label: 'Trial Title', fieldName: 'title', type: 'text', wrapText: true },
        { label: 'Status', fieldName: 'status', type: 'text', initialWidth: 150 },
        { label: 'Phases', fieldName: 'phase', type: 'text', initialWidth: 150 }
    ];

    get hasData() {
        return this.data && this.data.length > 0;
    }

    handleConditionChange(event) {
        this.condition = event.target.value;
    }

    handleStatusChange(event) {
        this.status = event.detail.value;
    }

    handleSearch() {
        this.isLoading = true;
        this.error = undefined;
        this.data = [];
        
        searchTrials({ condition: this.condition, status: this.status })
            .then((result) => {
                let parsedResult = JSON.parse(result);
                
                // Map the v2 nested JSON structure to our datatable
                if (parsedResult.studies && parsedResult.studies.length > 0) {
                    this.data = parsedResult.studies.map(study => {
                        const protocol = study.protocolSection || {};
                        const ident = protocol.identificationModule || {};
                        const stat = protocol.statusModule || {};
                        const design = protocol.designModule || {};
                        
                        return {
                            nctId: ident.nctId || 'Unknown',
                            title: ident.briefTitle || 'No Title Available',
                            status: stat.overallStatus || 'Unknown',
                            phase: design.phases ? design.phases.join(', ') : 'N/A'
                        };
                    });
                } else {
                    this.error = 'No trials found matching your criteria.';
                }
            })
            .catch((error) => {
                this.error = error.body ? error.body.message : 'An unknown error occurred while fetching data.';
                console.error(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}