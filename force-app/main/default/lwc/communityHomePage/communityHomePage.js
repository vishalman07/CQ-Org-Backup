import { LightningElement , wire, api} from 'lwc';
import homeContent from '@salesforce/apex/CommunityLoginController.homePageContect';
import campQualityImg from '@salesforce/resourceUrl/CampQuality';
import pinkheaderImg from '@salesforce/resourceUrl/CQ_pinkHeaderTop'; 
import welcomeText from '@salesforce/label/c.CQ_Welcome_Text';
import helpCall from '@salesforce/label/c.CQ_Help_and_Call_Text';
import logout from '@salesforce/label/c.CQ_Logout';
import profile from '@salesforce/label/c.CQ_Profile';
import contactUs from '@salesforce/label/c.CQ_Contact_Us';
import home from '@salesforce/label/c.CQ_Home';
import signedAs from '@salesforce/label/c.CQ_Signed_in_as';
//Use for navigation
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import UserFirstName from '@salesforce/schema/User.FirstName';
import UserLastName from '@salesforce/schema/User.LastName';
import userEmailFld from '@salesforce/schema/User.Email';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class CommunityHomePage extends LightningElement {

    // Initialize variables and resources
    campQualityLogo = campQualityImg;
    headerPinkImg = pinkheaderImg;
    currentUserName;
    currentEmail;
    avtar;
    homeContent = [];
    error;
    // Define labels for UI elements
    label = {
        welcomeText,
        helpCall,
        logout,
        profile,
        contactUs,
        home,
        signedAs
    };


    @api homePageHandle(){
        window.scrollTo(0, 0);
    }

    //Display the username and email 
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD , userEmailFld , UserFirstName , UserLastName]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentEmail = data.fields.Email.value;
            this.avtar = data.fields.FirstName.value.substring(0,1)+data.fields.LastName.value.substring(0,1);
        }
        else if (error) {
            this.error = error ;
        }
    }

//Dropdown Button 
dropdownClass = 'dropdown-content'; // Initial state is hidden
    toggleDropdown() {
        // Toggle the dropdown's visibility
        this.dropdownClass = this.dropdownClass === 'dropdown-content' ? 'dropdown-content show ' : 'dropdown-content'; 
    }
dropdownUserClass = 'dropdown-content_User'; // Initial state is hidden
    toggleDropdownuser(){
          this.dropdownUserClass = this.dropdownUserClass === 'dropdown-content_User' ? 'dropdown-content_User show ' : 'dropdown-content_User';
    }

    storeSessionUserId;
    connectedCallback(){
        this.loadMrOrangeStyles();
        if(this.generatedOtp == this.userOtp){
            console.log('Verified OTP');
            console.log('result.userId undefined====='+ this.userIdToStore);
            if(sessionStorage.getItem('userId') != undefined){
                this.storeSessionUserId = sessionStorage.getItem('userId');
            this.homeData();
        } 
        else{
            this.incorrectOtp = true;
        }

    }
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

    homeData(){
        homeContent()
        .then(result=>{
            this.homeContent = result;
        })
        .catch(error=>{
            console.log('home Page======>' + error);
            this.error = error;
        })
    }
}