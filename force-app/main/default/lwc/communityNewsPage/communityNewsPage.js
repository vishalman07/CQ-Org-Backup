import { LightningElement, api } from 'lwc';
//Importing custom labels, static resources, apex method
import headerImg from '@salesforce/resourceUrl/CQ_OliveGreenHeader';
import newsHaeding from '@salesforce/label/c.CQ_news_Update_Heading';
import getNewsAndUpdate from '@salesforce/apex/VolunteerNewsUpdateController.getNewsAndUpdate'
import getPage from '@salesforce/apex/VolunteerNewsUpdateController.getPage';
import partialFont from '@salesforce/resourceUrl/campQualityCss';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class CommunityNewsPage extends LightningElement {

// Initialize variables and  static resources
headerOliveGreenImg = headerImg;
//Custom label
label = {
    newsHaeding
    }
    newsData;
    connectedCallback(){
        this.loadMrOrangeStyles();
        if(this.newsData == undefined){
            // Fetching news data from the apex class using imperative method 
            getNewsAndUpdate()
            .then(result=>{
                console.log('result===========>' + result);
                this.newsData = JSON.parse(result).Content__c;
            })
            .catch(error =>{
                console.log('error==> ' + error);
            })
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

    

    // Public API method to open a specific page
    @api openPage(site , page){
        console.log('Site ... !'+site);
        console.log('Page ...!'+page);
        // Calling the Apex method to get content for the specified page
        getPage({site : site , page : page})
        .then(result => {
             // Parsing and setting the fetched news data
            this.newsData = JSON.parse(result).Content__c;
        })
        .catch(error => {
            console.log('this is data error'+JSON.stringify(error));
        })
    }

}