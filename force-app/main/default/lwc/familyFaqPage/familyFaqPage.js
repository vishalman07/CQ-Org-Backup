import { LightningElement } from 'lwc';
import getFaqData from '@salesforce/apex/FamilyFaqPageController.getFaqData';
import headerblueImg from '@salesforce/resourceUrl/CQ_blueImage';
import faq from '@salesforce/label/c.CQ_nav_FAQ';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';
export default class FamilyFaqPage extends LightningElement {
    headerblueImg = headerblueImg;

    label = {
        faq
    }

    faqContent;
    error;

    connectedCallback(){
        this.fetchFaqDta();
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


    fetchFaqDta(){
        getFaqData()
        .then(result=>{
            // this.faqContent = result;
            this.faqContent = JSON.parse(result).Content__c
            console.log('this.faqData' + JSON.stringify(this.faqContent));
            // console.log('this.faqData' + this.faqData);
        })
        .catch(error=>{
            this.error = error;
            console.log('this.faqData' + this.error);
        })
    }
}