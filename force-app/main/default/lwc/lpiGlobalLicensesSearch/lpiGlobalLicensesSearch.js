import { LightningElement, track } from 'lwc';

export default class LpiGlobalLicensesSearch extends LightningElement {
    @track sectionClass1 = 'slds-accordion__section custom-accordion slds-is-open';
    @track sectionClass2 = 'slds-accordion__section custom-accordion';
    @track isFilteredData = false;
    @track jsonArray = [
    {
        "Id": 1,
        "badgeContent": "Individual Insurance Agent",
        "title": "Individual Insurance Agent",
        "description": "The FCNB Individual Insurance Agent Licence authorizes qualified, sponsored individuals to legally conduct Life, General, Accident & Sickness, or Travel insurance business in New Brunswick."
    },
    {
        "Id": 2,
        "badgeContent": "Real Estate Salesperson",
        "title": "Real Estate Salesperson",
        "description": "Financial and Consumer Services Commission of New Brunswick"
    },
        {
        "Id": 3,
        "badgeContent": "Interim Teacher",
        "title": "Interim Teacher’s Certificate",
        "description": "Form C is an application for internationally trained teachers seeking interim certification in New Brunswick, Canada. It outlines eligibility criteria, certification levels, required documentation, background disclosures, and payment details."
    },
    {
        "Id": 4,
        "badgeContent": "New Graduates",
        "title": "Initial Teacher's Certificate (Form A)",
        "description": "Standard application for individuals who have recently completed their Bachelor of Education degree at a New Brunswick university and are seeking their first provincial teaching license."
    },
    {
        "Id": 5,
        "badgeContent": "Labour Mobility",
        "title": "Canadian Mobility Certificate (Form B)",
        "description": "Application form for educators who already hold a valid teaching certificate from another Canadian province or territory and wish to transfer their credentials to New Brunswick."
    },
    {
        "Id": 6,
        "badgeContent": "Upgrades",
        "title": "Certificate Level Increase (Form D)",
        "description": "Used by currently licensed New Brunswick teachers to apply for a higher certification level (e.g., moving from Level 4 to 5 or 6) based on the completion of additional university credits or graduate degrees."
    },
    {
        "Id": 7,
        "badgeContent": "",
        "title": "Statement of Professional Standing (Form F)",
        "description": "A formal request to have the Office of Teacher Certification send a verification of your New Brunswick license status and conduct history to another licensing jurisdiction or employer."
    },
    {
        "Id": 8,
        "badgeContent": "",
        "title": "Duplicate Certificate Request (Form L)",
        "description": "Application to receive an official replacement copy of a lost or damaged teaching certificate, or to update a certificate following a legal name change."
    },
    {
        "Id": 9,
        "badgeContent": "Specialist",
        "title": "Principal's Certificate",
        "description": "Application for experienced teachers who have completed the required leadership coursework and are seeking certification to serve as a Principal or Vice-Principal in the NB public school system."
    },
    {
        "Id": 10,
        "badgeContent": "Temporary",
        "title": "Local Teaching Permit",
        "description": "A temporary authorization issued at the request of a School District when a certified teacher is unavailable, allowing a non-certified individual to teach for a limited duration."
    }
];
		
		@track sortOptions = [{label:"Ascending",value:"ASC"},{label:"Descending",value:"DESC"}];
		
    @track dataJSON;
    totalPages = 1;
    currentPage = 1;
    currentPageData = 1;
    dataPerPage = 4;
    pageMessage;
		isDisablePrevious=false;
		isDisableNext=false; 
		sortBy='';

    connectedCallback() {
        console.log("Connected");
        this.setPaginationData();    	
    }
    
    setPaginationData() {
        console.log("setPaginationData");
				let dataToPaginate = this.isFilteredData ? this.dataJSON : this.jsonArray;
				 if (this.sortBy) {
						  dataToPaginate = this.sortData(dataToPaginate, this.sortBy);
        } 
        let startIndex = (this.currentPage - 1) * this.dataPerPage;
        let endIndex = this.currentPage * this.dataPerPage;
        this.dataJSON = dataToPaginate.slice(startIndex, endIndex);

        this.totalPages = Math.ceil(dataToPaginate.length / this.dataPerPage);
        let startRecord = startIndex + 1;
        let endRecord = endIndex > dataToPaginate.length ? dataToPaginate.length : endIndex;
        this.pageMessage = `Results ${startRecord} - ${endRecord} of ${dataToPaginate.length}`;
        console.log("Total pages: " + this.totalPages);
				this.isDisableNext = this.currentPage > this.totalPages ? true : false;
				this.isDisablePrevious = this.currentPage < 1 ? true : false;
    }
		
		sortData(data, sortBy) {
        const sortField = sortBy.replace(/(ASC|DESC)$/, '').toLowerCase();
        const sortDirection = sortBy.endsWith('ASC') ? 1 : -1;
        return [...data].sort((a, b) => {
            if (a[sortField] > b[sortField]) {
                return 1 * sortDirection;
            } else if (a[sortField] < b[sortField]) {
                return -1 * sortDirection;
            } else {
                return 0;
            }
        });
    }

    handleSortChange(event) {
        this.sortBy = event.detail.value;
				console.log('sorting by ',this.sortBy);
        this.currentPage = 1; 
        this.setPaginationData();
    }


    handleAccordianClick(event) {
        let name = event.currentTarget.dataset.name;
        let accordionStatus = this.template.querySelector(`[data-name="category"]`);

        if (name === 'category') {
            if (this.sectionClass1 === 'slds-accordion__section custom-accordion') {
                this.sectionClass1 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', true);
            } else {
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', false);
            }
        }
        if (name === 'agency') {
            if (this.sectionClass2 === 'slds-accordion__section custom-accordion') {
                this.sectionClass2 = 'slds-accordion__section custom-accordion slds-is-open';
                this.sectionClass1 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', true);
            } else {
                this.sectionClass2 = 'slds-accordion__section custom-accordion';
                accordionStatus.setAttribute('aria-expanded', false);
            }
        }
    }
		
    handleClick(event) {
    const dataId = event.target.dataset.id; 
    const title = event.target.dataset.title;
    const description = event.target.dataset.description; 
    window.open(`/s/global-search-details?id=${dataId}&title=${encodeURIComponent(title)}&description=${encodeURIComponent(description)}`, '_blank');
}
    
    handleSearch(event) {
        const searchTerm = event.target.value.toLowerCase();
        if (searchTerm) {
            this.dataJSON = this.jsonArray.filter(item => {
                return Object.values(item).some(value => 
                    String(value).toLowerCase().includes(searchTerm)
                );
            });
            this.isFilteredData = true;
        } else {
            this.isFilteredData = false;
        }

        this.currentPage = 1; 
        this.setPaginationData();
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.setPaginationData();
        }else{
						this.isDisableNext = true;
				}
    }

    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.setPaginationData();
        }else{
						this.isDisablePrevious = true;
				}
    }
}