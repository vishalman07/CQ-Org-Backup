@RestResource(urlMapping='/stripeWebhook/*')
global with sharing class  StripeWebhookCls {
	@HttpPost
    global static String handlePost(String payload) {
        try {
            // Process the payload
            System.debug('Received Payload: ' + payload);
            // Add your processing logic here
            
            return 'Success';
        } catch (Exception e) {
            // Handle exceptions and log errors
            System.debug('Error: ' + e.getMessage());
            return 'Error';
        }
    }
}