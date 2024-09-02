import { LightningElement } from 'lwc';
//Footer Label
import about from '@salesforce/label/c.CQ_About';
import acknowledge from '@salesforce/label/c.CQ_Acknowledge';
import downloadApple from '@salesforce/label/c.CQ_Download_Apple';
import downloadAnroid from '@salesforce/label/c.CQ_Download_Anroid';
import fujitsu from '@salesforce/label/c.CQ_Fujitsu';
import reg from '@salesforce/label/c.CQ_reg';
import volunteer from '@salesforce/label/c.CQ_volunteer';
import fujitsuImg from '@salesforce/resourceUrl/CampFujitsu';
import footerTopImg from '@salesforce/resourceUrl/CampQualityFooterTop';

export default class SiteFooter extends LightningElement {
    //Import image from static resource and assign in variable 
    fujitsuImage = fujitsuImg;
    footerTopImg = footerTopImg;
    currentYear;

    //Custom Labels
    label = {
        about,
        acknowledge,
        downloadApple,
        downloadAnroid,
        fujitsu,
        reg,
        volunteer
    }

    connectedCallback(){
        var today = new Date();
        // Return the date in "YYYY" format
         this.currentYear = today.getFullYear();
        }
}