import { LightningElement, track, wire, api } from 'lwc';
//Import apex methods, static resources and custom labels
import fetchevents from '@salesforce/apex/FamilyEventController.fetchEvents';
import familyEventdetails from '@salesforce/apex/FamilyEventController.familyEventdetails';
import noevent from '@salesforce/label/c.CQ_No_Events';
import eventHeading from '@salesforce/label/c.CQ_Event_Heading';
import longDescription from '@salesforce/schema/Special_Needs__c.Long_Description__c';
import shirtSize from '@salesforce/schema/Contact.Shirt_Size__c';
import eventDetails from '@salesforce/label/c.CQ_Event_details';
import headerImg from '@salesforce/resourceUrl/CQ_SkyBlueHeader';
import updateStatus from '@salesforce/apex/FamilyEventController.updateEventDetails';
import swimAbility from '@salesforce/schema/Contact.Swimming_Ability__c';
import getConfirmBtnData from '@salesforce/apex/FamilyEventController.getConfirmBtnData';
import getConDatafortable from '@salesforce/apex/FamilyEventController.getConDatafortable';
import getAccountDatatab from '@salesforce/apex/FamilyEventController.getAccountDatatable';
import updateAccountData from '@salesforce/apex/FamilyEventController.updateAccountData';
import updatetableData from '@salesforce/apex/FamilyEventController.updatetableData';
import preferredSessionPicklist from '@salesforce/apex/FamilyEventController.preferredSessionPicklist';
import transportLocationPic from '@salesforce/apex/FamilyEventController.transportLocationPic';
import transportLocationHome from '@salesforce/apex/FamilyEventController.transportLocationHome';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import home_Locations from '@salesforce/schema/Campaign.Available_Getting_Home_Locations__c';
import camp_Locations from '@salesforce/schema/Campaign.Available_Getting_to_Camp_Locations__c';
import { RefreshEvent } from 'lightning/refresh';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningAlert from 'lightning/alert';
import getContentVersion from '@salesforce/apex/FamilyEventController.contentVersion';
import contentVersionforEvent from '@salesforce/apex/FamilyEventController.contentVersionforEvent';
import getAttendencePicklistValues from '@salesforce/apex/FamilyEventController.getFamAttPicklistValues';

export default class FamilyEventPage extends LightningElement {

    //Declare the variables, array 
    headerSkyBlueImg = headerImg;
    waitForRes = false;
    title;
    backBtn = false;
    label = {
        noevent,
        eventHeading,
        eventDetails
    }
    events = [];
    isComplete = false;
    hasEvent = false;
    familyAttId;
    showUpdatePanel = false;
    eventDetails = false;
    showConfirmAlert = false;
    commentNullError = false;
    @track eventDetail;
    @track conData = [];
    tableAccountFieldData = {
        emergency_Contact: '',
        emergency_Contact_Phone: '',
        emergency_Contact_Mobile: '',
        emergency_Contact_Relationship: '',
        family_Member_On_Treatment: true,
        mediaTakePhoto: true,
        mediaparticipant: true,
        mediaSharingPhoto: true,
        consent: true,
        regisPeriodName: '',
        behavioralExpectations: true,
    };
    error;
    swimOptions = [];
    swimAbility = '';
    shirtOptions = [];
    homeOptions = [];
    home_Locations = '';
    campOptions = [];
    camp_Locations = '';
    // optionsPickList = [];
    optionsDroppList = [];
    shirtSize = '';
    specNeedsPick;
    Attendence = '';
    AttendenceValue = [];

    @track btnConfirmdata = {
        shirtSize: '',
        swimmingAbility: '',
        specialCelebration: '',
        transportPickUpRequired: '',
        transportDropOffRequired: '',
        eventtransportAccOrNot: '',
        homeTransportAcceptOrNot: '',
        medicalComments: '',
        medicationAndVitaminsOptionsvalue: '',
        OTCStandard: '',
        childImmunisationScheduleCurrent: '',
        currentlyonTreatment: '',
        MedicationandVitamins: '',
        hasCentralLine: '',
        hasPortacath: '',
        dietList: [],
        speNeedList: [],
        speNeedDelete: [],
        id: '',
        hideLocationField: '',
        memId: '',
        requiresMedicationOrVitamins: ''
        //Attendence:''
    }
    @track isModalOpen = false;
    @track yesNoOption = [{
        label: 'Yes', value: 'Yes',
    },
    {
        label: 'No', value: 'No'
    }];

    @track yesNoOptionMedical = [
        { label: '--Please Select--', value: '' },
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' }
    ];

    @track medicationAndVitaminsOptions = [
        {
            label: 'Option #1 (our preferred option):\nMedication will be prepared in a Webster Pack organised through your pharmacist (dosette boxes can be used if dispensed by the hospital pharmacy and sealed with clear instructions from the pharmacy),\nor medication that is provided as part of a signed management plan which the child will have a copy of with their medication on camp.',
            value: 'Webster Pack'
        },
        {
            label: 'Option #2:\nMedication will be handed in its original packaging with the dosage and child’s name. Please include an ice brick if required.\nFor Option #2 you will need to get your doctor to complete the Doctors Consent and Medication Chart for medications, vitamins, & asthma puffers/epi pens without a signed management plan. This form will be emailed to you if your child is accepted for camp.',
            value: 'Original Packaging'
        }
    ];

    // Index tracking for diet list
    keyIndexdiet = 0;
    @track dietForCon = [
        // {
        //     id: 0,
        //     dietDescription: '',
        //     dietComment: ''
        // }
    ]
    // Index tracking for special needs list
    keyIndex = 0;
    @track specialFOrCon = [
        // {
        //     id: 0,
        //     specNeedDescription: '',
        //     specNeedComment: ''
        // }
    ]

    hideDietFields = false;
    hideSpecialNeedFields = false;
    isAgeCamp = false;


    //Get the shirtSize picklist values from the database by the record type
    @wire(getPicklistValues, {
        recordTypeId: "012280000007dCj",
        fieldApiName: shirtSize
    })
    wiredTypePicklistValuesShirt({ error, data }) {
        if (data) {
            // Map the data values to an array of options
            this.shirtOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }

        // If there is an error
        else if (error) {
        }
    }

    //Get the swimAbility picklist values from the database by the record type
    @wire(getPicklistValues, {
        recordTypeId: "012280000007dCj",
        fieldApiName: swimAbility
    })
    wiredTypePicklistValuesSwim({ error, data }) {
        if (data) {
            // Map the data values to an array of options
            this.swimOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }

        // If there is an error
        else if (error) {
        }
    }

    handlemedicationAndVitaminsOptions(event) {
        // this.medicationAndVitaminsOptionsvalue = event.target.value;
    }

    @wire(getAttendencePicklistValues, {})
    // Define a wired property for rating picklist values
    wiredRatingPicklistValues({ error, data }) {
        // If data is returned from the wire function
        if (data) {
            // Map the data to an array of options
            this.AttendenceValue = data.map(option => {
                console.log('this.AttendenceValue' + this.AttendenceValue);
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }
        // If there is an error
        else if (error) {
            // Log the error to the console
            console.error(error);
        }
    }

    // Function to handle changes in the swim ability and shirt size selection
    handleSwimAbilityChange(event) {
        this.btnConfirmdata.swimmingAbility = event.target.value;
    }
    handleShirtSizeChange(event) {
        this.btnConfirmdata.shirtSize = event.target.value;
    }

    // handleAttendenceChange(event) {
    //     this.btnConfirmdata.Attendence = event.target.value;
    // }



    storeSessionUserId;
    parameters = {};
    setSesForEveDetail;
    allowUpdates = false;
    connectedCallback() {
        this.loadMrOrangeStyles();
        if (sessionStorage.getItem('OTP') != undefined) {
            this.storeSessionUserId = sessionStorage.getItem('OTP');
            console.log('line 246--'+ this.storeSessionUserId );
            this.getFamilyEventsData();

            this.parameters = this.getQueryParameters();
            console.log('--this.parameters line 248---' + JSON.stringify(this.parameters));
            if (this.parameters.Id != undefined) {
                this.campaignId = this.parameters.Id;
                console.log('Inside 250 line---'+ this.campaignId);
                this.callEventWithId();
                this.setSesForEveDetail = sessionStorage.setItem('urlParameter', this.parameters.Id);
            }
        }
    }

    loadMrOrangeStyles() {
        let urlName;
        if (location.origin.includes('partial')) {
            urlName = '/campqualityCss/partialFont.css';
        }
        else {
            urlName = '/campqualityCss/productionFont.css';
        }

        loadStyle(this, partialFont + urlName)
            .then(() => {
                // Stylesheet loaded successfully
            })
            .catch(error => {
                // Handle error if stylesheet fails to load
                console.error('Error loading MrOrange stylesheet: ', error);
            });
    }

    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }
        return params;
    }

    @track versionData;

    async loadContentVersion2(contentVersionId) {
        try {
            const result = await contentVersionforEvent({ contentVerId: contentVersionId });
            return result;
        } catch (error) {
            // Handle errors here
            console.error('Error in loadContentVersion2:', error);
        }
    }

    @track versionData;

    async loadContentVersion(contentVersionId) {
        try {
            const result = await getContentVersion({ contentVerId: contentVersionId });
            return result;
        } catch (error) {
            return undefined;
        }
    }

    eventImage = '';

    async getFamilyEventsData() {

        // Calling the Apex method 'fetchevents' to retrieve event data
        const result = await fetchevents({ recUserId: this.storeSessionUserId });
        // Updating the component's 'events' property with the retrieved data

        for (const ele of result) {
            this.waitForRes = true;
            let objData = {
                Event_Type__c: ele.camp.Event_Type__c || '',
                StartDate: '',
                Event_time__c: ele.camp.Event_time__c || '',
                EndDate: '',
                RVSP__c: ele.camp.RVSP__c || '',
                Portal_Title__c: ele.camp.Portal_Title__c || '',
                Id: ele.camp.Id || '',
                Image_for_Portals__r: '',
                bolbData: [],
            };

            // Create an array to store promises
            const promises = [];

            if (ele.bolbData !== undefined && ele.bolbData !== '') {
                for (const item of ele.bolbData) {
                    // Wait for each promise to resolve before moving to the next iteration
                    const result = await this.loadContentVersion(item);
                    if (result !== undefined) {
                        objData.bolbData.push('data:image/png;base64,' + result);
                    }
                }
            }


            if (ele.camp.StartDate !== undefined) {

                let dateComponents = ele.camp.StartDate.split('-');
                let year = dateComponents[0];
                let monthIndex = parseInt(dateComponents[1]) - 1;
                let day = parseInt(dateComponents[2]);

                // Create a Date object to get the day of the week
                let inputDate = new Date(year, monthIndex, day);

                // Define an array for day names
                const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

                // Get the day of the week
                let dayOfWeek = dayNames[inputDate.getDay()];


                // Define an array for month names
                const monthNames = [
                    'January', 'February', 'March', 'April', 'May', 'June', 'July',
                    'August', 'September', 'October', 'November', 'December'
                ];

                // Get the month name
                let month = monthNames[monthIndex];

                // Convert day to ordinal form (1st, 2nd, 3rd, etc.)
                let dayOrdinal = '';
                if (day === 1 || day === 21 || day === 31) {
                    dayOrdinal = 'st';
                } else if (day === 2 || day === 22) {
                    dayOrdinal = 'nd';
                } else if (day === 3 || day === 23) {
                    dayOrdinal = 'rd';
                } else {
                    dayOrdinal = 'th';
                }
                // Construct the formatted date string
                let formattedDate = `${dayOfWeek} ${day}${dayOrdinal} ${month} ${year}`;
                objData.StartDate = formattedDate;
            }

            if (ele.camp.EndDate !== undefined) {


                let dateComponents = ele.camp.EndDate.split('-');
                let year = dateComponents[0];
                let monthIndex = parseInt(dateComponents[1]) - 1;
                let day = parseInt(dateComponents[2]);

                // Create a Date object to get the day of the week
                let inputDate = new Date(year, monthIndex, day);

                // Define an array for day names
                const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

                // Get the day of the week
                let dayOfWeek = dayNames[inputDate.getDay()];


                // Define an array for month names
                const monthNames = [
                    'January', 'February', 'March', 'April', 'May', 'June', 'July',
                    'August', 'September', 'October', 'November', 'December'
                ];

                // Get the month name
                let month = monthNames[monthIndex];

                // Convert day to ordinal form (1st, 2nd, 3rd, etc.)
                let dayOrdinal = '';
                if (day === 1 || day === 21 || day === 31) {
                    dayOrdinal = 'st';
                } else if (day === 2 || day === 22) {
                    dayOrdinal = 'nd';
                } else if (day === 3 || day === 23) {
                    dayOrdinal = 'rd';
                } else {
                    dayOrdinal = 'th';
                }
                // Construct the formatted date string
                let formattedDate = `${dayOfWeek} ${day}${dayOrdinal} ${month} ${year}`;
                objData.EndDate = formattedDate;
            }

            this.events.push(objData);
        }
        this.waitForRes = false;
        if (result.length > 0) {
            this.hasEvent = true;
        }
    }


    // Function to handle changes in the diet combo box values
    handleChangediet(event) {
        // Extracting the record ID and selected value from the event
        const recordId = event.target.dataset.recordid;
        const selectedValue = event.target.value;
        if (event.target.name === 'dietName') {
            // Find the item in dietForCon with the matching recordId
            let itemToUpdate = this.btnConfirmdata.dietList.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietDescription property of the item
                itemToUpdate.dietDescription = selectedValue;

                // You may want to update dietForCon to trigger reactivity in the template
                this.btnConfirmdata.dietList = [...this.btnConfirmdata.dietList];
            }
        }
        if (event.target.name === 'dietComment') {
            // Find the item in dietForCon with the matching recordId
            let itemToUpdate = this.btnConfirmdata.dietList.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the dietComment property of the item
                itemToUpdate.dietComment = selectedValue;
                // You may want to update dietForCon to trigger reactivity in the template
                this.btnConfirmdata.dietList = [...this.btnConfirmdata.dietList];
            }
        }
    }

    // Function to handle changes in the special need combo box values
    handleChange(event) {
        // Extracting the record ID and selected value from the event
        let recordId = event.target.dataset.recordid;
        let selectedValue = event.target.value;
        if (event.target.name === 'speNeedDes') {
            // Find the item in dietForCon with the matching recordId
            let itemToUpdate = this.btnConfirmdata.speNeedList.find(item => item.id == recordId);
            if (itemToUpdate) {
                // Update the dietDescription property of the item
                itemToUpdate.specNeedDescription = selectedValue;
                // Triggering reactivity in the template by updating 'speNeedList'
                this.btnConfirmdata.speNeedList = [...this.btnConfirmdata.speNeedList];
            }
        }
        if (event.target.name === 'speNeedCom') {
            // Finding the item in 'btnConfirmdata.speNeedList' with the matching recordId
            let itemToUpdate = this.btnConfirmdata.speNeedList.find(item => item.id == recordId);

            if (itemToUpdate) {
                // Update the specNeedComment property of the item
                itemToUpdate.specNeedComment = selectedValue;
                // Triggering reactivity in the template by updating 'speNeedList'
                this.btnConfirmdata.speNeedList = [...this.btnConfirmdata.speNeedList];
            }
        }
    }


    campaignId;
    campIdUrl;
    // Function to handle clicking on an event details button
    eventDetailsHandle(event) {
        // Calling the 'familyEventdetails' Apex method with the Campaign Id
        this.campaignId = event.target.dataset.id;
        let getUrl = window.location.href;
        this.campIdUrl = '/family/?page=event&Id=' + this.campaignId;
        window.open('/family/?page=event&Id=' + this.campaignId, '_self');
    }

    @track bolbData = [];
    async callEventWithId() {
        try {
            console.log('line 533 camp id---'+ this.campaignId); 
            console.log('line 536--'+ this.storeSessionUserId );
            const result = await familyEventdetails({ campId: this.campaignId, recUserId: this.storeSessionUserId });
            this.waitForRes = false;
            this.eventDetail = result;
            console.log('Line 537--'+ JSON.stringify(result));
            if (result.startDate != undefined) {
                this.eventDetail.startDate = this.dayFormatfunction(result.startDate);
            }

            if (result.endDate != undefined) {
                this.eventDetail.endDate = this.dayFormatfunction(result.endDate);
            }

            if (result.recordTypeName == 'Age_Camp') {
                this.isAgeCamp = true;
                console.log('result line 504----' + result);
                this.OTCStandardError = false;
                this.currentlyonTreatmentError = false;
                this.requiresMedicationOrVitaminsError = false;
                this.hasCentralLineError = false;
                this.hasPortacathError = false;
                this.childImmunisationScheduleCurrentError = false;
            }

            if (result.blobEventImages !== undefined && result.blobEventImages.length > 0) {
                for (const item of result.blobEventImages) {
                    if (item.bolbData && typeof item.bolbData[Symbol.iterator] === 'function') {
                        for (const ele of item.bolbData) {
                            const imageData = await this.loadContentVersion2(ele); // Await the result here
                            if (imageData !== undefined) {
                                this.bolbData.push('data:image/png;base64,' + imageData);
                            }
                        }
                    }
                }
            }

            this.eventDetails = true;
            this.hasEvent = false;
            this.backBtn = true;
        } catch (error) {
            // Handle errors here
            console.error('Error message:', error.message);
            console.error('Stack trace:', error.stack);

            this.waitForRes = false;

        }
    }

    dayFormatfunction(datetoFormat) {
        let dateComponents = datetoFormat.split('-');
        let year = dateComponents[2];
        let monthIndex = parseInt(dateComponents[1]) - 1;
        let day = parseInt(dateComponents[0]);

        // Create a Date object to get the day of the week
        let inputDate = new Date(year, monthIndex, day);

        // Define an array for day names
        const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

        // Get the day of the week
        let dayOfWeek = dayNames[inputDate.getDay()];


        // Define an array for month names
        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June', 'July',
            'August', 'September', 'October', 'November', 'December'
        ];

        // Get the month name
        let month = monthNames[monthIndex];

        // Convert day to ordinal form (1st, 2nd, 3rd, etc.)
        let dayOrdinal = '';
        if (day === 1 || day === 21 || day === 31) {
            dayOrdinal = 'st';
        } else if (day === 2 || day === 22) {
            dayOrdinal = 'nd';
        } else if (day === 3 || day === 23) {
            dayOrdinal = 'rd';
        } else {
            dayOrdinal = 'th';
        }

        return `${dayOfWeek} ${day}${dayOrdinal} ${month} ${year}`;
    }
    // Function to handle going back from event details.
    backHandle() {
        // Updating flags to control the visibility of different components
        this.eventDetails = false;
        this.hasEvent = true;
        this.showUpdatePanel = false;
        this.backBtn = false;
    }
    callHandle;

    // Function to update the status to 'Declined' for a family attendance
    updateStatusDeclined(event) {


        // const tilt = event.target.dataset.value;

        this.customModalOpen = true;
        //this.callHandle = 'Declined';
        console.log('this.dataget ' + this.callHandle);
        this.title = "Declined Event Invitation";
        console.log('this.title: ' + this.title);
        this.customQue = false;
        this.showPickList = true;
        this.customModalValidation = false;
        this.familyAttId = event.target.dataset.id;
    }
    handleDeclined() {
        // Setting a flag to indicate that the component is waiting for a response
        this.showUpdatePanel = false;
        this.customModalOpen = false;
        this.waitForRes = true;
        // Calling the 'updateStatus' Apex method with Family Attendance Id, status, and cancel reason
        updateStatus({ famiAttId: this.familyAttId, status: 'Declined', cancelReason: '', cancelResasonPicklist: this.cancelReasPicValue })
            .then(result => {
                // Handling the result by triggering an alert and resetting the 'waitForRes' flag
                this.handleAlertClick('Declined');
                this.waitForRes = false;
                this.callEventWithId();
            })
            .catch(error => {
                // Resetting the 'waitForRes' flag in case of an error
                console.log('Error2=>' + JSON.stringify(error));
                this.waitForRes = false;
            })
    }
    @track getfamAttId;
    @track pickListValueSession = [{ label: 'Select an Option', value: '', selected: false }];
    hideSessionDropdown = false;
    selectSession = false;
    // Function to handle updating registration details
    updateRegHandle(event) {
        this.getAllowUpdate();
        console.log('allowed updates at 642', this.allowUpdates);
        this.conData = [];
        this.getfamAttId = event.target.dataset.id;
        window.scrollTo(0, document.body.scrollHeight - 50);
        // Setting a flag to indicate that the component is waiting for a response
        this.showUpdatePanel = true;
        // Calling the 'getConDatafortable' Apex method to retrieve registration details
        getConDatafortable({ familyAttId: this.getfamAttId })
            // Processing each item in the result to create formatted data
            .then(result => {
                result.forEach(item => {
                    let data = {
                        Family_Member_Type__c: item.Contact__r.Family_Member_Type__c,
                        Swimming_Ability__c: item.Contact__r.Swimming_Ability__c,
                        AccountId: item.Contact__r.AccountId,
                        Id: item.Contact__r.Id,
                        memId: item.Id,
                        Shirt_Size__c: item.Contact__r.Shirt_Size__c,
                        Name: item.Contact__r.Name,
                        confirmdetails: this.allowUpdates ? true : (item.Attendance__c == 'Request to Attend' || item.Attendance__c == 'Declined' ? false : true),
                        // confirmdetails : true,
                        //    confirmdetails: item.Attendance__c == 'Request to Attend' || item.Attendance__c == 'Declined' ? false : true,
                        attend: item.Attendance__c == 'Request to Attend' ? true : false
                    };
                    if (data.confirmdetails != false && this.tableAccountFieldData.behavioralExpectations == false && this.tableAccountFieldData.consent == false) {
                        this.isComplete = true;
                    }
                    console.log('data at 730 ', data.confirmdetails);
                    // Adding the formatted data to the 'conData' array
                    this.conData.push(data);
                })
            })
            .catch(error => {
                console.log('Error3=>' + JSON.stringify(error));
            })
        getAccountDatatab({ recUserId: this.storeSessionUserId, campId: this.campaignId, famAttId: this.getfamAttId })
            // Calling the 'getAccountDatatab' Apex method to retrieve account field data
            .then(result => {
                // Updating the component's 'tableAccountFieldData' property with the retrieved result
                this.tableAccountFieldData = result;
                //Assigning the values to wrapper class variables with retrived result and use that variable in HTML
                this.tableAccountFieldData.emergency_Contact = result.emergency_Contact;
                if (this.tableAccountFieldData.emergency_Contact == undefined || this.tableAccountFieldData.emergency_Contact == '') {
                    this.tableAccountFieldData.emergency_Contact = '';
                }
                this.tableAccountFieldData.emergency_Contact_Phone = result.emergency_Contact_Phone;
                if (this.tableAccountFieldData.emergency_Contact_Phone == undefined || this.tableAccountFieldData.emergency_Contact_Phone == '') {
                    this.tableAccountFieldData.emergency_Contact_Phone = '';
                }
                this.tableAccountFieldData.emergency_Contact_Mobile = result.emergency_Contact_Mobile;
                if (this.tableAccountFieldData.emergency_Contact_Mobile == undefined || this.tableAccountFieldData.emergency_Contact_Mobile == '') {
                    this.tableAccountFieldData.emergency_Contact_Mobile = '';
                }
                this.tableAccountFieldData.emergency_Contact_Relationship = result.emergency_Contact_Relationship;
                if (this.tableAccountFieldData.emergency_Contact_Relationship == undefined || this.tableAccountFieldData.emergency_Contact_Relationship == '') {
                    this.tableAccountFieldData.emergency_Contact_Relationship = '';
                }
                this.selectedSessionPickList = result.regisPeriodName;
                if (result.regisPeriodName == undefined || result.regisPeriodName == '') {
                    this.selectSession = true;
                }
                this.tableAccountFieldData.family_Member_On_Treatment = result.family_Member_On_Treatment;

                this.tableAccountFieldData.mediaTakePhoto = result.mediaTakePhoto;
                this.openSharing = result.mediaTakePhoto;
                this.tableAccountFieldData.mediaparticipant = result.mediaparticipant;
                this.tableAccountFieldData.mediaSharingPhoto = result.mediaSharingPhoto;
                this.tableAccountFieldData.consent = result.consent;
                this.tableAccountFieldData.behavioralExpectations = result.behavioralExpectations;

                preferredSessionPicklist({ camId: this.campaignId })
                    .then(result => {
                        if (result != undefined && result != '') {
                            this.pickListValueSession = [{ label: 'Select an Option', value: '', selected: false }];
                            result.forEach(item => {
                                const obj = {
                                    label: item.label,
                                    value: item.value,
                                    selected: false
                                }
                                if (item.value == this.selectedSessionPickList) {
                                    obj.selected = true;
                                }
                                this.pickListValueSession.push(obj);
                                this.hideSessionDropdown = false;

                            })
                        }
                        else {
                            this.hideSessionDropdown = true;
                        }

                    })
                    .catch(error => {
                        //(error);
                        console.log(' JSON ERROR-------' + JSON.stringify(error));
                    })
            })
            .catch(error => {
                console.log('Error4=>' + JSON.stringify(error));
            })

    }

    preferresSessVali = false;
    @track selectedSessionPickList = '';
    handleSessionChange(event) {
        this.selectedSessionPickList = event.target.value;
    }
    // Function to handle completing the registration process
    completeHandle(event) {
        // Initializing a counter to track the number of confirmed details
        let count = 0;
        this.tableAccountFieldData.regisPeriodName = this.selectedSessionPickList;
        if ((this.tableAccountFieldData.regisPeriodName === undefined || this.tableAccountFieldData.regisPeriodName === '' || this.tableAccountFieldData.regisPeriodName === 'Select an Option') && this.pickListValueSession.length > 1) {
            this.preferresSessVali = true;
        }
        else if (this.selectedSessionPickList != '' || this.selectedSessionPickList != undefined) {
            this.preferresSessVali = false;
        }
        let famIds = [];
        // Looping through each item in 'conData' to count the confirmed details
        this.conData.forEach(item => {
            // if (item.confirmdetails == false) {
            //     count += 1;
            // }
            if (item.attend == true) {
                count += 1;
                famIds.push(item.memId);
            }
        })
        // Checking if at least one confirmed detail is present
        if (count == 0) {
            this.showConfirmAlert = true;
        }

        else if (this.tableAccountFieldData.consent == true && this.tableAccountFieldData.behavioralExpectations == true && this.preferresSessVali == false) {
            this.showConfirmAlert = false;
            this.waitForRes = true;
            // Calling the 'updateAccountData' Apex method to update account data
            updateAccountData({ accData: this.tableAccountFieldData, recUserId: this.storeSessionUserId, campId: this.campaignId, femAttId: this.getfamAttId, famMemList: famIds })
                .then(result => {
                    // Resetting the 'waitForRes' flag and triggering a success alert
                    this.waitForRes = false;
                    this.handleAlertSuccessClick('Registration Completed');
                    this.tableAccountFieldData.consent = false;
                    this.tableAccountFieldData.behavioralExpectations = false;
                    this.eventDetails = false;
                    this.hasEvent = true;
                    this.showUpdatePanel = false;
                    this.backBtn = false;
                })
                .catch(error => {
                    // Resetting the 'waitForRes' flag and logging any errors that occur
                    this.waitForRes = false;
                    this.tableAccountFieldData.consent = false;
                    this.tableAccountFieldData.behavioralExpectations = false;
                })

            updateStatus({ famiAttId: this.getfamAttId, status: 'Request to Attend', cancelReason: '', cancelResasonPicklist: '' })
                .then(result => {
                    this.waitForRes = false;
                })
                .catch(error => {
                    this.waitForRes = false;
                })


        }
    }



    // Wire service to fetch picklist values for the 'longDescription' field for dietary requirement with the default record type Id
    @wire(getPicklistValues, {
        recordTypeId: '01228000000iUetAAE', // Default record type Id
        fieldApiName: longDescription
    })
    getPicklistValuesDiet({ error, data }) {
        if (data) {
            // Transforming the picklist values into a format suitable for the component
            let valueList = [];
            //Iterate the result of wire to make in format of label and value
            data.values.forEach(item => {
                valueList.push({ label: item.label, value: item.value });
            });
            // Updating the component's 'specNeedsPick' property with the transformed picklist values
            this.diet = valueList;
        } else if (error) {
            // Handle error
        }
    }

    // Wire service to fetch picklist values for the 'longDescription' field for special need requirements with another record type Id
    @wire(getPicklistValues, {
        recordTypeId: '01228000000iUeuAAE', // Default record type Id
        fieldApiName: longDescription
    })
    getPicklistValuesSpecialNeed({ error, data }) {
        if (data) {
            // Transforming the picklist values into a format suitable for the component
            let specialNeed = [];
            data.values.forEach(item => {
                specialNeed.push({ label: item.label, value: item.value });
            });
            // Updating the component's 'diet' property with the transformed picklist values
            this.specNeedsPick = specialNeed;
        } else if (error) {
            // Handle error
        }


    }

    @track checkAttendingBox = false;
    checkBoxValidation = false;
    dontSave = false;
    //Handle the submit button funtionality 
    submitDetails(event) {

        // Using if-else statements for validation conditions
        if(this.isAgeCamp){

        
        if (this.btnConfirmdata.OTCStandard === 'Yes' || this.btnConfirmdata.OTCStandard === 'No') {
            this.OTCStandardError = false;
        } else {
            this.OTCStandardError = true;
        }

        if (this.btnConfirmdata.currentlyonTreatment === 'Yes' || this.btnConfirmdata.currentlyonTreatment === 'No') {
            this.currentlyonTreatmentError = false;
        } else if(this.btnConfirmdata.currentlyonTreatment === '' || this.btnConfirmdata.currentlyonTreatment === undefined) {
            this.currentlyonTreatmentError = true;
        }


        if (this.btnConfirmdata.currentlyonTreatment == 'Yes') {
            if (this.btnConfirmdata.hasCentralLine === 'Yes' || this.btnConfirmdata.hasCentralLine === 'No' ) {
                this.hasCentralLineError = false;
            } else if(this.btnConfirmdata.hasCentralLine === '' || this.btnConfirmdata.hasCentralLine === undefined) {
                this.hasCentralLineError = true;
            }

            if (this.btnConfirmdata.hasPortacath === 'Yes' || this.btnConfirmdata.hasPortacath === 'No' ) {
                this.hasPortacathError = false;
            } else if(this.btnConfirmdata.hasPortacath === '' || this.btnConfirmdata.hasPortacath === undefined) {
                this.hasPortacathError = true;
            }
        }


        if (this.btnConfirmdata.childImmunisationScheduleCurrent === 'Yes' || this.btnConfirmdata.childImmunisationScheduleCurrent === 'No' ) {
            this.childImmunisationScheduleCurrentError = false;
        } else if(this.btnConfirmdata.childImmunisationScheduleCurrent === '' || this.btnConfirmdata.childImmunisationScheduleCurrent === undefined) {
            this.childImmunisationScheduleCurrentError = true;
        }

        if (this.btnConfirmdata.requiresMedicationOrVitamins === 'Yes' || this.btnConfirmdata.requiresMedicationOrVitamins === 'No') {
            this.requiresMedicationOrVitaminsError = false;
        } else if(this.btnConfirmdata.requiresMedicationOrVitamins === '' || this.btnConfirmdata.requiresMedicationOrVitamins === undefined) {
            this.requiresMedicationOrVitaminsError = true;
        }
        }


        // Logging errors

        console.log('--this.OTCStandardError---' + this.OTCStandardError);
        console.log('--this.currentlyonTreatmentError---' + this.currentlyonTreatmentError);
        console.log('--this.hasCentralLineError---' + this.hasCentralLineError);
        console.log('--this.hasPortacathError---' + this.hasPortacathError);
        console.log('--this.requiresMedicationOrVitaminsError---' + this.requiresMedicationOrVitaminsError);
        // console.log('-- this.requiredmedicalCommentsError---' + this.requiredmedicalCommentsError);



        // Extracting the record ID from the button's dataset
        let recId = event.target.dataset.id;
        // Initializing a counter to track the number of comments that are empty
        let count = 0;
        // Checking if 'dietList' and 'speNeedList' are defined and not null
        if ((this.btnConfirmdata.dietList != undefined || this.btnConfirmdata.dietList != null) && (this.btnConfirmdata.speNeedList != undefined || this.btnConfirmdata.speNeedList != null)) {
            // Looping through 'dietList' to check for empty comments
            this.btnConfirmdata.dietList.forEach(item => {
                if (item.dietComment == '' || item.dietComment == null) {
                    count += 1;
                }
            })
            // Looping through 'speNeedList' to check for empty comments
            this.btnConfirmdata.speNeedList.forEach(item => {
                if (item.specNeedComment == '' || item.specNeedComment == null) {
                    count += 1;
                }
            })

            // Checking if there are any empty comments if they empty show error else don't show error
            if (count > 0) {
                this.commentNullError = true;
            }
            else {
                this.commentNullError = false;
            }
        }


        // Check if no checkbox is selected
       
        if (this.btnConfirmdata.requiresMedicationOrVitamins == 'Yes' && this.isAgeCamp == true) {

            console.log('--this.btnConfirmdata.medicationAndVitaminsOptionsvalue---line 971--' + this.btnConfirmdata.medicationAndVitaminsOptionsvalue);
            if (this.btnConfirmdata.medicationAndVitaminsOptionsvalue === undefined || this.btnConfirmdata.medicationAndVitaminsOptionsvalue == '') {
                this.checkBoxValidation = true;
                console.log('No checkbox is selected ');
                return; // Exit the function if no checkbox is selected
            }
            else {
                this.checkBoxValidation = false;
            }

            if (this.optionOneSelected == false && this.optionTwoSelected == false) {
                this.checkBoxValidation = true;
                this.dontSave = true;
                return;
            }
        }
        




        // checkBoxValidation

        if (!this.OTCStandardError && !this.currentlyonTreatmentError && !this.requiresMedicationOrVitaminsError && !this.hasCentralLineError && !this.hasPortacathError && !this.childImmunisationScheduleCurrentError) {
            console.log('Insiide Update Spnipper move--')

            this.waitForRes = true;
            // Calling the 'updatetableData' Apex method to update the table data
            updatetableData({ jsonData: JSON.stringify(this.btnConfirmdata), contId: recId })
                .then(result => {
                    if (this.tableAccountFieldData.behavioralExpectations == false && this.tableAccountFieldData.consent == false) {
                        this.isComplete = true;
                        console.log('--this.isComplete--' + this.isComplete);
                    }
                    // Updating the 'confirmdetails' property for the corresponding record in 'conData'
                    const foundItem = this.conData.find(item => item.memId == this.attMemId);
                    //this.getAllowUpdate();
                    if (foundItem) {
                        if (this.allowUpdates) {
                            foundItem.confirmdetails = true;
                        } else {
                            foundItem.confirmdetails = false;
                        }
                        foundItem.attend = true;
                        // this.dispatchEvent(new RefreshEvent());
                        familyEventdetails({ campId: this.campaignId, recUserId: this.storeSessionUserId })
                            .then(result => {
                                console.log('line 970--> ' + result);
                                this.eventDetail = result;
                                this.dispatchEvent(new RefreshEvent());
                            })
                            .catch(error => {
                                console.log('---FoundItemError===' + JSON.stringify(error));
                            })
                    }
                    // Resetting the 'waitForRes' flag and triggering a success alert
                    this.waitForRes = false;
                    this.isModalOpen = false;
                    this.editBtncheck = false;
                    this.keyIndex = 0;
                    this.keyIndexdiet = 0;
                    this.handleAlertConfirmClick('Your information has been updated successfully.');
                })
                .catch(error => {
                    this.waitForRes = false;
                    this.isModalOpen = false;
                    this.editBtncheck = false;
                    console.log('Error7=>' + JSON.stringify(error));
                })
        }
    }


    // Function to handle displaying a success alert
    async handleAlertSuccessClick(msg) {
        // Opening a success alert with the specified message
        await LightningAlert.open({
            message: msg,
            theme: 'success',
            variant: 'headerless', // this is the header text
        });
    }

    addButtonVisible = false;
    // Function to add a new row to the in special need requirements
    addRow() {
        this.addingRow = true;
        // Increment 'keyIndex' to generate a unique identifier for the new row
        ++this.keyIndex;
        // Create a new item with default values
        var newItem = { id: this.keyIndex, specNeedDescription: '', specNeedComment: '' };
        if (newItem) {
            this.addButtonVisible = false;
            this.hideSpecialNeedFields = false;
        }
        // Push the new item to the 'speNeedList'
        this.btnConfirmdata.speNeedList.push(newItem);
    }

    // Function to remove a row from special need requirements
    removeRow(event) {
        // Retrieve the unique identifier from the event's accessKey
        let id = event.target.accessKey;
        // Find the index of the item in 'speNeedList' with the matching id
        let itemIndex = this.btnConfirmdata.speNeedList.findIndex(item => item.id == id);
        // If the item is found in 'speNeedList', remove it
        if (itemIndex != -1) {
            this.btnConfirmdata.speNeedList.splice(itemIndex, 1);
        }
        if (itemIndex <= 0) {
            this.addButtonVisible = true;
        }
        // If the id length is greater than 10, add the id to 'speNeedDelete'
        if (id.length > 10) {
            this.btnConfirmdata.speNeedDelete.push({ id: id });
        }
    }

    addButtonVisibleSp = false;
    // Function to add a new row in dietary requirement
    addRowDiet() {
        // Increment 'keyIndex' to generate a unique identifier for the new row
        ++this.keyIndexdiet;
        // Create a new item with default values
        var newItemDiet = { id: this.keyIndexdiet, dietDescription: '', dietComment: '' };
        if (newItemDiet) {
            this.addButtonVisibleSp = false;
            this.hideDietFields = false;
        }
        // Push the new item to the 'speNeedList'
        this.btnConfirmdata.dietList.push(newItemDiet);
    }

    // Function to remove a row from the dietary requirement
    removeRowDiet(event) {
        // Retrieve the unique identifier from the event's accessKey
        let id = event.target.accessKey;
        // Find the index of the item in 'dietList' with the matching id
        let itemIndex = this.btnConfirmdata.dietList.findIndex(item => item.id == id);
        // If the item is found in 'speNeedList', remove it
        if (itemIndex != -1) {
            this.btnConfirmdata.dietList.splice(itemIndex, 1);
        }
        if (itemIndex <= 0) {
            this.addButtonVisibleSp = true;
        }
        // If the id length is greater than 10, add the id to 'speNeedDelete'
        if (id.length > 10) {
            this.btnConfirmdata.speNeedDelete.push({ id: id });
        }
    }
    // Function to display a success alert
    async handleAlertClick(msg) {
        await LightningAlert.open({
            message: 'Status updated ' + msg + ' sucessfully.',
            //message: 'Your information has been updated successfully.',
            theme: 'success', // a red theme intended for error states
            label: 'Update Status', // this is the header text
        });

    }

    // Function to display a success alert
    async handleAlertClick2() {
        await LightningAlert.open({
            message: 'Status updated to Cancelled  sucessfully.',
            // message: 'Your information has been updated successfully.',
            theme: 'success', // a red theme intended for error states
            label: 'Update Status', // this is the header text
        });
        let openEvent = this.template.querySelector('c-family-main-page');
        // Invoke the 'openEvent' method on the component to trigger a specific event
        openEvent.openEvent('event');
    }

    // Function to display a alert message on click confirm button 
    async handleAlertConfirmClick(msg) {
        await LightningAlert.open({
            // message: 'Status updated ' + msg + ' sucessfully.',
            message: msg,
            theme: 'success', // a red theme intended for error states
            label: 'Update Status', // this is the header text
        });
    }

    picktransportLocaPickUp = [];
    picktransportLocatHome = [];
    attMemId;

    // Function to handle confirming the details
    confirmHandle(event) {
        const recId = event.target.dataset.id;
        console.log('recId 1041---> ' + recId);
        const memId = event.target.dataset.memid;
        console.log('memId 1043---> ' + memId);
        this.attMemId = memId;
        getConfirmBtnData({ contId: recId, memId: memId })
            .then(result => {
                //  this.data
                console.log('Line 1048-->' + JSON.stringify(result));
                let confirmBtndata = result;
                console.log('Line 1050-->' + JSON.stringify(result));
                // Assigning retrieved data to 'btnConfirmdata' properties
                this.btnConfirmdata.shirtSize = result.shirtSize;
                this.btnConfirmdata.swimmingAbility = result.swimmingAbility;
                this.btnConfirmdata.memberId = memId;
                if (result.dietList == undefined) {
                    this.btnConfirmdata.dietList = this.dietForCon;
                    this.hideDietFields = true;
                    this.addButtonVisibleSp = true;
                }
                else {
                    this.btnConfirmdata.dietList = result.dietList;
                }
                if (result.speNeedList == undefined) {
                    this.btnConfirmdata.speNeedList = this.specialFOrCon;
                    this.hideSpecialNeedFields = true;
                    this.addButtonVisible = true;
                }
                else {
                    this.btnConfirmdata.speNeedList = result.speNeedList;
                }
                // this.btnConfirmdata.transportDropOffRequired = result.transportDropOffRequired;
                // this.btnConfirmdata.transportPickUpRequired = result.transportPickUpRequired;
                // this.eventtransportAccOrNot = result.eventtransportAccOrNot;
                // this.homeTransportAcceptOrNot = result.homeTransportAcceptOrNot;
                // this.btnConfirmdata.specialCelebration = result.specialCelebration;
                // this.btnConfirmdata.id = recId;
                // this.btnConfirmdata.hideLocationField = result.hideLocationField;

                this.btnConfirmdata.medicalComments = result.medicalComments;
                this.btnConfirmdata.medicationAndVitaminsOptionsvalue = result.medicationAndVitaminsOptionsvalue;
                console.log('--this.btnConfirmdata.medicationAndVitaminsOptionsvalue line 1236--' + this.btnConfirmdata.medicationAndVitaminsOptionsvalue);
                if (this.btnConfirmdata.medicationAndVitaminsOptionsvalue == 'Webster Pack or Signed Management Plan') {
                    this.optionOneSelected = true;
                    this.optionTwoSelected = false;
                }
                else {
                    this.optionOneSelected = false;
                    this.optionTwoSelected = true;
                }

                if (this.btnConfirmdata.medicationAndVitaminsOptionsvalue == undefined || this.btnConfirmdata.medicationAndVitaminsOptionsvalue == '') {
                    this.optionOneSelected = false;
                    this.optionTwoSelected = false;
                }
                this.btnConfirmdata.id = recId;
                this.btnConfirmdata.hideLocationField = result.hideLocationField;
                // this.btnConfirmdata.lastChemoDoseDate = result.lastChemoDoseDate;
                this.btnConfirmdata.OTCStandard = result.OTCStandard;
                console.log('--this.btnConfirmdata.OTCStandard Line 1131--' + this.btnConfirmdata.OTCStandard);
                // this.btnConfirmdata.OTCComments = result.OTCComments;
                this.btnConfirmdata.childImmunisationScheduleCurrent = result.childImmunisationScheduleCurrent;
                this.btnConfirmdata.currentlyonTreatment = result.currentlyonTreatment;
                if(this.btnConfirmdata.currentlyonTreatment == 'Yes'){
                    this.isCurrentlyOnTreatmentYes == true;
                }
                this.btnConfirmdata.MedicationandVitamins = result.MedicationandVitamins;
                this.btnConfirmdata.hasCentralLine = result.hasCentralLine;
                this.btnConfirmdata.hasPortacath = result.hasPortacath;
                this.btnConfirmdata.requiresMedicationOrVitamins = result.requiresMedicationOrVitamins;
                if (this.btnConfirmdata.requiresMedicationOrVitamins == 'Yes') {
                    this.isRequiresMedicationOrVitaminsYes = true;
                }

            })
            .catch(error => {
                console.log('Error8=>' + JSON.stringify(error));
            })


        transportLocationHome({ camId: this.campaignId })
            .then(result => {
                if (result != undefined && result != '') {
                    result.forEach(item => {
                        const option = {
                            label: item,
                            value: item
                        }
                        this.picktransportLocatHome.push(option);
                    });
                }

            })
            .catch(error => {
                //(error);
            })

        transportLocationPic({ camId: this.campaignId })
            .then(result => {
                if (result != undefined && result != '') {
                    result.forEach(item => {
                        const option = {
                            label: item,
                            value: item
                        }
                        this.picktransportLocaPickUp.push(option);
                    });
                }
            })
            .catch(error => {
                //(error);
            })

        this.isModalOpen = true;

    }
    getAllowUpdate() {
        // Get the current URL
        let currentUrl = new URL(window.location.href);

        // Get the search parameters from the URL
        let searchParams = new URLSearchParams(currentUrl.search);

        // Check if 'allow_updates' is set to 'yes'
        this.allowUpdates = searchParams.get('allow_updates') === 'yes';
    }

    openchild1 = false;
    openchild2 = false;
    isOTCStandardNo = false;
    isCurrentlyOnTreatmentYes = false;
    isRequiresMedicationOrVitaminsYes = false;
    requiresMedicationOrVitaminsError = false;
    hasPortacathError = false;
    hasCentralLineError = false;
    lastChemoDoseDateError = false;
    currentlyonTreatmentError = false;
    OTCStandardError = false;
    // requiredmedicalCommentsError = false;
    childImmunisationScheduleCurrentError = false

    child1handleChange(event) {
        if (event.target.value) {
            this.openchild1 = true;
            // this.btnConfirmdata.eventtransportAccOrNot = event.target.value;
            this.btnConfirmdata.transportPickUpRequired = event.target.value;
        }
        else {
            this.openchild1 = false;
            // this.btnConfirmdata.eventtransportAccOrNot = event.target.value;
            this.btnConfirmdata.transportPickUpRequired = event.target.value;
        }
    }

    handleimmunisations(event) {
        this.btnConfirmdata.childImmunisationScheduleCurrent = event.target.value;

         if(this.isAgeCamp){
        if (this.btnConfirmdata.childImmunisationScheduleCurrent === 'Yes' || this.btnConfirmdata.childImmunisationScheduleCurrent === 'No' ) {
            this.childImmunisationScheduleCurrentError = false;
        } else if(this.btnConfirmdata.currentlyonTreatment === ''|| this.btnConfirmdata.currentlyonTreatment === undefined){
            this.childImmunisationScheduleCurrentError = true;
        }
         }

    }

    handleOTCStandardChange(event) {
        this.btnConfirmdata.OTCStandard = event.target.value;
        if(this.isAgeCamp){
            if (this.btnConfirmdata.OTCStandard === 'Yes' || this.btnConfirmdata.OTCStandard === 'No') {
            this.OTCStandardError = false;
         } else if( this.btnConfirmdata.OTCStandard === '' || this.btnConfirmdata.OTCStandard === undefined) {
            this.OTCStandardError = true;
        }
        }


    }

    handleCurrentlyOnTreatmentChange(event) {
        this.btnConfirmdata.currentlyonTreatment = event.target.value;
        console.log('1288 this.btnConfirmdata.currentlyonTreatment', this.btnConfirmdata.currentlyonTreatment);
        if (this.btnConfirmdata.currentlyonTreatment == 'Yes') {
            this.isCurrentlyOnTreatmentYes = true;

        }
        else {
            this.btnConfirmdata.hasCentralLine = '';
            this.btnConfirmdata.hasPortacath = '';
            this.isCurrentlyOnTreatmentYes = false;
            this.hasCentralLineError = false;
            console.log('-- this.hasCentralLineError lIne 1317--' + this.hasCentralLineError);
            this.hasPortacathError = false;
            console.log('-- this.hasPortacathError lIne 1317--' + this.hasPortacathError);
        }
         if(this.isAgeCamp){
        if (this.btnConfirmdata.currentlyonTreatment === 'Yes' || this.btnConfirmdata.currentlyonTreatment === 'No' ) {
            this.currentlyonTreatmentError = false;
        } else if(this.btnConfirmdata.currentlyonTreatment === '' || this.btnConfirmdata.currentlyonTreatment === undefined) {
            this.currentlyonTreatmentError = true;
        }
         }
    }

    // handleLastDoseOfChemoDateChange(event) {
    //     this.btnConfirmdata.lastChemoDoseDate = event.target.value;
    //     if (this.btnConfirmdata.lastChemoDoseDate != 'Yes' || this.btnConfirmdata.lastChemoDoseDate != 'No') {
    //         this.lastChemoDoseDateError = true;
    //         console.log('Line 1261 this.lastChemoDoseDateError---' + this.lastChemoDoseDateError);
    //     }
    //     else{
    //         this.lastChemoDoseDateError = false;
    //         console.log('Line 1265 this.lastChemoDoseDateError ---' + this.lastChemoDoseDateError);
    //     }
    // }

    handleHasCentralLineChange(event) {
        this.btnConfirmdata.hasCentralLine = event.target.value;
         if(this.isAgeCamp){
        if (this.btnConfirmdata.hasCentralLine === 'Yes' || this.btnConfirmdata.hasCentralLine === 'No' ) {
            this.hasCentralLineError = false;
        } else if(this.btnConfirmdata.hasCentralLine === undefined || this.btnConfirmdata.hasCentralLine === '') {
            this.hasCentralLineError = true;
        }
        }
    }

    handleHasPortacathChange(event) {
        this.btnConfirmdata.hasPortacath = event.target.value;
         if(this.isAgeCamp){
        if (this.btnConfirmdata.hasPortacath === 'Yes' || this.btnConfirmdata.hasPortacath === 'No' ) {
            this.hasPortacathError = false;
        } else if(this.btnConfirmdata.hasPortacath === undefined || this.btnConfirmdata.hasPortacath === '') {
            this.hasPortacathError = true;
        }
        }

    }

    handleRequiresMedicationOrVitaminsChange(event) {
        this.btnConfirmdata.requiresMedicationOrVitamins = event.target.value;
        console.log('1338 this.btnConfirmdata.requiresMedicationOrVitamins', this.btnConfirmdata.requiresMedicationOrVitamins);

        if(this.isAgeCamp){ 
        if (this.btnConfirmdata.requiresMedicationOrVitamins == 'Yes') {
            this.isRequiresMedicationOrVitaminsYes = true;
        }
        else {
            this.isRequiresMedicationOrVitaminsYes = false;
        }

        if (this.btnConfirmdata.requiresMedicationOrVitamins === 'Yes' || this.btnConfirmdata.requiresMedicationOrVitamins === 'No' ) {
            this.requiresMedicationOrVitaminsError = false;
        } else if(this.btnConfirmdata.requiresMedicationOrVitamins === '' || this.btnConfirmdata.requiresMedicationOrVitamins === undefined) {
            this.requiresMedicationOrVitaminsError = true;
        }
        }

    }

    @track optionOneSelected = false;
    @track optionTwoSelected = false;

    handleMedicalCheckbox(event) {
        const value = event.target.value;
        console.log('--value line 1342--' + value);
        this.btnConfirmdata.medicationAndVitaminsOptionsvalue = value;
        console.log('medicationAndVitaminsOptionsvalue line 1344-->' + this.btnConfirmdata.medicationAndVitaminsOptionsvalue);

        // Update the state based on the value
        if (value === 'Webster Pack or Signed Management Plan') {
            console.log('thisoptionOneSelected line 1432---', value);
            this.optionOneSelected = !this.optionOneSelected;
            this.optionTwoSelected = false;

        } else if (value === 'Original Packaging') {
            console.log('thisoptionOneSelected line 1437---', value);
            this.optionTwoSelected = !this.optionTwoSelected;
            this.optionOneSelected = false;
        }
        if(this.isAgeCamp){

        
        if (this.btnConfirmdata.medicationAndVitaminsOptionsvalue === undefined || this.btnConfirmdata.medicationAndVitaminsOptionsvalue == '') {
            this.checkBoxValidation = true;
            console.log('No checkbox is selected');
            // return; // Exit the function if no checkbox is selected
        }
        else {
            this.checkBoxValidation = false;
        }
        }
    }


    handleMedicationAndVitaminsChange(event) {
        this.btnConfirmdata.medicationAndVitamins = event.target.value;
    }

    @wire(getPicklistValues, {
        recordTypeId: '01228000000RBx8AAG',
        fieldApiName: camp_Locations
    })
    picklistValueCampLocation({ error, data }) {
        if (data) {
            // Map the data values to an array of options
            this.campOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }

        // If there is an error
        else if (error) {
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '01228000000RBwsAAG',
        fieldApiName: home_Locations
    })
    picklistValueHomeLocation({ error, data }) {
        if (data) {
            // Map the data values to an array of options
            this.homeOptions = data.values.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }

        // If there is an error
        else if (error) {
        }
    }


    handleChangePicked(event) {
        this.btnConfirmdata.eventtransportAccOrNot = event.target.value;
    }

    handleChangeDrop(event) {
        this.btnConfirmdata.homeTransportAcceptOrNot = event.target.value;
    }
    child2handleChange(event) {
        if (event.target.value) {
            this.openchild2 = true;
            //this.btnConfirmdata.homeTransportAcceptOrNot = event.target.value;
            this.btnConfirmdata.transportDropOffRequired = event.target.value;
        }
        else {
            this.openchild2 = false;
            //this.btnConfirmdata.homeTransportAcceptOrNot = event.target.value;
            this.btnConfirmdata.transportDropOffRequired = event.target.value;
        }
    }

    handleSpecial(event) {
        this.btnConfirmdata.specialCelebration = event.target.value;
    }

    handleComments(event) {
        this.btnConfirmdata.medicalComments = event.target.value;
        console.log('Line 1524--> ' + this.btnConfirmdata.medicalComments);
        // if (this.btnConfirmdata.medicalComments == undefined || this.btnConfirmdata.medicalComments =='') {
        //     console.log('Line 1525--> '+ this.btnConfirmdata.medicalComments);

        //      console.log('this.btnConfirmdata.medicalComments---'+this.btnConfirmdata.medicalComments);
        //     console.log('inside if==> '+ typeof this.requiredmedicalCommentsError);
        //     this.requiredmedicalCommentsError = true;
        // } else {
        //     this.requiredmedicalCommentsError = false;
        // }
    }
    openSharing = false;

    //Handle changes in input values.
    changeDeatilsHandler(event) {
        switch (event.target.name) {
            case 'mediaTakePhoto':
                // this.Family_Member_On_Treatment__c.mediaTakePhoto = event.target.checked;
                // this.openSharing = event.target.checked;
                this.tableAccountFieldData.mediaTakePhoto = event.target.checked;
                break;
            case 'mediaparticipant':
                this.tableAccountFieldData.mediaparticipant = event.target.checked;
                break;
            case 'mediaSharingPhoto':
                this.tableAccountFieldData.mediaSharingPhoto = event.target.checked;
            case 'name':
                this.tableAccountFieldData.emergency_Contact = event.target.value;
                break;
            case 'phone':
                this.tableAccountFieldData.emergency_Contact_Phone = event.target.value;
                break;
            case 'mobile':
                this.tableAccountFieldData.emergency_Contact_Mobile = event.target.value;
                break;
            case 'relationship':
                this.tableAccountFieldData.emergency_Contact_Relationship = event.target.value;
                break;
            case 'medical':
                this.tableAccountFieldData.family_Member_On_Treatment = event.target.checked;
                break;
            case 'consent':
                if (event.target.checked == true) {
                    this.tableAccountFieldData.consent = false;
                }
                this.tableAccountFieldData.consent = event.target.checked;
                this.conData.forEach(item => {
                    if (item.confirmdetails == true && this.tableAccountFieldData.consent == true && this.tableAccountFieldData.behavioralExpectations == true) {
                        this.isComplete = false;
                    }
                });
                break;
            case 'behavioralExpectations':
                if (event.target.checked == true) {
                    this.tableAccountFieldData.behavioralExpectations = false;
                }
                this.tableAccountFieldData.behavioralExpectations = event.target.checked;
                this.conData.forEach(item => {
                    if (item.confirmdetails == true && this.tableAccountFieldData.consent == true && this.tableAccountFieldData.behavioralExpectations == true) {
                        this.isComplete = false;
                    }
                });
        }
    }

    customModalOpen = false;
    customQue = false;
    showPickList = false;
    cancelHandle(event) {
        this.familyAttId = event.target.dataset.id;
        this.callHandle = 'Cancel';
        console.log('this.dataget ' + this.callHandle);
        this.title = this.callHandle + " Event Invitation";
        console.log('this.title: ' + this.title);

        this.customModalOpen = true;
        this.customQue = true;

        this.customModalValidation = false;
        this.showPickList = false;
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.customModalOpen = false;

    }

    modalInputvalue;
    handleModalInput(event) {
        this.modalInputvalue = event.target.value;
        if (this.modalInputvalue != undefined && this.modalInputvalue != '') {
            this.customModalValidation = false;
        }
    }
    cancelReasPicValue;
    handleModalInputValue(event) {
        const selectmodalInputpisclistValue = event.target.value;
        this.cancelReasPicValue = event.target.value;
        console.log(' selectmodalInputpisclistValue-----' + selectmodalInputpisclistValue);
        console.log(' PickListValue------' + this.cancelReasPicValue);
    }

    customModalValidation = false;
    cancelTrue = true;

    handleModalOk(event) {
        console.log("=========>1");

        const dataget = event.target.dataset.id;

        console.log("=========>2" + dataget);
        if ((this.modalInputvalue != undefined && this.modalInputvalue != '') || this.customQue == false) {
            console.log("=========>3 inside if");
            this.customModalOpen = false;
            this.waitForRes = true;
            console.log('--1217 - --' + this.familyAttId);
            if (!this.customQue) {
                this.handleDeclined();
                console.log("=========>4 inside if");
            }
            else {
                updateStatus({ famiAttId: this.familyAttId, status: 'Cancelled', cancelReason: this.modalInputvalue, cancelResasonPicklist: this.cancelReasPicValue })
                    .then(result => {
                        console.log('result---->' + JSON.stringify(result));
                        // if (dataget == 'Declined') {
                        if (dataget == 'Cancel') {
                            console.log('check cancelled 1244====>');
                            this.waitForRes = false;
                            this.customModalOpen = false;
                            this.handleAlertClick2();
                            this.callEventWithId();



                        }
                        else {
                            console.log('check cancelled 1254====>');
                            this.waitForRes = false;
                            this.customModalOpen = false;
                            this.handleAlertClick2();
                            this.callEventWithId();
                            this.eventDetailsHandle();
                            this.cancelTrue = false;
                        }
                    })
                    .catch(error => {
                        this.waitForRes = false;
                        this.customModalOpen = false;
                        console.log('error 1260=> ' + JSON.stringify(error));
                        console.log('error 12601=> ' + JSON.stringify(error.stack));
                        console.log('error 12602=> ' + error.message);
                    })
            }
        }
        else {
            //('Check here Ok button-')          
            this.customModalValidation = true;

        }

    }
}