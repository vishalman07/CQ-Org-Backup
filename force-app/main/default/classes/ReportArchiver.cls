public class ReportArchiver {
    public static void archiveOldReports() {
        // Get the Id of the archive folder
        Id archiveFolderId = [SELECT Id FROM Folder WHERE Name = 'Archive' AND Type = 'Report' LIMIT 1].Id;

        // Get reports that have not been run in the last 12 months
        List<Report> reportsToArchive = [SELECT Id, Name FROM Report WHERE LastRunDate = NULL OR LastRunDate < LAST_N_DAYS:365];

        // Update the FolderId of these reports to the archive folder Id
        for (Report report : reportsToArchive) {
            report.Id = archiveFolderId;
            reportsToArchive.add(report);
        }

        // Perform the update
        //update reportsToArchive;
       system.debug('reportsToArchive'+reportsToArchive);
    }

}