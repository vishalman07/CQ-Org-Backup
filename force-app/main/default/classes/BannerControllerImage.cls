public class BannerControllerImage {
    @RemoteAction
    public static void setImageData(String base64ImageData) {
        // Process the base64-encoded image data in the controller as needed
        System.debug('Received base64-encoded image data: ' + base64ImageData);
    }
}