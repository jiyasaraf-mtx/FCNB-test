import { LightningElement, track, wire } from 'lwc';
import {
    showAsyncErrorMessage,
    showMessage
} from 'c/lpiUtil';
import { CurrentPageReference } from 'lightning/navigation';
import loadPicklistValues from '@salesforce/apex/LPI_LicenseSearchController.loadPicklistValues';
import fetchBusinessLicense from '@salesforce/apex/LPI_LicenseSearchController.fetchBusinessLicense';
import fetchBLWithoutCounty from '@salesforce/apex/LPI_LicenseSearchController.fetchBLWithoutCounty';
import getApplicationData from '@salesforce/apex/LPI_LicenseSearchController.getApplicationData';
import getLabels from '@salesforce/apex/EMP_LanguageCtrl.getLabels';
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
import {
    PUBLIC_PAGE_LABEL_API_NAMES,
    mapApiToCamel,
    readStoredLanguage
} from 'c/lpLanguageUtils';

export default class MoDprLicenseSearch extends LightningElement {
    @wire(CurrentPageReference)
    currentPageReference;
    @track showSpinner;
    @track professionList = [];
    @track status = 'Active';
    @track professionName = '';
    @track searchCriteria = 'None';
    @track partialRequires = '';
    @track countyName = '';
    @track disablePartialText = true;
    @track labels = {
        lsTitle: 'Search for Licenses',
        lsSubtitle: 'Licenses can be searched by selecting a combination of filters.',
        lsActiveSearch: 'Active Licensee Search',
        lsNonActiveSearch: 'Non Active Licensee Search',
        lsActiveOnly: 'Active Licensee Only',
        lsNonActiveOnly: 'Non Active Licensee Only',
        lsIntro:
            'The licensee search function provides data extracted from our database and constitutes a Primary Source Verification. The information "Licensee Search" updated nightly. If you are unable to locate licensee information or have questions regarding any of the information supplied, please contact the individual licensing board directly. You must choose at least one criterion (County, Profession, Name, or License Number).',
        lsSelectDropdown: 'Select from the dropdown',
        lsSelectPlaceholder: 'Select from the dropdown list',
        lsCountyName: 'County Name',
        lsCountyPlaceholder: 'Enter county name',
        lsSearchCriteria: 'Search Criteria',
        lsCriteriaNone: 'None',
        lsCriteriaName: 'Licensee Name (Partial Last, First - enter in the textbox below)',
        lsCriteriaNumber: 'License Number (Exact - enter in the textbox below)',
        lsCriteriaDba: 'Practitioner DBA Name (Partial - enter in the textbox below)',
        lsPartialLabel: 'Partial requires at least two characters - left to right',
        lsPartialPlaceholder: 'Enter text',
        lsPartialMismatch: 'Invalid input. Please enter at least 2 characters.',
        lsReset: 'Reset',
        lsSearch: 'Search',
        lsNoData: 'No data found',
        lsRecordsFound: 'Records Found',
        lsProfessionName: 'Profession Name',
        lsLicenseeName: 'Licensee Name',
        lsAddress: 'Address',
        lsStatus: 'Status',
        lsAction: 'Action',
        lsView: 'View',
        lsActive: 'Active',
        lsPage: 'Page',
        lsOf: 'of',
        lsBack: 'Back',
        lsLicenseeDetails: 'Licensee Details',
        lsInvalidLicense: 'You have provided Invalid License Number!!',
        lsLoading: 'Loading...',
        lsResult: 'Result',
        lsPrintLicense: 'Print License',
        lsAddressInfo: 'Address Information',
        lsExpirationDate: 'Expiration Date',
        lsOriginalIssueDate: 'Original Issue Date',
        lsLicenseNumber: 'License Number',
        lsStreet: 'Street',
        lsCity: 'City',
        lsState: 'State',
        lsPostalCode: 'PostalCode',
        lsZipCode: 'Zip Code',
        lsCountyField: 'County'
    };
    licenseSearchData = [];
    licenseRecordsSize = 'No data found';
    showLicenseResult = false;
    selectedBlId = '';
    publicAddressId = '';
    licenseMessage = 'Active Licensee Only';
    directApplication = false;
    isNursing = false;
    norecords = lpiResource + '/media/icons/norecords.svg';

    get options() {
        return [
            { label: this.labels.lsActiveSearch, value: 'Active' },
            { label: this.labels.lsNonActiveSearch, value: 'Non Active' }
        ];
    }

    get searchOptions() {
        return [
            { label: this.labels.lsCriteriaNone, value: 'None' },
            {
                label: this.labels.lsCriteriaName,
                value: 'Licensee Name (Partial Last, First - enter in the textbox below)'
            },
            {
                label: this.labels.lsCriteriaNumber,
                value: 'License Number (Exact - enter in the textbox below)'
            },
            {
                label: this.labels.lsCriteriaDba,
                value: 'Practitioner DBA Name (Partial - enter in the textbox below)'
            }
        ];
    }

    // Select option1 by default
    value = 'Active Licensee Search';

    connectedCallback() {
        this.loadPublicPageLabels();
        this.showSpinner = true;
        if (`${this.currentPageReference.state.license}` != 'undefined') {
            this.showLicenseResult = true;
            this.directApplication = true;
            this.selectedBlId = `${this.currentPageReference.state.license}`;
            this.getApplicationData();
        } else {
            this.directApplication = false;
            this.selectedBlId = '';
            this.publicAddressId = '';
            this.loadData();
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.setFocusOnFirstInteractiveElement();
            }, 1000);
    }

    loadPublicPageLabels() {
        const lang = readStoredLanguage() || 'en_US';
        const apiNames = PUBLIC_PAGE_LABEL_API_NAMES.filter((n) => n.startsWith('LP_LS_'));
        getLabels({ apiNames, language: lang })
            .then((apiMap) => {
                this.labels = { ...this.labels, ...mapApiToCamel(apiMap) };
                this.licenseMessage =
                    this.status === 'Non Active'
                        ? this.labels.lsNonActiveOnly
                        : this.labels.lsActiveOnly;
                if (!this.licenseSearchData || !this.licenseSearchData.length) {
                    this.licenseRecordsSize = this.labels.lsNoData;
                } else {
                    this.licenseRecordsSize =
                        this.licenseSearchData.length + ' ' + this.labels.lsRecordsFound;
                }
                if (this.jsonData && this.jsonData.length) {
                    this.jsonData = this.jsonData.map((section) => ({
                        ...section,
                        displayHeading: this.translateDetailHeading(section.headingName),
                        headingFieldValue: (section.headingFieldValue || []).map((field) => ({
                            ...field,
                            label: this.translateDetailLabel(field.originalLabel || field.label)
                        }))
                    }));
                }
            })
            .catch(() => {
                // keep English defaults
            });
    }

    loadRecords() {
        this.showSpinner = true;
        fetchBusinessLicense({ status: this.status, countyName: this.countyName, professionName: this.professionName, searchCriteria: this.searchCriteria, partialRequires: this.partialRequires }).then(result => {
            if (result && !result.length) {
                showAsyncErrorMessage(this, this.labels.lsNoData);
                this.licenseRecordsSize = this.labels.lsNoData;
                this.licenseSearchData = [];
            } else {
                this.recordsData = result;
                this.licenseSearchData = JSON.parse(JSON.stringify(result));
                if (this.licenseSearchData != null && this.licenseSearchData[0]?.boardName == 'Nursing') {
                    this.isNursing = true;
                    this.licenseSearchData = [];
                } else {
                    this.isNursing = false;
                    this.licenseRecordsSize =
                        this.licenseSearchData.length + ' ' + this.labels.lsRecordsFound;
                    this.currentPage = 1;
                }
                this.setFocusOnResult();
            }
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }
    loadRecordsWithoutCountyFilter() {
        fetchBLWithoutCounty({ status: this.status, professionName: this.professionName, searchCriteria: this.searchCriteria, partialRequires: this.partialRequires }).then(result => {
            console.log('result ==> ' + JSON.stringify(result));
            if (result && !result.length) {
                console.log('No Data found');
                showAsyncErrorMessage(this, this.labels.lsNoData);
                this.licenseRecordsSize = this.labels.lsNoData;
                this.licenseSearchData = [];
            } else {
                this.recordsData = result;
                this.licenseSearchData = JSON.parse(JSON.stringify(result));
                if (this.licenseSearchData != null && this.licenseSearchData.length > 0 && this.licenseSearchData[0]?.boardName == 'Nursing') {
                    this.isNursing = true;
                    this.licenseSearchData = [];
                } else {
                    this.isNursing = false;
                    this.licenseRecordsSize =
                        this.licenseSearchData.length + ' ' + this.labels.lsRecordsFound;
                    this.currentPage = 1;
                }
                this.setFocusOnResult();
            }
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }
    loadData() {
        this.showSpinner = true;
        loadPicklistValues({ status: this.status }).then(result => {
            if (!result) {
                showAsyncErrorMessage(this, this.labels.lsNoData);
                return;
            } else {
                this.professionList = JSON.parse(JSON.stringify(result));
                this.professionList.sort((a, b) => a.label.localeCompare(b.label));
            }
        }).catch(error => {
            showAsyncErrorMessage(this, error);
        }).finally(() => {
            this.showSpinner = false;
        })
    }
    submitButtonHandler(event) {
        const hasError = Array.from(this.template.querySelectorAll('.slds-has-error')).some(field => {
            return field.classList.contains('slds-has-error');
        });

        this.showSpinner = true;
        if (this.professionName == 'Nursing') {
            this.isNursing = true;
            this.showSpinner = false;
        } else {
            this.isNursing = false;
            if (this.countyName.trim() !== '') {
                if (hasError) {
                    showAsyncErrorMessage(this, 'Invalid input.');
                    this.showSpinner = false;
                } else {
                     this.loadRecords();
                } 
            } else if (this.countyName == '') {
                if (this.searchCriteria == 'None' && this.professionName == '') {
                    showAsyncErrorMessage(this, 'Select Atleast one more filter');
                    this.showSpinner = false;
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    setTimeout(() => {
                    this.setFocusOnFirstInteractiveElement();
                    }, 4000);
                } else {
                    if (hasError) {
                        showAsyncErrorMessage(this, 'Invalid input.');
                        this.showSpinner = false;
                    } else {
                        this.loadRecordsWithoutCountyFilter();
                    } 
                }
            }
        }
    }
    //Added By Piyush to set the focus on the First Interactive Element 
    setFocusOnFirstInteractiveElement(){
        const firstInteractiveElement = this.template.querySelector('.firstInteractiveElement');
        if (firstInteractiveElement) {
            firstInteractiveElement.focus();
        }
    }
    //Ended By Piyush to set the focus on the First Interactive Element 

    handleChangeActiveInactive(event) {
        this.status = event.detail.value;
        this.licenseMessage =
            this.status === 'Non Active'
                ? this.labels.lsNonActiveOnly
                : this.labels.lsActiveOnly;
        this.loadData();
    }

    handleChangeCounty(event) {
        this.countyName = event.detail.value;

    }
    handleChangeProfession(event) {
        this.professionName = event.detail.value;
    }
    handleChangeCriteria(event) {
        if (event.target.value == 'None') {
            this.partialRequires = '';
            this.disablePartialText = true;
        } else {
            this.disablePartialText = false;
        }
        this.searchCriteria = event.target.value;
    }
    handelPartialTextInput(event) {
        let isHtmlTag = !/^[a-zA-Z0-9]+$/.test(event.detail.value)
        if (isHtmlTag) {
            event.target.setCustomValidity('Invalid input. This field only accepts letters and numbers. Special characters are not allowed.');
            event.target.reportValidity();
            event.target.classList.add('slds-has-error');
        } else {
            event.target.classList.remove('slds-has-error');
            event.target.setCustomValidity('');
            event.target.reportValidity();
            this.partialRequires = (event.detail.value).trim();
            console.log('partial require',this.partialRequires)
        }
    }
    resetButtonHandler() {
        location.reload();
    }

    // county names
    countyNames = [
        {
            'label': 'Adair',
            'value': 'Adair'
        },
        {
            'label': 'Andrew',
            'value': 'Andrew'
        },
        {
            'label': 'Atchison',
            'value': 'Atchison'
        },
        {
            'label': 'Audrain',
            'value': 'Audrain'
        },
        {
            'label': 'Barry',
            'value': 'Barry'
        },
        {
            'label': 'Barton',
            'value': 'Barton'
        },
        {
            'label': 'Bates',
            'value': 'Bates'
        },
        {
            'label': 'Benton',
            'value': 'Benton'
        },
        {
            'label': 'Bollinger',
            'value': 'Bollinger'
        },
        {
            'label': 'Boone',
            'value': 'Boone'
        },
        {
            'label': 'Buchanan',
            'value': 'Buchanan'
        },
        {
            'label': 'Butler',
            'value': 'Butler'
        },
        {
            'label': 'Caldwell',
            'value': 'Caldwell'
        },
        {
            'label': 'Callaway',
            'value': 'Callaway'
        },
        {
            'label': 'Camden',
            'value': 'Camden'
        },
        {
            'label': 'Cape Girardeau',
            'value': 'Cape Girardeau'
        },
        {
            'label': 'Carroll',
            'value': 'Carroll'
        },
        {
            'label': 'Carter',
            'value': 'Carter'
        },
        {
            'label': 'Cass',
            'value': 'Cass'
        },
        {
            'label': 'Cedar',
            'value': 'Cedar'
        },
        {
            'label': 'Chariton',
            'value': 'Chariton'
        },
        {
            'label': 'Christian',
            'value': 'Christian'
        },
        {
            'label': 'Clark',
            'value': 'Clark'
        },
        {
            'label': 'Clay',
            'value': 'Clay'
        },
        {
            'label': 'Clinton',
            'value': 'Clinton'
        },
        {
            'label': 'Cole',
            'value': 'Cole'
        },
        {
            'label': 'Cooper',
            'value': 'Cooper'
        },
        {
            'label': 'Crawford',
            'value': 'Crawford'
        },
        {
            'label': 'Dade',
            'value': 'Dade'
        },
        {
            'label': 'Dallas',
            'value': 'Dallas'
        },
        {
            'label': 'Daviess',
            'value': 'Daviess'
        },
        {
            'label': 'DeKalb',
            'value': 'DeKalb'
        },
        {
            'label': 'Dent',
            'value': 'Dent'
        },
        {
            'label': 'Douglas',
            'value': 'Douglas'
        },
        {
            'label': 'Dunklin',
            'value': 'Dunklin'
        },
        {
            'label': 'Franklin',
            'value': 'Franklin'
        },
        {
            'label': 'Gasconade',
            'value': 'Gasconade'
        },
        {
            'label': 'Gentry',
            'value': 'Gentry'
        },
        {
            'label': 'Greene',
            'value': 'Greene'
        },
        {
            'label': 'Grundy',
            'value': 'Grundy'
        },
        {
            'label': 'Harrison',
            'value': 'Harrison'
        },
        {
            'label': 'Henry',
            'value': 'Henry'
        },
        {
            'label': 'Hickory',
            'value': 'Hickory'
        },
        {
            'label': 'Holt',
            'value': 'Holt'
        },
        {
            'label': 'Howard',
            'value': 'Howard'
        },
        {
            'label': 'Howell',
            'value': 'Howell'
        },
        {
            'label': 'Iron',
            'value': 'Iron'
        },
        {
            'label': 'Jackson',
            'value': 'Jackson'
        },
        {
            'label': 'Jasper',
            'value': 'Jasper'
        },
        {
            'label': 'Jefferson',
            'value': 'Jefferson'
        },
        {
            'label': 'Johnson',
            'value': 'Johnson'
        },
        {
            'label': 'Knox',
            'value': 'Knox'
        },
        {
            'label': 'Laclede',
            'value': 'Laclede'
        },
        {
            'label': 'Lafayette',
            'value': 'Lafayette'
        },
        {
            'label': 'Lawrence',
            'value': 'Lawrence'
        },
        {
            'label': 'Lewis',
            'value': 'Lewis'
        },
        {
            'label': 'Lincoln',
            'value': 'Lincoln'
        },
        {
            'label': 'Linn',
            'value': 'Linn'
        },
        {
            'label': 'Livingston',
            'value': 'Livingston'
        },
        {
            'label': 'Macon',
            'value': 'Macon'
        },
        {
            'label': 'Madison',
            'value': 'Madison'
        },
        {
            'label': 'Maries',
            'value': 'Maries'
        },
        {
            'label': 'Marion',
            'value': 'Marion'
        },
        {
            'label': 'Mcdonald',
            'value': 'Mcdonald'
        },
        {
            'label': 'Mercer',
            'value': 'Mercer'
        },
        {
            'label': 'Miller',
            'value': 'Miller'
        },
        {
            'label': 'Mississippi',
            'value': 'Mississippi'
        },
        {
            'label': 'Moniteau',
            'value': 'Moniteau'
        },
        {
            'label': 'Monroe',
            'value': 'Monroe'
        },
        {
            'label': 'Montgomery',
            'value': 'Montgomery'
        },
        {
            'label': 'Morgan',
            'value': 'Morgan'
        },
        {
            'label': 'New Madrid',
            'value': 'New Madrid'
        },
        {
            'label': 'Newton',
            'value': 'Newton'
        },
        {
            'label': 'Nodaway',
            'value': 'Nodaway'
        },
        {
            'label': 'Oregon',
            'value': 'Oregon'
        },
        {
            'label': 'Osage',
            'value': 'Osage'
        },
        {
            'label': 'Ozark',
            'value': 'Ozark'
        },
        {
            'label': 'Pemiscot',
            'value': 'Pemiscot'
        },
        {
            'label': 'Perry',
            'value': 'Perry'
        },
        {
            'label': 'Pettis',
            'value': 'Pettis'
        },
        {
            'label': 'Phelps',
            'value': 'Phelps'
        },
        {
            'label': 'Pike',
            'value': 'Pike'
        },
        {
            'label': 'Platte',
            'value': 'Platte'
        },
        {
            'label': 'Polk',
            'value': 'Polk'
        },
        {
            'label': 'Pulaski',
            'value': 'Pulaski'
        },
        {
            'label': 'Putnam',
            'value': 'Putnam'
        },
        {
            'label': 'Ralls',
            'value': 'Ralls'
        },
        {
            'label': 'Randolph',
            'value': 'Randolph'
        },
        {
            'label': 'Ray',
            'value': 'Ray'
        },
        {
            'label': 'Reynolds',
            'value': 'Reynolds'
        },
        {
            'label': 'Ripley',
            'value': 'Ripley'
        },
        {
            'label': 'Saline',
            'value': 'Saline'
        },
        {
            'label': 'Schuyler',
            'value': 'Schuyler'
        },
        {
            'label': 'Scotland',
            'value': 'Scotland'
        },
        {
            'label': 'Scott',
            'value': 'Scott'
        },
        {
            'label': 'Shannon',
            'value': 'Shannon'
        },
        {
            'label': 'Shelby',
            'value': 'Shelby'
        },
        {
            'label': 'St. Charles',
            'value': 'St. Charles'
        },
        {
            'label': 'St. Clair',
            'value': 'St. Clair'
        },
        {
            'label': 'St. Francois',
            'value': 'St. Francois'
        },
        {
            'label': 'St. Louis City',
            'value': 'St. Louis City'
        },
        {
            'label': 'St. Louis County',
            'value': 'St. Louis County'
        },
        {
            'label': 'Ste. Genevieve',
            'value': 'Ste. Genevieve'
        },
        {
            'label': 'Stoddard',
            'value': 'Stoddard'
        },
        {
            'label': 'Stone',
            'value': 'Stone'
        },
        {
            'label': 'Sullivan',
            'value': 'Sullivan'
        },
        {
            'label': 'Taney',
            'value': 'Taney'
        },
        {
            'label': 'Texas',
            'value': 'Texas'
        },
        {
            'label': 'Vernon',
            'value': 'Vernon'
        },
        {
            'label': 'Warren',
            'value': 'Warren'
        },
        {
            'label': 'Washington',
            'value': 'Washington'
        },
        {
            'label': 'Wayne',
            'value': 'Wayne'
        },
        {
            'label': 'Webster',
            'value': 'Webster'
        },
        {
            'label': 'Worth',
            'value': 'Worth'
        },
        {
            'label': 'Wright',
            'value': 'Wright'
        }
    ];

    openDetailPage(event) {
        this.showSpinner = true;
        this.selectedBlId = event.target.dataset.id;
        this.publicAddressId = event.target.dataset.addid;
        this.getApplicationData();
    }

    @track pageSize = 10; // Number of records to display per page
    @track currentPage = 1;

    // Compute the total number of pages based on data length and page size
    get totalPages() {
        if (this.licenseSearchData.length == 0) {
            return 1;
        }
        return Math.ceil(this.licenseSearchData.length / this.pageSize);
    }

    // Compute the data to be displayed for the current page
    get displayedData() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        return this.licenseSearchData.slice(startIndex, endIndex);
    }

    // Handle previous page button click
    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
        this.setFocusOnpageNumberOnNextPreviousElement();
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
        this.setFocusOnpreviousPageBack();
    }, 2000);
    }

    // Handle next page button click
    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
        this.setFocusOnpageNumberOnNextPreviousElement();
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
        this.setFocusOnNextPageBack();
        }, 2000);
    }
    //Added By Piyush to set the focus on the First Interactive Element 
    setFocusOnpageNumberOnNextPreviousElement(){
        const pageCount = this.template.querySelector('.pageCount');
        if (pageCount) {
            pageCount.setAttribute('tabindex', '0');
            pageCount.focus();
        }
    }
    setFocusOnpreviousPageBack(){
        const previousButtonClass = this.template.querySelector('.previousButtonClass');
        const nextButtonClass = this.template.querySelector('.nextButtonClass');
        if (previousButtonClass && !(this.disablePreviousbutton)) {
            previousButtonClass.focus();
        }else if (nextButtonClass){
            nextButtonClass.focus();
        }

    }
    setFocusOnNextPageBack(){
        const nextButtonClass = this.template.querySelector('.nextButtonClass');
        const previousButtonClass = this.template.querySelector('.previousButtonClass');
        if (nextButtonClass && !(this.disableNextButton)) {
            nextButtonClass.focus();
        }else if (previousButtonClass){
            previousButtonClass.focus();
        }
    }   
    //Ended By Piyush to set the focus on the First Interactive Element 


    getApplicationData() {
        this.showErrorForNoLicense = false;
        console.log('selectedBlId ==> ' + this.selectedBlId);
        console.log('publicAddressId ==> ' + this.publicAddressId);
        console.log('status ==> ' + this.status);
        console.log('directApplication ==> ' + this.directApplication);
        getApplicationData({
            blId: this.selectedBlId,
            addId: this.publicAddressId || null,
            status: this.status,
            directApplication: this.directApplication ? 'true' : 'false'
        })
            .then((result) => {
                console.log('result ==> ' + JSON.stringify(result));
                this.showLicenseResult = true;
                if (result !== null) {
                    this.jsonData = JSON.parse(JSON.stringify(result)).map((section, index) => {
                        const headingName = section.headingName || '';
                        const fields = (section.headingFieldValue || []).map((field, fieldIndex) => {
                            const originalLabel = field.label;
                            return {
                                ...field,
                                originalLabel,
                                label: this.translateDetailLabel(originalLabel),
                                fieldKey: `${headingName}-${originalLabel || 'field'}-${fieldIndex}`
                            };
                        });
                        return {
                            ...section,
                            headingFieldValue: fields,
                            sectionKey: `${headingName}-${index}`,
                            // Hide generic "License" heading under Licensee Details; show Address / other section titles
                            showHeading: headingName && headingName !== 'License',
                            displayHeading: this.translateDetailHeading(headingName)
                        };
                    });
										console.log('Json data =  ' , this.jsonData)
                } else {
                    this.showErrorForNoLicense = true;
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                showAsyncErrorMessage(this, error?.body?.message);
                this.showSpinner = false;
            });
    }
    handleBackToLicenseSearch() {
        this.showSpinner = true;
        this.selectedBlId = '';
        this.showLicenseResult = false;
        this.showSpinner = false;
    }

    translateDetailHeading(headingName) {
        if (headingName === 'Address') {
            return this.labels.lsAddressInfo || 'Address Information';
        }
        if (headingName === 'License') {
            return this.labels.lsLicenseeDetails || 'Licensee Details';
        }
        return headingName;
    }

    translateDetailLabel(label) {
        if (!label) {
            return label;
        }
        const map = {
            'Licensee Name': this.labels.lsLicenseeName,
            'Profession Name': this.labels.lsProfessionName,
            'License Number': this.labels.lsLicenseNumber,
            'Expiration Date': this.labels.lsExpirationDate,
            'Original Issue Date': this.labels.lsOriginalIssueDate,
            Street: this.labels.lsStreet,
            Steet: this.labels.lsStreet,
            City: this.labels.lsCity,
            State: this.labels.lsState,
            PostalCode: this.labels.lsPostalCode,
            'Zip Code': this.labels.lsZipCode,
            County: this.labels.lsCountyField,
            Status: this.labels.lsStatus
        };
        return map[label] || label;
    }

    // Placeholder for print license action
    handlePrintLicense() {
        showMessage(this, {
            title: this.labels.lsPrintLicense || 'Print License',
            message: 'Print License functionality will be available soon.',
            messageType: 'info',
            mode: 'dismissable'
        });
    }
    //This method is used to scroll down to the result section once the search is completed
    setFocusOnResult(){
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
           window.scrollTo(0,  
            this.getElementPosition(this.template.querySelector(".resultCard"))-100);
        }, 600); 
        //Added By Piyush to set the focus on the Result found
        const resultFound = this.template.querySelector('.resultFound');
        if (resultFound) {
            resultFound.setAttribute('tabindex', '0');
            resultFound.focus();
        }
        //Ended By Piyush to set the focus on the Result found
    }

    //This method is used to get position of the search result section
    getElementPosition(element){
        let currenttop = 0;
        if (element.offsetParent) {
            do {
                currenttop += element.offsetTop;
            } while ((element = element.offsetParent));
            return [currenttop];
        }
    }
    get disablePreviousbutton() {
        return this.currentPage == 1;
    }
    get disableNextButton() {
        return this.totalPages == this.currentPage;
    }
}