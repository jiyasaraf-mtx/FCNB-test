import { LightningElement, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
// import EEC_DesignLead from "@salesforce/resourceUrl/EEC_DesignLead";
import { loadStyle } from 'lightning/platformResourceLoader';
import getData from "@salesforce/apex/LPI_RelatedListCmpController.getData";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LpiRelatedListCmp extends NavigationMixin(LightningElement) {


    @api columns;
    @api objectName;
    @api relatedFieldApiName;
    @api condition;
    @api recordId;
    @api title;
    @api iconName;
    @track allColumnsList;
    @track allData;
    @track allData10List;
    @track showViewAll;
    @track dataSize;
    @track showModal = false;
    @track selectedRecordId;
    @track modalSpinner = false;
    @track allColumnsDataList;
    @track sortColumnIndex = 0;
    @track sortColumnName;


    /*
    @Method : relatedData
    @param :
    @return : list of data
    @purpose : sort the data and return it.
    */
    get relatedData() {
        let sortedData = [];
        if (this.allData10List != undefined) {
            if (this.allColumnsList[this.sortColumnIndex].isDesc) {
                sortedData = this.sort(this.allData10List, this.sortColumnName, 'dsc', this.allColumnsList[this.sortColumnIndex].type);
            } else if (this.allColumnsList[this.sortColumnIndex].isAsc) {
                sortedData = this.sort(this.allData10List, this.sortColumnName, 'asc', this.allColumnsList[this.sortColumnIndex].type);
            } else if (this.allColumnsList[this.sortColumnIndex].sortIcon) {
                sortedData = this.sort(this.allData10List, 'Name', 'dsc', this.allColumnsList[this.sortColumnIndex].type);
            }
            return sortedData;
        } else {
            return [];
        }
    }


    /*
    @Method : sort
    @param : list of data to be sorted, key name of the object, order in which sorting is done, type of the column
    @return : list of sorted data
    @purpose : sort the data and return it.
    */
    sort(dataToSort, fieldname, direction, type) {
        try {
            let data = JSON.parse(JSON.stringify(dataToSort));
            let keyValue = (a) => {
                let dataVal;
                a.row.forEach(element => {
                    if (element.columnName == fieldname) {
                        dataVal = element.data;
                    }
                })
                return dataVal;
            };
            let isReverse = direction === 'asc' ? 1 : -1;
            if (type == 'date') {
                data.sort(function (a, b) {
                    a = keyValue(a) ? keyValue(a) : '';
                    b = keyValue(b) ? keyValue(b) : '';
                    const x = a != '' ? new Date(a) : '';
                    const y = b != '' ? new Date(b) : '';
                    if (direction == 'asc') {
                        return x - y;
                    } else {
                        return y - x;
                    }

                });
            } else {
                data.sort((Value1, Value2) => {
                    Value1 = keyValue(Value1) ? keyValue(Value1) : '';
                    Value2 = keyValue(Value2) ? keyValue(Value2) : '';
                    return isReverse * ((Value1 > Value2) - (Value2 > Value1));
                });
            }
            return data;
        } catch (error) {
            this.showToastMessage("Error!", JSON.stringify(error), "error");
            console.log('sortterroorr ' + error);

        }
    }

    connectedCallback() {
        // loadStyle(this, EEC_DesignLead + '/EEC_DesignLead/styles/internalmain.css');


        this.fetchAllData();

    }


    /*
    @Method : showAllData
    @purpose : Gets triggered on click of View All to display all the records.
    */
    showAllData() {
        this.showViewAll = false;
        this.allData10List = JSON.parse(JSON.stringify(this.allData));
    }


    /*
    @Method : fetchAllData
    @purpose : Makes apex call to fetch all the data.
    */
    fetchAllData() {
        getData({
            columnWrapper: this.columns,
            parentId: this.recordId,
            parentFieldName: this.relatedFieldApiName,
            objectName: this.objectName,
            queryCondition: this.condition
        })
            .then(result => {
                this.allColumnsDataList = result.columns;
                this.allColumnsList = result.columns;
                this.allData = result.data;



                if (this.allData.length > 10) {
                    this.allData10List = result.data.slice(0, 10);
                    this.showViewAll = true;
                    this.dataSize = '10+';
                } else {
                    this.allData10List = result.data;
                    this.showViewAll = false;
                    this.dataSize = this.allData.length;
                }
            })
            .catch(error => {
                this.showToastMessage("Error!", JSON.stringify(error), "error");
                console.log('cache error--->' + JSON.stringify(error));
            });
    }


    /*
    @Method : onEditClick
    @purpose : Navigate to the edit modal of the records on clicking of edit button
    */
    onEditClick(event) {
        let recordId = event.target.getAttribute('data-id');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'edit'
            }
        });
    }


    /*
    @Method : onDeleteClick
    @purpose : Open confirmation modal on click of delete
    */
    onDeleteClick(event) {
        this.selectedRecordId = event.target.getAttribute('data-id');
        this.showModal = true;
    }


    /*
    @Method : onCancel
    @purpose : Closed the confirmation modal
    */
    onCancel() {
        this.showModal = false;
    }


    /*
    @Method : onDelete
    @purpose : Delete the selected record
    */
    onDelete(event) {
        this.modalSpinner = true;
        deleteRecord(this.selectedRecordId)
            .then(() => {
                this.showToastMessage("Success!", 'Record deleted successfully', "success");
                this.fetchAllData();
                this.modalSpinner = false;
                this.showModal = false;
            })
            .catch(error => {
                this.modalSpinner = false;
                this.showToastMessage("Error!", JSON.stringify(error), "error");
                console.log('cache error--->' + JSON.stringify(error));
            });
    }


    /*
    @Method : handleSorting
    @purpose : Handles the column on which sorting will be done.
    */
    handleSorting(event) {
        this.allColumnsList = JSON.parse(JSON.stringify(this.allColumnsDataList));
        this.sortColumnName = event.target.getAttribute('data-name');
        this.sortColumnIndex = event.target.getAttribute('data-index');
        let sortingOrder = event.target.getAttribute('data-id');
        if (sortingOrder == 'sortIcon') {
            this.allColumnsList[this.sortColumnIndex][sortingOrder] = false;
            this.allColumnsList[this.sortColumnIndex]['isAsc'] = true;
            this.allColumnsList[this.sortColumnIndex]['isDesc'] = false;
        } else if (sortingOrder == 'isDesc') {
            this.allColumnsList[this.sortColumnIndex][sortingOrder] = false;
            this.allColumnsList[this.sortColumnIndex]['isAsc'] = true;
            this.allColumnsList[this.sortColumnIndex]['sortIcon'] = false;
        } else {
            this.allColumnsList[this.sortColumnIndex][sortingOrder] = false;
            this.allColumnsList[this.sortColumnIndex]['isDesc'] = true;
            this.allColumnsList[this.sortColumnIndex]['sortIcon'] = false;
        }
    }


    /*
   @Method : showToastMessage
   @purpose : for showing toast message.
   */
    showToastMessage(title, message, variant) {
        const event = new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": 'sticky'
        });
        this.dispatchEvent(event);
    }

}