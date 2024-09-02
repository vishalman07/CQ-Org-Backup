import { LightningElement, wire, track } from 'lwc';
import checkIncidentAccess from '@salesforce/apex/CommunityLoginController.checkIncidentAccess';
import fatchIncident from '@salesforce/apex/CommunityLoginController.fatchIncidentRecord';
import updateIncident from '@salesforce/apex/CommunityLoginController.updateCommentIncident';
import userInfo from '@salesforce/apex/CommunityLoginController.avtarUser';
import headerblueImg from '@salesforce/resourceUrl/CQ_blueImage';
//Custom Label

import incidents from '@salesforce/label/c.CQ_Incidents';
import addNewBtn from '@salesforce/label/c.CQ_Add_New_btn';
import downloadIncident from '@salesforce/label/c.CQ_Download_Incident';
import downloadIncidentLink from '@salesforce/label/c.CQ_DownloadIncidentLink';
import jotFormLink from '@salesforce/label/c.CQ_JotFormLink';
import incidentIdtableHeader from '@salesforce/label/c.CQ_Incident_ID_table_header';
import incidentDateTimetableHeader from '@salesforce/label/c.CQ_Incident_Date_Time_table_header';
import incidentTypeTableHeader from '@salesforce/label/c.CQ_Incident_Type_table_header';
import severityTableHeader from '@salesforce/label/c.CQ_Severity_table_header';
import statusTableHeader from '@salesforce/label/c.CQ_Status_table_header';
import reporternameTableheader from '@salesforce/label/c.CQ_Reporters_Name_table_header';
import actionTableHeader from '@salesforce/label/c.CQ_Action_table_header';
import LightningAlert from 'lightning/alert';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class CommunityIncidentPage extends LightningElement {

    // Resource for the blue header image.
    headerblueImg = headerblueImg;

    label = {
        incidents,
        addNewBtn,
        downloadIncident,
        jotFormLink,
        downloadIncidentLink,
        incidentIdtableHeader,
        incidentDateTimetableHeader,
        incidentTypeTableHeader,
        severityTableHeader,
        statusTableHeader,
        reporternameTableheader,
        actionTableHeader
    }

    // Arrays and variables to store incident data and manage UI states.
    @track username;
    @track incidentDataAccess = [];
    error;
    @track recordId = {};
    showDetails;
    waitForRes = false;
    openRecord = false;
    record = {
        Incident_Date_Time__c: '',
        RecordType: { Name: '' },
        Severity__c: '',
        Status__c: '',
        Stakeholder_s_Involved__c: '',
        Stakeholder_s_Other__c: '',
        Incident_Location__c: '',
        Incident_description__c: '',
        Were_emergency_services_required__c: '',
        Was_first_aid_required__c: '',
        First_Aid_provided__c: '',
        First_Aider__c: '',
        Incident_Type__c: '',
        Type_of_Behaviour__c: '',
        Observed_Triggers__c: '',
        Staff_Volunteers_Involved__c: '',
        Injuries_sustained__c: '',
        Nature_of_bodily_injury__c: '',
        Emergency_Contact_Notified__c: '',
        Call_Details__c: '',
        Supervisor_Name__c: '',
        Supervisor_Notified_Date__c: '',
        Actions_taken__c: '',
        Volunteer_Comments__c: '',
        Reporters_Name__c: ''
    };
    @track comment;





    storeSessionUserId;
    //Calling the function in connectedCallback
    connectedCallback() {
        if (sessionStorage.getItem('userId') != undefined) {
            this.storeSessionUserId = sessionStorage.getItem('userId');
            this.incidentAccess();
            this.getUseInfo();
        }
        this.loadMrOrangeStyles();
    }


    loadMrOrangeStyles() {
        if (location.origin.includes('partial')) {
            loadStyle(this, partialFont + '/campqualityCss/partialFont.css')
                .then(() => {
                    // Stylesheet loaded successfully
                    console.log('font lodded');
                })
                .catch(error => {
                    // Handle error if stylesheet fails to load
                    console.error('Error loading MrOrange stylesheet: ', error);
                });
        }
        else {
            loadStyle(this, partialFont + '/campqualityCss/productionFont.css')
                .then(() => {
                    // Stylesheet loaded successfully
                    console.log('font lodded');
                })
                .catch(error => {
                    // Handle error if stylesheet fails to load
                    console.error('Error loading MrOrange stylesheet: ', error);
                });
        }
    }



    trimIncidentId;
    hideIncidentType = false;
    showMessage = false;
    //Invokes the checkIncidentAccess Apex method to check user access to incidents.
    incidentAccess() {
        checkIncidentAccess({ recUserId: this.storeSessionUserId })
            .then(result => {
                if (!result.includes('No access')) {


                    this.incidentDataAccess = JSON.parse(result);
                    console.log('---incidentDataAccess---' + JSON.stringify(this.incidentDataAccess));
                    // if(this.incidentDataAccess[0].Incident_Date_Time__c !=undefined){
                    //     this.trimIncidentId = this.incidentDataAccess[0].Incident_Date_Time__c;
                    // }
                    // let datePart = this.trimIncidentId.split('T')[0];

                    let modifiedIncidentData = [];
                    for (const ele of this.incidentDataAccess) {
                        let objData = {
                            Name: ele.Name,
                            Incident_Type__c: ele.Incident_Type__c,
                            Severity__c: ele.Severity__c,
                            Status__c: ele.Status__c,
                            Reporters_Name__c: ele.Reporters_Name__c,
                            Reporters_Name__c: ele.Reporters_Name__c,
                            Id: ele.Id,
                            hideIncidentType: false
                        };


                        console.log('===ele===' + JSON.stringify(ele));
                        if (ele.Incident_Date_Time__c != undefined && ele.Incident_Date_Time__c !== '' && ele.Incident_Date_Time__c.trim().length > 0) {
                            let dateComponents = ele.Incident_Date_Time__c.split('T')[0].split('-');
                            let day = dateComponents[2];
                            let month = dateComponents[1];
                            let year = dateComponents[0];
                            objData.Incident_Date_Time__c = `${day}-${month}-${year}`;
                        }

                        if (ele.Incident_Type__c != 'Customer/Client Complaint' && ele.RecordType.DeveloperName != 'Complaint') {
                            console.log('---ele.Incident_Type__c line 155--- ' + ele.Incident_Type__c);
                            objData.hideIncidentType = true;
                        }
                        else {
                            objData.hideIncidentType = false;

                            // this.hideIncidentType = false;
                            console.log('---ele.Incident_Type__c  line 161---' + JSON.stringify(objData.hideIncidentType));
                        }
                        modifiedIncidentData.push(objData);
                        console.log('modifiedIncidentData---166-------' + modifiedIncidentData);
                        // if()

                    }
                    this.incidentDataAccess = modifiedIncidentData;
                    console.log('---this.incidentDataAccess2' + JSON.stringify(this.incidentDataAccess));
                }
                else if ((this.incidentDataAccess == null || this.incidentDataAccess == undefined || this.incidentDataAccess == '' || this.incidentDataAccess.length === 0 || result.includes('No access'))) {
                    this.showMessage = true;
                }
            })
            .catch(error => {
                this.error = error;
                console.log('---error---' + error);
            })
    }

    defaultBehaviour = false;
    typeOfBeha;
    hideIncidentTypeInDetail = true;
    //Handles the click event for viewing incident details.
    viewhandle(event) {
        this.recordId = event.target.dataset.id;
        fatchIncident({ recordId: this.recordId })
            .then(result => {
                this.openRecord = true;
                console.log('Innner result---' + JSON.stringify(result));
                Object.keys(this.record).forEach(field => {
                    // Check if the field exists in the incomingData object
                    if (result.hasOwnProperty(field)) {
                        // Assign the value from incomingData to incidentObject
                        this.record[field] = result[field];
                        if (this.record[field] === 'Customer/Client Complaint') {
                            this.hideIncidentTypeInDetail = true;
                            console.log('Inside if 197---' + this.record[field])
                        }
                        else {
                            this.hideIncidentTypeInDetail = false;
                            console.log('Inside else  201---' + this.record[field])
                        }
                        console.log('---this.record[field]----' + this.record[field])
                        console.log('---this.record[field]2----' + JSON.stringify(this.record[field]));
                    }
                    else {
                        // Clear out the field if it doesn't exist in result
                        this.record[field] = '';
                    }
                });
                //Default behaviour 
                if (result.Type_of_Behaviour__c == undefined) {
                    this.defaultBehaviour = true;
                    this.typeOfBeha = 'Bullying or Harassment';
                }

            })
            .catch(error => {
                console.log('error = ' + JSON.stringify(error));
            })
    }
    //Closes the incident details modal.
    closedDetails() {
        this.openRecord = false;
    }

    //Handles the change event for the comment input field.
    changeCommentHandler(event) {
        this.comment = event.target.value;
    }


    getUseInfo() {
        userInfo({ reocrdId: this.storeSessionUserId })
            .then(result => {
                this.username = result.Name;
            })
            .catch(error => {
                console.log('-error--' + JSON.stringify(error));
            })
    }


    //Handles the save action for updating incident comments.
    handleSave() {
        this.waitForRes = false;

        const d = new Date();
        d.setUTCDate(d.getUTCDate());
        const forDate = d.toString().substring(0, d.toString().indexOf('('));
        const newComment = this.comment;

        const updatedComments = `${this.record.Volunteer_Comments__c}\n===${forDate} (${this.username})===\n${newComment}`;
        updateIncident({ comment: updatedComments, recordId: this.recordId })
            .then(result => {
                this.waitForRes = false;
                this.handleAlertClick(result);
            })
            .catch(error => {
                this.waitForRes = false;
            });
    }
    //Handles the opening of the Lightning Alert modal.
    async handleAlertClick(msg) {
        await LightningAlert.open({
            message: msg,
            theme: 'success',
            variant: 'headerless', // this is the header text
        });
        this.openRecord = false;
    }



    get downloadIncidentUrl() {
        return decodeURIComponent(downloadIncidentLink);
    }

    get jotFormUrl() {
        return decodeURIComponent(jotFormLink);
    }


}