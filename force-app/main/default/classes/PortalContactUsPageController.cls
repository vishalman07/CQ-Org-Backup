/**
 * Created by prakruti on 3/1/19.
 */

public class PortalContactUsPageController {

    public String contactType {get;set;}
    public String property {get;set;}

    public PortalContactUsPageController(){
        String ct = ApexPages.currentPage().getParameters().get('ct');
        String pid = ApexPages.currentPage().getParameters().get('pid');

        if(ct != null){
            contactType = 'Respite_Case';
        }else{
            contactType = 'Family_Request';
        }

        if(pid != null){
            property = pid;
        }
    }

}