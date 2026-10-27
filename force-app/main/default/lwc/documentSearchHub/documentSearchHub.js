import { LightningElement, track, wire } from 'lwc';
import getFilterOptions from '@salesforce/apex/DocumentSearchController.getFilterOptions';
import searchDocuments from '@salesforce/apex/DocumentSearchController.searchDocuments';

const COLUMNS = [
    {
        label: 'Document Name',
        fieldName: 'documentUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Document_Name__c' }, target: '_blank' }
    },
    {
        label: 'Category Reference',
        fieldName: 'parentUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'parentName' }, target: '_blank' }
    },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Record Type', fieldName: 'Type__c' }
];

export default class DocumentSearchHub extends LightningElement {
    columns = COLUMNS;

    @track selectedCategory = 'Application';
    @track selectedType = '';
    @track selectedStatus = '';
    @track searchKey = '';

    categoryOptions = [
        { label: 'Application', value: 'Application' }
    ];
    typeOptions = [];
    statusOptions = [];

    documents = [];
    error;

    @wire(getFilterOptions)
    wiredOptions({ error, data }) {
        if (data) {
            this.statusOptions = data.statusOptions || [];
            this.typeOptions = data.typeOptions || [];
        } else if (error) {
            console.error('Error loading filters:', error);
        }
    }

    connectedCallback() {
        this.fetchDocuments();
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.fetchDocuments();
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.fetchDocuments();
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
        this.fetchDocuments();
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.detail.value;
        this.fetchDocuments();
    }

    handleClear() {
        this.selectedCategory = 'Application';
        this.selectedType = '';
        this.selectedStatus = '';
        this.searchKey = '';
        this.fetchDocuments();
    }

    fetchDocuments() {
        searchDocuments({
            category: this.selectedCategory,
            selectedType: this.selectedType,
            status: this.selectedStatus,
            searchKey: this.searchKey
        })
        .then(result => {
            this.documents = result.map(row => {
                return {
                    ...row,
                    documentUrl: '/' + row.Id,
                    Document_Name__c: row.Document_Name__c ? row.Document_Name__c : row.Name,
                    parentName: row.Individual_Application__r ? row.Individual_Application__r.Name : '',
                    parentUrl: row.Individual_Application__c ? '/' + row.Individual_Application__c : ''
                };
            });
            this.error = undefined;
        })
        .catch(err => {
            this.error = err.body ? err.body.message : 'Error fetching records';
            this.documents = [];
        });
    }
}