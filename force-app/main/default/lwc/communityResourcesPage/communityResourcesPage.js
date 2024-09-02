import { LightningElement , wire} from 'lwc';
import headerImg from '@salesforce/resourceUrl/CQ_lightOrangeHeader';
import resources from '@salesforce/label/c.CQ_Resources_Heading';
import getResources from '@salesforce/apex/VolunteerResourcesController.getResources';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class CommunityResourcesPage extends LightningElement {

headerLightOrangeImg = headerImg;
label = {
    resources
    }
    content;
    

    connectedCallback(){
        this.loadMrOrangeStyles();
        getResources()
        .then(result => {
            console.log('Get Resources --> ' + result);
            this.content = JSON.parse(result).Content__c; 
        })
        .catch(error =>{
            console.log(JSON.stringify(error));
        })                 
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
    
}