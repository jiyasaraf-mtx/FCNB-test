import createCertificationRecord from "@salesforce/apex/LPI_AuditDetailController.createCertificationRecord";
import createInsuranceRecord from "@salesforce/apex/LPI_AuditDetailController.createInsuranceRecord";
import createTrainCoursePartData from "@salesforce/apex/LPI_AuditDetailController.createTrainingCourseParticiantRecords";
import deleteTrainCoursePartData from "@salesforce/apex/LPI_AuditDetailController.deleteTrainingCourseParticiantRecords";
import getAuditData from "@salesforce/apex/LPI_AuditDetailController.getAuditData";
import getTrainCoursePartData from "@salesforce/apex/LPI_AuditDetailController.getTrainingCourseParticiantRecords";
import updateAuditStatus from "@salesforce/apex/LPI_AuditDetailController.updateAuditStatus";
import handleUpdateFileStatus from '@salesforce/apex/LPI_AuditDocumentController.updateAppDocStatusOnCancel';
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { LightningElement, api, track, wire } from "lwc";
import lpiResource from '@salesforce/resourceUrl/LPI_Design';
export default class LpiAuditDetailsComp extends NavigationMixin(LightningElement) {
	showSpinner = false;
	@track courseDetailData = {};
	@track courseInfoList = [];
	@track selectedCourseInfoIndex = "";
	@track appDocumentList = [];
	@track flowDocumentsList = [];
	@track preCourseInfoList = [];
	openConfirmationModal = false;
	courseDetailPopupOpen = false;
	recordExist = false;
	ceAudit = false;
	certificationAudit = false;
	insuranceAudit = false;
	cdrAudit = false;
	@track certificationData = {};
	@track insuranceData = {};
	boardName;
	cureHoursCheckBox;
	auditData = {};
	//ceHoursCheckBox;
	cureHours;
	yearCure;
	gracePeriod;
	openSubmitConfirmationModal = false;
	@track blId = "";

	noRecord = lpiResource + '/media/icons/no-record.svg';
	actions = [
		{
			label: "Edit",
			value: "Edit"
		},
		{
			label: "Delete",
			value: "Delete"
		}
	];
	@track tempData = {};
	_recordId;
	@api notificationId;
	startDate;
	endDate;
	currentAppDocId;
	isCeAudit = true;
	@track appDocIdList = [];
	courseIdForDelete;

	@api
	set recordId(value) {
		this.showSpinner = true;
		this._recordId = value;
	}
	get recordId() {
		return this._recordId;
	}

	@wire(CurrentPageReference)
	currentPageReference;

	connectedCallback() {
		this.showSpinner = true;
		if (`${this.currentPageReference.state.audId}` !== "undefined") {
			this.recordId = `${this.currentPageReference.state.audId}`;
			this.notificationId =
				`${this.currentPageReference.state.notificationId}` !== "undefined"
					? `${this.currentPageReference.state.notificationId}`
					: null;
			getAuditData({
				audId: this.recordId,
				notificationId: this.notificationId
			})
				.then((result) => {
					if (result?.isAllowed) {
						this.auditData = result;
						this.cureHoursCheckBox = result?.cureHours;
						this.getTrainingCourseParticipantData();
					} else {
						this.showMessage(
							"Error",
							"Either Audit Period is ended or you already completed the Audit.",
							"error"
						);
						this[NavigationMixin.Navigate]({
							type: "standard__namedPage",
							attributes: {
								pageName: "dashboard"
							}
						});
					}
				})
				.catch((error) => {
					this.showMessage("Error", error?.body?.message, "error");
					this.showSpinner = false;
				});
		}
	}

	// Fetching Training Course Participant records
	getTrainingCourseParticipantData() {
		this.courseInfoList = [];
		getTrainCoursePartData({
			audId: this.recordId
		})
			.then((data) => {
				if (data != null) {
					this.preCourseInfoList = data;
					this.preCourseInfoList.forEach((courseInfo) => {
						this.courseDetailData = Object.assign({}, courseInfo);
						this.blId = this.courseDetailData.blId;
						if (this.courseDetailData.audRecTypeName === "CE_Audit") {
							this.ceAudit = true;
						} else if (this.courseDetailData.audRecTypeName === "Certification_Audit") {
							this.certificationAudit = true;
						} else if (this.courseDetailData.audRecTypeName === "Insurance_Audit") {
							this.insuranceAudit = true;
						} else if (this.courseDetailData.audRecTypeName === "CDR_Audit") {
							this.cdrAudit = true;
						}

						if (this.courseDetailData.audRecTypeName === "CE_Audit") {
							this.courseDetailData.index = this.courseInfoList.length;
							if (
								this.courseDetailData.subjectAreaList != null &&
								this.courseDetailData.subjectAreaList !== undefined &&
								this.courseDetailData.subjectAreaList.length > 0
							) {
								let subjectAreaList = [];
								for (let i = 0; i < this.courseDetailData.subjectAreaList.length; i++) {
									let subAreaObject = Object.assign({}, this.courseDetailData.subjectAreaList[i]);
									subAreaObject.index = i;
									subAreaObject.showAddButton =
										i === this.courseDetailData.subjectAreaList.length - 1;
									subjectAreaList.push(subAreaObject);
								}
								this.courseDetailData.subjectAreaList = subjectAreaList;
							} else {
								this.courseDetailData.subjectAreaList = [{ index: 0, showAddButton: true }];
							}
							if (this.courseDetailData.course !== null && this.courseDetailData.course !== undefined) {
								this.courseInfoList.push(this.courseDetailData);
							}
						}
						this.boardName = this.courseDetailData.boardName;
					});
				}
				this.showSpinner = false;
			})
			.catch((error) => {
				this.showMessage("Error", error?.body?.message, "error");
				this.showSpinner = false;
			});
	}

	get options() {
		return [
			{ label: "A", value: "A" },
			{ label: "B", value: "B" }
		];
	}
	get isBoardNameAccountancy() {
		return this.boardName === "Accountancy" ? true : false;
	}
	get isBoardNamePsychologists() {
		return this.boardName === "Psychologists" ? true : false;
	}

	get displayCourseInfoList() {
		return this.courseInfoList && this.courseInfoList.length > 0;
	}

	// Added Courses
	addCourseButton() {
		if (this.boardName === "Accountancy") {
			this.courseDetailData = { subjectAreaList: [{ index: 0, showAddButton: true }], hours: 0 };
		} else {
			this.courseDetailData = {};
		}
		this.courseDetailPopupOpen = true;
		//S-57276 added by Vamshi
		setTimeout(() => {
			this.focusFirstEle();
		}, 200);
	}

	// Close Courses Model Pop Up
	closeModelAuthContact() {
		this.courseDetailPopupOpen = false;
		//S-57276 added by Vamshi
		if (this.courseInfoList != null && this.courseInfoList.length > 0) {
			this.focusOnInitialButton("addCourseFocus");
			// this.focusOnInitialButton("editFocus");
		} else {
			this.focusOnInitialButton("addCourseFocus");
		}
		this.handleFilesStatus(false);
	}

	// storing individual course data in a object
	handleCourseInfoInputs(event) {
		if (event.target.type === "checkbox") {
			if (event.target.name.split(".").length > 1) {
				this.courseDetailData[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
					event.target.checked;
			} else {
				this.courseDetailData[event.target.name.split(".")[0]] = event.target.checked;
				/*
				if (event.target.name === "cureHours") {
					this.ceHoursCheckBox = event.target.checked;
				}*/
			}
		} else {
			if (event.target.name.split(".").length > 1) {
				this.courseDetailData[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
					event.target.value.trim();
			} else {
				this.courseDetailData[event.target.name.split(".")[0]] = event.target.value.trim();
			}
		}
		//added for 58678
		this.courseDetailData.editButtonAriaLabel = "Edit " + this.courseDetailData.course;
		this.courseDetailData.deleteButtonAriaLabel = "Delete " + this.courseDetailData.course;
	}

	// Saving Course records
	saveCourseInfo() {
		console.log('000');
		if (this.checkValidityAuthValidate(true)) {
			console.log('111');
			this.courseDetailPopupOpen = false;
			this.saveCourseRecords();
		} else {
			// for accessbility issue
			setTimeout(() => {
				var allInput = this.template.querySelector(".slds-has-error");
				if (allInput) {
					allInput.scrollIntoView();
					allInput.focus();
				}
			}, 3000);
		}
	}

	// Saving Course records
	saveCourseRecords() {
		this.showSpinner = true;
		console.log('222');
		createTrainCoursePartData({
			audId: this.recordId,
			courseData: JSON.stringify(this.courseDetailData),
			appRecordIdList : this.appDocIdList
		})
			.then((data) => {
				if (data !== null && data !== undefined && data !== "") {
					let isCourseExist =
						this.courseDetailData.index !== undefined &&
						this.courseDetailData.index !== "" &&
						this.courseDetailData.index !== null;
						data.index = this.courseDetailData.index;
						this.courseDetailData = data;
					if (isCourseExist) {
						this.courseInfoList[this.courseDetailData.index] = this.courseDetailData;
						setTimeout(()=>{
							this.showMessage("Success", "Record updated Successfully", "success");
						},1000);
					} else {
						this.courseDetailData.index = this.courseInfoList.length;
						this.courseInfoList.push(this.courseDetailData);
						setTimeout(()=>{
							this.showMessage("Success", "Record created Successfully", "success");
						},1000);
					}
				} else {
					this.showMessage("Error", "Something went wrong!", "error");
				}
				//I-234824 added by Vamshi
				setTimeout(() => {
					this.focusOnInitialButton("addCourseFocus");
				}, 500);
			})
			.catch((error) => {
				this.showMessage("Error", error?.body?.message, "error");
			})
			.finally(() => {
				this.appDocIdList = [];
				this.showSpinner = false;
			});
	}

	// handling each record while editing the details
	handleCourseInfoEdit(event) {
		this.courseDetailData = Object.assign({}, this.courseInfoList[event.currentTarget.dataset.index]);
		this.courseDetailPopupOpen = true;
		//S-57276 added by Vamshi
		setTimeout(() => {
			this.template.querySelector('.editFocus').focus();
			this.focusFirstEle();
		}, 200);
	}

	// handling each record while deleting the details
	handleCourseInfoDelete(event) {
		this.modalHeading = "Are you sure you want to delete this Course Information?";
		this.selectedCourseInfoIndex = event.currentTarget.dataset.index;
		this.openConfirmationModal = true;
		//S-57276 added by Vamshi
		setTimeout(() => {
			this.template.querySelector('.deleteFocus').focus();
			this.focusFirstEle();
		}, 200);
	}

	// Deleting the course record
	deleteCourse() {
		this.showSpinner = true;
		this.courseIdForDelete = this.tempData.courseId;
		this.handleFilesStatus(true);
		deleteTrainCoursePartData({
			courseId: this.tempData.courseId
		})
			.then((data) => {
				if (data === true) {
					this.showMessage("Success", "Record deleted successfully", "success");
				} else {
					this.showMessage("Error", "Something went wrong!", "error");
				}
			})
			.catch((error) => {
				this.showMessage("Error", error?.body?.message, "error");
			})
			.finally(() => {
				this.showSpinner = false;
			});
	}

	// Handling the certification record
	handleCertificationInputs(event) {
		if (event.target.name.split(".").length > 1) {
			this.certificationData[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
				event.target.value.trim();
		} else {
			if (event.target.name === "startDate") {
				this.startDate = event.target.value;
			} else if (event.target.name === "endDate") {
				this.endDate = event.target.value;
			}
			this.certificationData[event.target.name.split(".")[0]] = event.target.value.trim();
		}
	}

	// Handling the submision of application for all three audits
	handleClickSubmit() {
		this.openSubmitConfirmationModal = false;
		if (this.certificationAudit) {
			if (this.checkCertificationDetailsValidate()) {
				this.modalHeadingSubmit = "Are you sure you want to submit this Certification Information?";
				let startDateValidate = this.template.querySelector(".certificationValidateStartDate");
				if (this.certificationData.startDate >= this.certificationData.endDate) {
					startDateValidate.setCustomValidity("Error! Start Date should be less than End Date");
					startDateValidate.reportValidity();
				} else {
					this.openSubmitConfirmationModal = true;
					setTimeout(() => {
						this.focusFirstEle();
					}, 200);
				}
			}
		} else if (this.insuranceAudit) {
			if (this.validateInsuranceDetails()) {
				this.openSubmitConfirmationModal = true;
				setTimeout(() => {
					this.focusFirstEle();
				}, 200);
				this.modalHeadingSubmit = "Are you sure you want to submit this Insurance Information?";
			}
		}else if(this.cdrAudit){
			this.openSubmitConfirmationModal = true;
				setTimeout(() => {
					this.focusFirstEle();
				}, 200);
				this.modalHeadingSubmit = "Are you sure you want to submit this CDR Information?";
		}else {
				if(this.courseInfoList.length === 0 && this.courseDetailData.audRecTypeName === "CE_Audit"){
					this.showMessage("Error", "Please add at least one course", "error");
				}else{
					if (this.checkValidityAuthValidate(false)) {
						this.modalHeadingSubmit = "Are you sure you want to submit this CE Audit Information?";
						this.openSubmitConfirmationModal = true;
						//added for S-58678
						setTimeout(() => {
							this.focusFirstEle();
						}, 500);
					}
				}
		}
		let allInput = this.template.querySelector(".slds-has-error");
		if (allInput) {
			allInput.scrollIntoView();
			allInput.focus();
		}
	}

	// Pop up for submission application
	handleSubmitConfirmation() {
		if (this.certificationAudit) {
			this.showSpinner = true;
			createCertificationRecord({
				audId: this.recordId,
				blId: this.blId,
				notificationId: this.notificationId,
				certificationRecData: JSON.stringify(this.certificationData)
			})
				.then((data) => {
					if (data) {
						this.showMessage("Success", "Record created Successfully", "success");
						this.openSubmitConfirmationModal = false;
						this.navigateToBusinessLicense();
					} else {
						this.showMessage("Error", "Something went wrong!", "error");
					}
				})
				.catch((error) => {
					this.showMessage("Error", error?.body?.message, "error");
				})
				.finally(() => {
					this.showSpinner = false;
				});
		} else if (this.insuranceAudit) {
			this.showSpinner = true;
			createInsuranceRecord({
				audId: this.recordId,
				blId: this.blId,
				notificationId: this.notificationId,
				insuranceRecData: JSON.stringify(this.insuranceData)
			})
				.then((data) => {
					if (data) {
						setTimeout(() => {
							this.showMessage("Success", "Record created Successfully", "success");
							this.openSubmitConfirmationModal = false;
						this.navigateToBusinessLicense();
						}, 500);
						
						
					} else {
						this.showMessage("Error", "Something went wrong!", "error");
					}
				})
				.catch((error) => {
					this.showMessage("Error", error?.body?.message, "error");
				})
				.finally(() => {
					this.showSpinner = false;
				});
		} else {
			this.showSpinner = true;
			updateAuditStatus({
				audId: this.recordId,
				notificationId: this.notificationId,
				auditDataString: JSON.stringify(this.auditData)
			})
				.then((data) => {
					if (data) {
						this.showMessage("Success", "Record created Successfully", "success");
						this.openSubmitConfirmationModal = false;
						this.navigateToBusinessLicense();
					}
				})
				.catch((error) => {
					this.showMessage("Error", error?.body?.message, "error");
				})
				.finally(() => {
					this.showSpinner = false;
				});
		}
	}

	// Validating course record inputs whether required fields are entered or not
	checkValidityAuthValidate(validateNotes) {
		let valid = false;

		valid = [...this.template.querySelectorAll(".auditDetailValidate")].reduce((validSoFar, input) => {
			//input.checkValidity()
			if (input.type === "date") {
				if (!input.checkValidity()) {
					input.classList.add("slds-has-error");
				} else {
					input.classList.remove("slds-has-error");
				}
			}
			input.reportValidity();
			return validSoFar && input.checkValidity();
		}, true);

		let isNotesValid = true;
		if (validateNotes) {
			let notesValidate = this.template.querySelector(".auditDetailValidateNotes");
			notesValidate.setCustomValidity("");
			let isHtmlTag = !/^((?!(<\s*|\s*>)).)*$/.test(notesValidate.value);
			if (this.courseDetailData?.notes?.length > 500 || isHtmlTag) {
				notesValidate.setCustomValidity(
					"Invalid input. This field only accepts letters and numbers. Special characters are not allowed and cannot allow more than 500 characters."
				);
				notesValidate.reportValidity();
				isNotesValid = false;
			}
		}
		return valid && isNotesValid;
	}

	// Validating certification record inputs whether required fields are entered or not
	checkCertificationDetailsValidate() {
		let valid = false;

		valid = [...this.template.querySelectorAll(".certificationValidate")].reduce((validSoFar, input) => {
			if (input.type === "date") {
				if (!input.checkValidity()) {
					input.classList.add("slds-has-error");
				} else {
					input.classList.remove("slds-has-error");
				}
			}
			input.reportValidity();
			return validSoFar && input.checkValidity();
		}, true);
		return valid;
	}

	// Handling Insurance record input
	handleInsuranceInputs(event) {
		if (event.target.name.split(".").length > 1) {
			this.insuranceData[event.target.name.split(".")[0]][event.target.name.split(".")[1]] =
				event.target.value.trim();
		} else {
			this.insuranceData[event.target.name.split(".")[0]] = event.target.value.trim();
		}
	}

	// Validating insurance record inputs whether required fields are entered or not
	validateInsuranceDetails() {
		let valid = false;

		valid = [...this.template.querySelectorAll(".insuranceValidate")].reduce((validSoFar, input) => {
			if (input.type === "date") {
				if (!input.checkValidity()) {
					input.classList.add("slds-has-error");
				} else {
					input.classList.remove("slds-has-error");
				}
			}
			input.reportValidity();
			return validSoFar && input.checkValidity();
		}, true);
		return valid;
	}

	// handling course model up when users click cancel
	handleCancelConfirmation() {
		this.courseDetailData = null;
		this.openConfirmationModal = false;
		this.appDocumentList = [];
		//I-234824 added by Vamshi
		if (this.courseInfoList != null && this.courseInfoList.length > 0) {
			this.focusOnInitialButton("deleteFocus");
		} else {
			this.focusOnInitialButton("addCourseFocus");
		}
	}

	// handling delete course record
	handleDeleteConfirmation() {
		this.tempData = this.courseInfoList[this.selectedCourseInfoIndex];
		this.deleteCourse(this.tempData);
		let temparr = [];
		temparr = [...this.courseInfoList];
		temparr.splice(Number(this.selectedCourseInfoIndex), 1);
		this.courseInfoList = [...temparr];
		this.openConfirmationModal = false;
		//S-57276 added by Vamshi
		if (this.courseInfoList != null && this.courseInfoList.length > 0) {
			this.focusOnInitialButton("editFocus");
		} else {
			this.focusOnInitialButton("addCourseFocus");
		}
	}

	// handling submit model up if user clicks on cancel button
	handleCancelAppConfirmation() {
		this.openSubmitConfirmationModal = false;
		//added for S-58678
		setTimeout(() => {
			this.focusOnInitialButton("submitBtnFocus");
		}, 500);
	}

	handleAuditDataChange(event) {
		if (event.target.name === "gracePeriod") {
			this.auditData.gracePeriod = event.target.checked;
		}
	}

	// Toast Message
	showMessage(title, message, variant) {
		const toastEvt = new ShowToastEvent({
			title,
			message,
			variant
		});
		this.dispatchEvent(toastEvt);
	}

	// Navigating to business license view page
	navigateToBusinessLicense() {
		// Added true Prevent the user from going back to the audit form
		this[NavigationMixin.Navigate](
			{
				type: "comm__namedPage",
				attributes: {
					name: "Renew_License_Details__c"
				},
				state: {
					blId: this.blId
				}
			},
			true
		);
	}
	//S-57276 Added by Vamshi - Start
	focusFirstEle() {
		const focusableElements =
			"lightning-button-icon, lightning-helptext,lightning-button, button, lightning-input, lightning-textarea, lightning-combobox";
		const modal = this.template.querySelector(".slds-modal");
		const firstFocusableElement = modal.querySelectorAll(focusableElements)[0];
		const focusableContent = modal.querySelectorAll(focusableElements);
		const lastFocusableElement = focusableContent[focusableContent.length - 1];
		firstFocusableElement.focus();
		this.template.addEventListener("keydown", function (event) {
			let isTabPressed = event.key === "Tab" || event.keyCode === 9;
			if (!isTabPressed) {
				return;
			}
			if (event.shiftKey) {
				if (this.activeElement === firstFocusableElement) {
					lastFocusableElement.focus();
					event.stopPropagation();
					event.preventDefault();
				}
			} else {
				if (this.activeElement === lastFocusableElement) {
					firstFocusableElement.focus();
					event.preventDefault();
					event.stopPropagation();
				}
			}
		});
	}
	focusOnInitialButton(className) {
		var focusOnInitial = this.template.querySelector(`.${className}`);
		if (focusOnInitial) {
			focusOnInitial.focus();
		}
	}
	//S-57276 Added by Vamshi - End
	//Added by kirti for accessibility issue
	handleEscCloseModal(event) {
		const ESC = 27;
		if (event.key === "Escape" || event.key === "Esc" || event.keyCode == ESC) {
			this.closeModelAuthContact();
			//added for S-58678
			this.handleCancelAppConfirmation();
		}
	}

	addSubjectArea() {
		this.courseDetailData.subjectAreaList[this.courseDetailData.subjectAreaList.length - 1].showAddButton = false;
		this.courseDetailData.subjectAreaList.push({
			index: this.courseDetailData.subjectAreaList.length,
			showAddButton: true
		});
	}

	deleteSubjectArea(event) {
		let deletedHours = parseFloat(
			this.courseDetailData.subjectAreaList[event.currentTarget.dataset.index].reportedHours
		);
		this.courseDetailData.hours -= isNaN(deletedHours) ? 0 : deletedHours;
		this.courseDetailData.subjectAreaList.splice(event.currentTarget.dataset.index, 1);
		this.courseDetailData.subjectAreaList[this.courseDetailData.subjectAreaList.length - 1].showAddButton = true;
	}

	get showDeleteButton() {
		return this.courseDetailData.subjectAreaList.length > 1;
	}

	handleSubjectInfoInput(event) {
		if (event.target.name === "subjectArea") {
			this.courseDetailData.subjectAreaList[event.currentTarget.dataset.index].subjectArea = event.target.value;
		} else if (event.target.name === "reportedHours") {
			let prevReportedHours =
				this.courseDetailData.subjectAreaList[event.currentTarget.dataset.index].reportedHours;
			if (prevReportedHours != null && prevReportedHours !== undefined) {
				prevReportedHours = parseFloat(prevReportedHours);
				this.courseDetailData.hours -= isNaN(prevReportedHours) ? 0 : prevReportedHours;
			}
			this.courseDetailData.hours += isNaN(parseFloat(event.target.value)) ? 0 : parseFloat(event.target.value);
			this.courseDetailData.subjectAreaList[event.currentTarget.dataset.index].reportedHours = parseFloat(
				event.target.value
			);
		}
	}
	getAppDocId(event){
		this.currentAppDocId = event.detail.appdocid;
		this.appDocIdList.push(this.currentAppDocId);
	}

	handleFilesStatus(fromDelete){
        let dataObj = {
            appDocIdList : this.appDocIdList.join(','),
            isAudit : true,
			deleteAll : fromDelete,
			tcpId : this.courseIdForDelete
    }
        handleUpdateFileStatus({
            jsonData : JSON.stringify(dataObj)
        }).catch(error => {
            showAsyncErrorMessage(this,error);
        }).finally(()=> {
			this.appDocIdList = [];
            this.showSpinner = false;
        })
    }
	removeIdFromList(event){
		this.currentAppDocId = event.detail.appdocid;
        const index = this.appDocIdList.indexOf(this.currentAppDocId);
        if (index > -1) {
            this.appDocIdList.splice(index, 1);
        }
        // array = [2, 9]
	}
	//Added for I-257468
	handleEscKeyDown(event) {
        if (event.code === 'Escape' || event.keyCode === 27) {
            this.handleCancelConfirmation();
        }
    }
}