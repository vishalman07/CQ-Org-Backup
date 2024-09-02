import { LightningElement } from 'lwc';
import g2gCrate from '@salesforce/apex/CsvUploadController.good2giveCreate';
import ppCreate from '@salesforce/apex/CsvUploadController.paypalCreate';
import jobList from '@salesforce/apex/CsvUploadController.updateCsvLog';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class CsvDonationHandler extends NavigationMixin( LightningElement ){
    columns = [];
    data = [];
    type = '';
    g2gMapColumn = false;
    ppffMapColumn = false;
    isLoaded = false;
    showRecordDetails;
    staticColumnForG2g = [
        {
            label: 'Payout Date', value: '', key: 'payout_Date'
        },
        {
            label: 'Donation Date', value: '', key: 'donation_Date'
        },
        {
            label: 'Good2Give Donor Id', value: '', key: 'good2Give_Donor_Id'
        },
        {
            label: 'Donor Firstname', value: '', key: 'donor_Firstname'
        },
        {
            label: 'Donor Lastname', value: '', key: 'donor_Lastname'
        },
        {
            label: 'Donor Email', value: '', key: 'donor_Email'
        },
        {
            label: 'Employer Name', value: '', key: 'employer_Name'
        },
        {
            label: 'Donation Type', value: '', key: 'donation_Type'
        },
        {
            label: 'Charity Project', value: '', key: 'charity_Project'
        },
        {
            label: 'Donor Reference', value: '', key: 'donor_Reference'
        },
        {
            label: 'Donation Confirmation Number', value: '', key: 'donation_Confirmation_Number'
        },
        
        {
            label: 'Donation Amount', value: '', key: 'donation_Amount'
        },
    ];
    staticColumnForPpff = [
        {
            label: 'Payout Date', value: '', key: 'payout_Date'
        },
        {
            label: 'Donation Date', value: '', key: 'donation_Date'
        },
        {
            label: 'Donor First Name', value: '', key: 'donor_First_Name'
        },
        {
            label: 'Donor Last Name', value: '', key: 'donor_Last_Name'
        },
        {
            label: 'Donor Email', value: '', key: 'donor_Email'
        },
        {
            label: 'Program Name', value: '', key: 'program_Name'
        },
        {
            label: 'Reference Information', value: '', key: 'reference_Information'
        },
        {
            label: 'Currency Code', value: '', key: 'currency_Code'
        },
        {
            label: 'Gross Amount', value: '', key: 'gross_Amount'
        },
        {
            label: 'Total Fees', value: '', key: 'total_Fees'
        },
        {
            label: 'Net Amount', value: '', key: 'net_Amount'
        },
        {
            label: 'Transaction ID', value: '', key: 'transaction_ID'
        },
        {
            label: 'Gateway Payout ID', value: '', key: 'gateway_Payout_ID'
        },

    ];
    get options() {
        return [
            { label: 'Good2Give', value: 'g2g' },
            { label: 'Paypal Giving Fund', value: 'ppff' },
        ];
    }
    jobList;
    connectedCallback() {
        jobList()
        .then(result => {
            console.log('result : '+JSON.stringify(result));
            this.jobList = result;
        })
        console.log(this.jobList);
    }
    handleClick(event) {
        let files = this.template.querySelector('input[name=fileupload]').files;
        //console.log("#### files = "+JSON.stringify(files));
        if (files.length > 0) {
            const file = files[0];
            // start reading the uploaded csv file
            this.read(file);
        }
    }
    get acceptedFormats() {
        return ['.csv'];
    }
    handleChange(event) {
        this.type = event.target.value;
        if (this.type == 'g2g') {
            this.g2gMapColumn = true;
            this.ppffMapColumn = false;
        }
        else if (this.type == 'ppff') {
            this.ppffMapColumn = true;
            this.g2gMapColumn = false;
        }

    }
    fileUploadHandler(event) {
        if (this.type == 'g2g') {
            this.g2gMapColumn = true;
            this.ppffMapColumn = false;
            let files = this.template.querySelector('input[name=fileupload]').files;
            //console.log("#### files = "+JSON.stringify(files));
            if (files.length > 0) {
                const file = files[0];
                // start reading the uploaded csv file
                this.readheader(file);
            }
        }
        else if (this.type == 'ppff') {
            this.ppffMapColumn = true;
            this.g2gMapColumn = false;
            let files = this.template.querySelector('input[name=fileupload]').files;
            //console.log("#### files = "+JSON.stringify(files));
            if (files.length > 0) {
                const file = files[0];
                // start reading the uploaded csv file
                this.readheader(file);
            }
        }

    }
    handleMappingChange(event) {
        console.log(event.target.value);
        if (this.type == 'g2g') {
            this.staticColumnForG2g.forEach(item => {
                if (item.label === event.target.label) {
                    item.value = event.target.value;
                }
            });
        }
        else if (this.type == 'ppff') {
            this.staticColumnForPpff.forEach(item1 => {
                if (item1.label === event.target.label) {
                    item1.value = event.target.value;
                }
            });
        }
    }


    async readheader(file) {
        try {
            const result = await this.loadheader(file);
            console.log("#### result line 182 = "+JSON.stringify(result));
            // execute the logic for parsing the uploaded csv file
            this.parseCSVheader(result);
        } catch (e) {
            this.error = e;
        }
    }

    async loadheader(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            reader.onload = () => {
                //console.log("#### reader.result = "+JSON.stringify(reader.result));
                resolve(reader.result);
            };
            reader.onerror = () => {
                //console.log("#### reader.error = "+JSON.stringify(reader.error));
                reject(reader.error);
            };
            //console.log("#### file = "+JSON.stringify(file));
            reader.readAsText(file);
        });
    }

    parseCSVheader(csv) {
        // parse the csv file and treat each line as one item of an array
        const lines = csv.split(/\r\n|\n/);
        // parse the first line containing the csv column headers
        let headers = [];
        if (this.type == 'g2g') {
            headers = lines[2].split(',');
            headers = headers.map(item => item.replace(/"/g, ''));
        }
        else if (this.type == 'ppff') {
            headers = lines[0].split(',');
            headers = headers.map(item => item.replace(/"/g, ''));
        }
        console.log("#### headers = " + JSON.stringify(headers));
        // iterate through csv headers and transform them to column format supported by the datatable
        this.columns = headers.map((header) => {
            return { label: header, value: header };
        });
        if (this.type == 'g2g') {
            this.columns.forEach(currentItem => {
                this.staticColumnForG2g.forEach(item1 => {
                    if (item1.label === currentItem.label) {
                        item1.value = currentItem.label;
                    }
                })
            });
        }
        else if (this.type == 'ppff') {
            this.columns.forEach(currentItem => {
                this.staticColumnForPpff.forEach(item2 => {
                    if (item2.label === currentItem.label) {
                        item2.value = currentItem.label;
                    }
                });
            });
        }
    }
    async read(file) {
        try {
            const result = await this.load(file);
            //console.log("#### result = "+JSON.stringify(result));
            // execute the logic for parsing the uploaded csv file
            this.parseCSV(result);
        } catch (e) {
            this.error = e;
        }
    }
    async load(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();

            reader.onload = () => {
                //console.log("#### reader.result = "+JSON.stringify(reader.result));
                resolve(reader.result);
            };
            reader.onerror = () => {
                //console.log("#### reader.error = "+JSON.stringify(reader.error));
                reject(reader.error);
            };
            //console.log("#### file = "+JSON.stringify(file));
            reader.readAsText(file);
        });
    }
    parseCSV(csv) {
        // parse the csv file and treat each line as one item of an array
        const lines = csv.split(/\r\n|\n/);
        // parse the first line containing the csv column headers
        let headers = [];
        if (this.type == 'g2g') {
            headers = lines[2].split(',');
            headers = headers.map(item => item.replace(/"/g, ''));
        }
        else if (this.type == 'ppff') {
            headers = lines[0].split(',');
            headers = headers.map(item => item.replace(/"/g, ''));
        }
        console.log("#### headers = " + JSON.stringify(headers));
        //console.log("#### this.columns = "+JSON.stringify(this.columns));
        const conList = [];
        if (this.type == 'g2g') {
            this.columns.forEach(currentItem => {
                this.staticColumnForG2g.forEach(item => {
                    if (item.value === currentItem.label) {
                        conList.push(item.key);
                    }
                });
            });
        }
        else if (this.type == 'ppff') {
            this.columns.forEach(currentItem => {
                this.staticColumnForPpff.forEach(item => {
                    if (item.value === currentItem.label) {
                        conList.push(item.key);
                    }
                });
            });
        }
        // iterate through csv file rows and transform them to format supported by the datatable

        lines.forEach((line, i) => {
            console.log('lenth : ' + lines.length)
            if (this.type == 'g2g' && (i <= 2 || i > lines.length - 5)) {
                return;
            }
            else if (this.type == 'ppff' && i === 0) {
                return;
            }
            if (i < lines.length - 1) {
                const obj = {};
                let currentline = line.split(',');
               currentline = currentline.map(item => item.replace(/"/g, ''));
                const modifiedCurrentline = [];
                let temp = '';
                for (let j = 0; j < currentline.length; j++) {
                    if (currentline[j].startsWith('"')) {
                        temp += currentline[j];
                    } else if (temp) {
                        temp += ',' + currentline[j];
                        modifiedCurrentline.push(temp);
                        temp = '';
                    } else {
                        modifiedCurrentline.push(currentline[j]);
                    }
                }
                for (let j = 0; j < headers.length; j++) {
                    obj[conList[j]] = modifiedCurrentline[j];
                }
                console.log(obj);
                this.data.push(obj);
            }
        });
        console.log(JSON.stringify(this.data));
        this.data = JSON.stringify(this.data);
        if (this.type == 'g2g') {
            this.isLoaded = true;
            g2gCrate({ jsonStr: this.data })
                .then(result => {
                    this.isLoaded = false;
                    this.showSuccessToast();
                    this.g2gMapColumn = false;
                    console.log(result);
                    this.updateRecordView();
                })
                .catch(error => {
                    this.isLoaded = false;
                    this.showErrorToast();
                    this.g2gMapColumn = false;
                    console.log(JSON.stringify(error));
                    this.updateRecordView();
                })
        }
        else if (this.type == 'ppff') {
            this.isLoaded = true;
            ppCreate({ jsonStr: this.data })
                .then(result => {
                    this.isLoaded = false;
                    this.showSuccessToast();
                    this.ppffMapColumn = false;
                    console.log(result);
                    this.updateRecordView();
                })
                .catch(error => {
                    this.isLoaded = false;
                    this.showErrorToast();
                    this.ppffMapColumn = false;
                    console.log(JSON.stringify(error));
                    this.updateRecordView();
                })
        }
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Create record sucessful',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'error',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 5000); 
     }
    showLogDetails(event){
        const recordId = event.currentTarget.dataset.index;;
        console.log(recordId);
        this.jobList.forEach( item =>{
            if(item.jobId === recordId){
                this.showRecordDetails = [item];
            }
        })
        console.log(JSON.stringify(this.showRecordDetails));
    }
    cancelShowdetails(){
        this.showRecordDetails = null;
    }
}