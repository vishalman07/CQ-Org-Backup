import { LightningElement } from 'lwc';
import headerImg from '@salesforce/resourceUrl/CQ_lightOrangeHeader';
import getFamilyResources from '@salesforce/apex/FamilyResourcePageController.getFamilyResources'
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import resource from '@salesforce/label/c.CQ_Resources';
import extraSupHeading from '@salesforce/label/c.CQ_Extra_Sup_Heading';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class FamilyResourcePage extends LightningElement {

    headerLightOrangeImg = headerImg;
    famResourceContent;

    label = {
        resource,
        extraSupHeading
    }

    connectedCallback(){
        this.loadMrOrangeStyles() 
        getFamilyResources()
        .then(result => {
            this.famResourceContent = JSON.parse(result).Content__c; 
        })
        .catch(error =>{
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