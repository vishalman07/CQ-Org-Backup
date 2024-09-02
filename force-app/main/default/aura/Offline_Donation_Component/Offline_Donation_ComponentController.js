({         
	doInit : function(component, event, helper) {
        
        var DEFAULT_PAYMENT_FORM = '12. Offline Direct Debit Donations';
        
        var inputsel = component.find("selPayForm");
        var opts=[]; 
        
        /* Getting the Payment Forms */
        var actionPayForms = component.get("c.getPaymentForms"); 
        actionPayForms.setCallback(this, function(response) {
            if( response.getState() == 'SUCCESS' ) {                   
                component.set("v.paymentForms", response.getReturnValue());
                
                opts.push({"class": "optionClass", label: '', value: ''});
                for(var i=0; i<response.getReturnValue().length; i++) {
                    opts.push({"class": "optionClass", label: response.getReturnValue()[i].payTypeName, value: response.getReturnValue()[i].payTypeId});
                    
                    // setting the default form Value
                    if ( response.getReturnValue()[i].payTypeName == DEFAULT_PAYMENT_FORM ) {
                        component.set("v.paymentTypeId", response.getReturnValue()[i].payTypeId)
                    }
                }                                
                inputsel.set("v.options", opts);                
            }
        });
        $A.enqueueAction(actionPayForms);        
    },
    
    handleSearchRecords : function (component, event, helper) {
        var searchText = component.find("searchinput").get("v.value");
        if(searchText) {
            helper.searchRecord(component, searchText);
        } else {
            //helper.searchRecord(component, '');
        }
    },
     
    handleLookupSelectEvent : function (component, event, helper) {
        var selectedRecordId = event.getParam("recordId");
        var selectedrecordName = event.getParam("recordName");
        component.set("v.selectedRecordId", selectedRecordId);
        component.set("v.selectedRecordName", selectedrecordName);
        helper.toggleLookupList(component, false, 'slds-combobox-lookup', 'slds-is-open');
    },
     
    hideList :function (component,event,helper) {
        window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    helper.toggleLookupList(component, false, 'slds-combobox-lookup','slds-is-open');
                }
            }), 200
        );
    },
    
    next : function(component, event, helper) { 
        
        component.set("v.showErrorCampaign", false);   
        component.set("v.showErrorPayForm", false);   
        
        var campaignName = component.get("v.selectedRecordName"); 
        var payMType = component.get("v.paymentTypeId");  
        
        var idPrefix = component.get("v.recordId").substring(0,3);
        
        var isError = false;
        if ( typeof campaignName === 'undefined' || campaignName == '' ) {
            isError = true;
            component.set("v.showErrorCampaign", true);   
        }
        if ( payMType == '' ) {   
			isError = true;            
            component.set("v.showErrorPayForm", true);                    	
        }
        
        if (!isError) {                   
            // getting the Campaign ID
            var camId;
            for(var i=0; i<component.get("v.matchingRecords").length; i++) {                
                if ( component.get("v.matchingRecords")[i].Name == campaignName ) {
                    camId = component.get("v.matchingRecords")[i].Id;
                    break;
                }
            }                  
            
            // getting the Payment Setting ID
            var payMSetting;
            for(var i=0; i<component.get("v.paymentForms").length; i++) {                
                if ( component.get("v.paymentForms")[i].payTypeId == payMType ) {
                    payMSetting = component.get("v.paymentForms")[i].paySettingId;
                    break;
                }
            }     
            
            var url = "/apex/AAkPay__checkoutM?payMSetting="+payMSetting+"&payMType="+payMType+"&camId="+camId+"";
            console.log('***1 url = ' + url);
                                   
            // account reocrd
            if ( idPrefix == '001' ) {
                url += "&aid="+component.get("v.recordId")+"";
                
            // contact record
            } else if ( idPrefix == '003' ) {
                url += "&cid="+component.get("v.recordId")+"";
            }
            
            console.log('***2 url = ' + url);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url": url, "isredirect": "true" });
            urlEvent.fire();   
        }
	}
    
})