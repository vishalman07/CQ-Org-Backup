public class VolunteerEventBanner {
    
    public static HttpResponse makeGetCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://highcountryonline.com.au/wp-content/uploads/2016/08/HCO.-Baw-Baw.6.jpg');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        Http binding = new Http();
		HttpResponse imgres = binding.send(request);

// converting response as a blob
		String image;
        Blob imageblob = imgres.getBodyAsBlob();
        image = EncodingUtil.Base64Encode(imageblob);
        System.debug(image);
        /*if(response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('results->'+ blob.valueOf(response.getBody()));
        }*/
        return response;
        
    }



}