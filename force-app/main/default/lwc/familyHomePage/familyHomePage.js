import { LightningElement } from 'lwc';
import familyHomeData from '@salesforce/apex/FamilyMyProfilePageController.homePageContect';
import pinkheaderImg from '@salesforce/resourceUrl/CQ_pinkHeaderTop'; 
import home from '@salesforce/label/c.CQ_Home';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class FamilyHomePage extends LightningElement {

    label = {
        home
    }
     
    headerPinkImg = pinkheaderImg;
    homeContent = [];
    error;
    storeSessionUserId ;

    connectedCallback(){
        this.homeData();
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

    homeData(){
        familyHomeData()
        .then(result=>{
            this.homeContent = result;
        })
        .catch(error=>{
            this.error = error;
        })
    }
}