global class DataMigrationBatch implements Database.Batchable<SObject> {

    private Boolean isRDProcessing = true;
    private Integer limitVar;
    private String additionalCondition;

    public DataMigrationBatch() {
        this(true);
    }
    public DataMigrationBatch(Boolean isRDProcessing) {
        this.isRDProcessing = isRDProcessing;
    }

    public DataMigrationBatch(Boolean isRDProcessing, Integer limitVar) {
        this(isRDProcessing);
        this.limitVar = limitVar;
    }

    public DataMigrationBatch(Boolean isRDProcessing, Integer limitVar, String additionalCondition) {
        this(isRDProcessing, limitVar);
        this.additionalCondition = additionalCondition;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('');
           
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {

    }

    global void finish(Database.BatchableContext BC) {
    }

}