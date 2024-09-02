import { LightningElement, track, api } from 'lwc';
import getContactDetails from '@salesforce/apex/VolunteerEligibilityController.getContactDetails';
import getCamEventDetail from '@salesforce/apex/VolunteerEligibilityController.getCamEventDetail';
import complainceLearning from '@salesforce/apex/VolunteerEligibilityController.complainceLearning';
import uploadFile from '@salesforce/apex/VolunteerEligibilityController.uploadFile';
import litMosCallout from '@salesforce/apex/VolunteerEligibilityController.litMosCallout';
import litMosCalloutforRefresh from '@salesforce/apex/VolunteerEligibilityController.litMosCalloutforRefresh';
import LightningAlert from 'lightning/alert';
import LightningConfirm from "lightning/confirm";




export default class VolunteerEligibility extends LightningElement {


    openAppliCationBox = true;
    openLearning = false;
    openBoarding =false;
    hideOnBoardignRecord =true;
    openCertficate = false;
    storeSessionUserId;
    volunteerStatus;
    eventDetails = [];
    clickEventUrl;
    @track onlineLearningVar = [];
    @track onBoardingVar = [];
    @track onCertficationVar = [];
    showUploadBtn = false;
    showLaunchBtn = false;
    uploadBox = false;
    learnAssigncount = 0;
    certAssigncount = 0;
     myRecordId;

    onAppliClick(event){
        // Toggle the value of openAppliCationBox
        this.openAppliCationBox  = this.openAppliCationBox  ? false : true;    
        this.openLearning = false;
        this.openBoarding = false;
        this.openCertficate = false; 

    }

    onLearning(){
          // Toggle the value of openAppliCationBox
          window.scroll({
            bottom: 100,
            behavior: "smooth",
          });
        this.openLearning = this.openLearning ? false : true;
        this.openAppliCationBox = false;
        this.openCertficate = false; 
        this.openBoarding = false;
    }

    onBoarding(){
        //Scroll specifix pixel
        // window.scrollTo(0, 300);
       // Toggle the value of openAppliCationBox
        this.openBoarding = this.openBoarding ? false : true;
        if( this.volunteerStatus == 'Volunteer'){
            this.hideOnBoardignRecord =false;
       }  
        this.openCertficate = false; 
       this.openLearning = false;
       this.openAppliCationBox = false;
        
    }

    onCertificate(){
        //Scroll specifix pixel
        // window.scrollTo(0, 500);
        // Toggle the value of openAppliCationBox
       this.openCertficate = this.openCertficate ? false : true;
       this.openBoarding = false;
       this.openLearning = false;
       this.openAppliCationBox = false;
    }

    toggleSection(event) {
        const section = event.currentTarget.dataset.section;
        switch(section) {
            case 'Application':
                this.openAppliCationBox = !this.openAppliCationBox;
                break;
            case 'Learning':
                this.openLearning = !this.openLearning;
                break;
            case 'Onboarding':
                this.openBoarding = !this.openBoarding;
                break;
            case 'Certifications':
                this.openCertficate = !this.openCertficate;
                break;
        }
    }


    mytitle;
    handleUploadBtn(event){
        this.uploadBox = true;
        this.myRecordId = event.target.dataset.id;
        this.mytitle = event.target.dataset.title;
        console.log('--- this.myRecordId---'+  this.myRecordId);
    }

    filename;
    fileData
    openfileUpload(event){
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.myRecordId,
                'recUserId' :this.storeSessionUserId,
            }
            console.log('this.fileData' + JSON.stringify(this.fileData));
            console.log('this.fileData' + this.fileData);

        }
        reader.readAsDataURL(file)
    }

    @track calloutRespList = [];
     refreshProgress = false;
    handleRefreshBtn(){
        this.refreshProgress = true;
        litMosCalloutforRefresh({recUserId :this.storeSessionUserId})
        .then(result=>{
            console.log('---result ---123459999---' + JSON.stringify(result)); // Log the entire result object
            this.volunteerCampUpdate(result);

              
        })
        .catch(error=>{
            this.refreshProgress = false;
            console.log('Lear error view launh refresh-->'+ JSON.stringify(error));
        })
    }

    handleUploadBtnSave(){
        console.log('Inside the upload btn')
        // consol
        if(this.fileData){
        
        const {base64, filename, recordId,recUserId} = this.fileData
        uploadFile({ base64, filename, recordId,recUserId }).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            // this.toast(title)
            this.uploadBox = false;
            this.handleAlertClick();
            console.log('--result  lIne 154---'+ result);
         })
        }
        else{
            this.handleAlertClickError();
            this.uploadBox = false;
        }
    }

    async handleAlertClickError() {
        await LightningAlert.open({
            message: 'Please attach the image',
            theme: 'error', // a red theme intended for error states
            //label: 'Image Uploded', // this is the header text
        });
        //Alert has been closed
    }

    async handleAlertClick() {
        await LightningAlert.open({
            message: 'Image Uploded successfully',
            theme: 'success', 
            label: 'Image Uploded', // this is the header text
        });
        //Alert has been closed
    }

    handlecancelModal(){
        this.uploadBox = false;
    }



    connectedCallback(){
         if(sessionStorage.getItem('userId') != undefined){
            this.storeSessionUserId = sessionStorage.getItem('userId');
            console.log('---storeSessionUserId---'+ this.storeSessionUserId);
            this.showContactStatus();
            this.showEventDetail();
            this.onlineLearning();
         }
    }

    showContactStatus(){
        getContactDetails({recUserId :this.storeSessionUserId})
        .then(result=>{
            console.log('--result---'+ result);
            this.volunteerStatus = result;
            // if( this.volunteerStatus == 'Volunteer'){
            //     this.hideOnBoardignRecord =false;
            // }
        })
        .catch(error=>{
            console.log('--ERROR---'+ JSON.stringify(error));
        })
    }

    showEvent = false;
    showEventDetail(){
        getCamEventDetail({recUserId :this.storeSessionUserId})
        .then(result=>{
            console.log('--result Event---'+ JSON.stringify(result));
            if(result !=undefined && result.length > 0){       
            // this.eventDetails = result;

            // console.log()
            this.showEvent = true;
            result.forEach(event => {
                let eventObj = {
                    eventDate : '',
                    eventId : event.id,
                    eventTitle : event.eventTitle
                }
                if(event.eventDate !=undefined){
                    // event.eventDate = this.dayFormatfunction(event.startDate);
                    eventObj.eventDate =  this.dayFormatfunction(event.eventDate);                
                }

                this.eventDetails.push(eventObj);

                this.clickEventUrl = '/volunteer/?page=event&Id='+ event.eventId;
                console.log('--clickEventUrl---'+ this.clickEventUrl);
                console.log('--result Event 1.0---'+ JSON.stringify(result));
            });
            console.log('--eventDetails2.0---'+ JSON.stringify(this.eventDetails));
            
        }
        else{
            this.showEvent = false;
        }
        })
        .catch(error=>{
            console.log('--ERROR event---'+ JSON.stringify(error));
        })
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

        return `${dayOfWeek}  ${month} ${day}${dayOrdinal}, ${year}`;
    }

    showCalloutError = false;
    refreshBtn = false;
    compliId= '';
    async handleLearnLaunch(event){

        const result = await LightningConfirm.open({
            message: "You are now leaving your Volunteer Portal and going to Litmos, our online training platform. Once you have completed your course in Litmos your status will be updated here and you can move onto the next learning course. Click on Ok to proceed",
            variant: "default", // headerless
            title : ''
        });

        //Confirm has been closed

        //result is true if OK was clicked
        if (result) {
            this.refreshBtn = true;
            this.compliId = event.target.dataset.id;
            console.log('---compliId--'+ this.compliId);
            litMosCallout({recUserId :this.storeSessionUserId, isCourse : this.refreshBtn})
                .then(result=>{
                    if(result.includes('Please try after 1 or 2 minute')){
                        this.showCalloutError = true;
                    }
                    else {
                        //window.open(result+'='+this.volCourseId+'&skipFirstLogin=true&titlebar=false');
                        window.open(result+'&c='+this.compliId+'&skipFirstLogin=true&titlebar=false');
                    }
                    console.log('---result ---12345---' + JSON.stringify(result)); // Log the entire result object
                    
                   // console.log('---this.loginKey1--'+JSON.stringify(result.LoginKey));
                    // console.log('---result777---'+ result);
                    // console.log('---this.loginKey1--'+result.LoginKey);
                })
                .catch(error=>{
                    console.log('Lear error view launh-->'+ JSON.stringify(error));
                })
        }
            }


    volCourseId;
    learningCourseId;
    boardingCourseId;
    certifiCourseId;
    onlineLearning(){
       
        complainceLearning({recUserId :this.storeSessionUserId})
        .then(result=>{
            console.log('---result Learning---'+ JSON.stringify(result));
            this.volunteerCampUpdate(result);
        })
        .catch(error=>{
            console.log('Lear error-->'+ JSON.stringify(error));
            console.log('Error message-->', error.message);
            console.log('Error stack-->', error.stack);
        })
    }

    volunteerCampUpdate(result){
        let count = 0;
        let certCount = 0;
        this.onlineLearningVar = [];
        
        result.forEach(item=>{
           // this.refreshProgress = false;
           // console.log('---this.refreshProgress call--------'+ this.refreshProgress);
            if(item.Criteria_Type__c == "Online Learning"){
                this.learningCourseId = item.Litmos_Course_ID__c;
                console.log('---this.learningCourseId--'+ this.learningCourseId);
                if(item.Status__c == "In Progress"){
                    this.showLaunchBtn = true;
                    this.volCourseId = item.Litmos_Course_ID__c;
                    console.log('---volCourseId--'+JSON.stringify(this.volCourseId));
                    this.learnAssigncount= count+= 1; 
                    console.log('---this.learnAssigncount----'+ this.learnAssigncount);
                    // this.volCourseName = item.Course_Name__c;                                                           
                    const obj1 = {
                        item : item,
                        showLaunchBtn : this.showLaunchBtn
                    }
                    this.onlineLearningVar.push(obj1);
                }
                else if(item.Status__c == "Assigned"){
                    this.learnAssigncount= count+= 1;                       
                    console.log('this.learnAssigncount++'+ this.learnAssigncount);
                    this.onlineLearningVar.push(item);
                }
                else{
                    this.onlineLearningVar.push(item);
                    console.log('---Line 300---' + this.onlineLearningVar);
                }
                console.log('--onlineLearningVar--44--'+ JSON.stringify(this.onlineLearningVar))
            }
            if(item.Criteria_Type__c == "Onboarding"){
                this.boardingCourseId = item.Litmos_Course_ID__c;
                this.onBoardingVar.push(item);
                console.log('--onBoardingVar--'+ JSON.stringify(this.onBoardingVar))
            }
            if(item.Criteria_Type__c == "Certifications"){
                this.certifiCourseId = item.Litmos_Course_ID__c;
                if(item.Status__c == "Assigned"){
                    console.log('items cer--+'+ JSON.stringify(item));
                    const obj = {
                        item : item,
                        showUploadBtn : true,
                        
                    }

                    if(item.Date_Expires__c != undefined){
                    // Split the date string into an array [YYYY, MM, DD]
                    const dateParts = item.Date_Expires__c.split("-");

                    // Reformat the date to DD/MM/YYYY
                    const formattedDate = `${dateParts[2]}/${dateParts[1]}/${dateParts[0]}`;
                    obj.expiryDate = formattedDate;
                    }

                    this.certAssigncount= certCount+= 1;                       
                    this.onCertficationVar.push(obj);
                    console.log('-onCertficationVar-----22'+ JSON.stringify(this.onCertficationVar));
                }
                
                else{
                    const obj = {
                        item : item,
                        showUploadBtn : false
                    }
                    if(item.Date_Expires__c != undefined){
                    // Split the date string into an array [YYYY, MM, DD]
                    const dateParts = item.Date_Expires__c.split("-");

                    // Reformat the date to DD/MM/YYYY
                    const formattedDate = `${dateParts[2]}/${dateParts[1]}/${dateParts[0]}`;
                    obj.expiryDate = formattedDate;
                    }
                    this.onCertficationVar.push(obj);
                    console.log("-------------- this.onCertficationVar-1234555555"+ JSON.stringify(this.onCertficationVar));
                }
                console.log('--onCertficationVar--'+ JSON.stringify(this.onCertficationVar))
            }
            // setTimeout(() => {
            //     this.refreshProgress = false;
            // console.log('---this.refreshProgress call--------'+ this.refreshProgress)
            // }, 2000);
            this.refreshProgress = false;
            console.log('---this.refreshProgress call--------'+ this.refreshProgress)

        })
    }
}