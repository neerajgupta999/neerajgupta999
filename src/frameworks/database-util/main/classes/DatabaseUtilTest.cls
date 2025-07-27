@isTest(isParallel=true)
private class DatabaseUtilTest {
    private static Integer STORE_NUMBER = 1;

    @isTest static void testUpdateSObjectAllowPartial(){
        
        Branch_Location__c aBranch1 = createBranchLocationSObject('America/Los_Angeles');
        Branch_Location__c aBranch2 = createBranchLocationSObject('America/New_York');

        List<Branch_Location__c> lstBranch = new List<Branch_Location__c>();
        List<Branch_Location__c> lstBranchToUpdate = new List<Branch_Location__c>();
        lstBranch.add(aBranch1);
        lstBranch.add(aBranch2);

        DatabaseUtil.insertSObjectDoNotAllowPartial(lstBranch);    

        for(Branch_Location__c aBranch: lstBranch){
            if(aBranch.Timezone_IANA__c.equals('America/Los_Angeles')){
                aBranch.Timezone_IANA__c = 'What is time really?';
            }
            if(aBranch.Timezone_IANA__c.equals('America/New_York')){
                aBranch.Timezone_IANA__c = 'America/Los_Angeles';
            }
            lstBranchToUpdate.add(aBranch);
        }

        Test.startTest();
        DatabaseUtil.updateSObjectAllowPartial(lstBranchToUpdate);
        Test.stopTest();

        lstBranch = [SELECT Id, Timezone_IANA__c FROM Branch_Location__c];
        List<Error_Log__c> lstErrorLog = [SELECT Id FROM Error_Log__c];
        
        System.assertEquals(2, lstBranch.size(), 'Two locations should be present');
        for(Branch_Location__c aBranch: lstBranch){
            System.assertEquals('America/Los_Angeles', aBranch.Timezone_IANA__c, 'Location should have Pacific Timezone');
        }
        System.assertEquals(1, lstErrorLog.size(), 'One error log should be present');
    }

    @isTest static void testUpdateSObjectDoNotAllowPartial(){
        Branch_Location__c aBranch1 = createBranchLocationSObject('America/Chicago');
        Branch_Location__c aBranch2 = createBranchLocationSObject('America/Chicago');

        List<Branch_Location__c> lstBranch = new List<Branch_Location__c>();
        List<Branch_Location__c> lstBranchToUpdate = new List<Branch_Location__c>();
        lstBranch.add(aBranch1);
        lstBranch.add(aBranch2);

        DatabaseUtil.insertSObjectDoNotAllowPartial(lstBranch);    
        
        Integer iCount = 0;
        for(Branch_Location__c aBranch: lstBranch){
            if(iCount == 0){
                aBranch.Timezone_IANA__c = 'What is time really?';
            }
            if(iCount == 1){
                aBranch.Timezone_IANA__c = 'America/Los_Angeles';
            }
            lstBranchToUpdate.add(aBranch);
        }

        Test.startTest();
        try{
            DatabaseUtil.updateSObjectDoNotAllowPartial(lstBranchToUpdate);
        }catch(Exception e){
            System.debug('Fail Silently and catch an exception');
        }
        Test.stopTest();

        lstBranch = [SELECT Id, Timezone_IANA__c FROM Branch_Location__c];
        
        System.assertEquals(2, lstBranch.size(), 'Two locations should be present');
        for(Branch_Location__c aBranch: lstBranch){
            System.assertEquals('America/Chicago', aBranch.Timezone_IANA__c, 'Location should have Central Timezone');
        }    
    }

    @isTest static void testUpsertSObjectAllowPartial(){
        
        Branch_Location__c aBranch1 = createBranchLocationSObject('America/Los_Angeles');
        Branch_Location__c aBranch2 = createBranchLocationSObject('America/New_York');

        List<Branch_Location__c> lstBranch = new List<Branch_Location__c>();
        List<Branch_Location__c> lstBranchToUpdate = new List<Branch_Location__c>();
        lstBranch.add(aBranch1);
        lstBranch.add(aBranch2);

        //DatabaseUtil.insertSObjectDoNotAllowPartial(lstBranch);    

        for(Branch_Location__c aBranch: lstBranch){
            if(aBranch.Timezone_IANA__c.equals('America/Los_Angeles')){
                aBranch.Timezone_IANA__c = 'What is time really?';
            }
            if(aBranch.Timezone_IANA__c.equals('America/New_York')){
                aBranch.Timezone_IANA__c = 'America/Los_Angeles';
            }
            lstBranchToUpdate.add(aBranch);
        }

        Test.startTest();
        DatabaseUtil.upsertSObjectAllowPartial(lstBranchToUpdate);
        Test.stopTest();

        lstBranch = [SELECT Id, Timezone_IANA__c FROM Branch_Location__c];
        List<Error_Log__c> lstErrorLog = [SELECT Id FROM Error_Log__c];
        
        Assert.areEqual(1, lstBranch.size(), 'One locations should be present');
        for(Branch_Location__c aBranch: lstBranch){
            Assert.areEqual('America/Los_Angeles', aBranch.Timezone_IANA__c, 'Location should have Pacific Timezone');
        }
        Assert.areEqual(1, lstErrorLog.size(), 'One error log should be present');
    }

    @isTest static void testUpsertSObjectDoNotAllowPartial(){
        Branch_Location__c aBranch1 = createBranchLocationSObject('America/Chicago');
        Branch_Location__c aBranch2 = createBranchLocationSObject('America/Chicago');

        List<Branch_Location__c> lstBranch = new List<Branch_Location__c>();
        List<Branch_Location__c> lstBranchToUpdate = new List<Branch_Location__c>();
        lstBranch.add(aBranch1);
        lstBranch.add(aBranch2);

        //DatabaseUtil.insertSObjectDoNotAllowPartial(lstBranch);    
        
        Integer iCount = 0;
        for(Branch_Location__c aBranch: lstBranch){
            if(iCount == 0){
                aBranch.Timezone_IANA__c = 'What is time really?';
            }
            if(iCount == 1){
                aBranch.Timezone_IANA__c = 'America/Los_Angeles';
            }
            lstBranchToUpdate.add(aBranch);
        }

        Test.startTest();
        try{
            DatabaseUtil.upsertSObjectDoNotAllowPartial(lstBranchToUpdate);
        }catch(Exception e){
            System.debug('Fail Silently and catch an exception');
        }
        Test.stopTest();

        lstBranch = [SELECT Id, Timezone_IANA__c FROM Branch_Location__c];
        
        Assert.areEqual(0, lstBranch.size(), 'Two locations should be present');
        for(Branch_Location__c aBranch: lstBranch){
            Assert.areEqual('America/Chicago', aBranch.Timezone_IANA__c, 'Location should have Central Timezone');
        }    
    }

    @isTest static void testInsertSObjectAllowPartial(){

        Branch_Location__c aBranch1 = createBranchLocationSObject('America/Los_Angeles');
        Branch_Location__c aBranch2 = createBranchLocationSObject('What is Time Really?');

        List<Branch_Location__c> lstBranch = new List<Branch_Location__c>();
        lstBranch.add(aBranch1);
        lstBranch.add(aBranch2);

        Test.startTest();
        DatabaseUtil.insertSObjectAllowPartial(lstBranch);
        Test.stopTest();

        lstBranch = [SELECT Id FROM Branch_Location__c];
        List<Error_Log__c> lstErrorLog = [SELECT Id FROM Error_Log__c];

        System.assertEquals(1, lstBranch.size(), 'Only one branch location should be inserted');
        System.assertEquals(1, lstErrorLog.size(), 'One error log should be present');
    }

    @isTest static void testInsertSObjectDoNotAllowPartial(){
        Branch_Location__c aBranch1 = createBranchLocationSObject('America/Los_Angeles');
        Branch_Location__c aBranch2 = createBranchLocationSObject('What is Time Really?');

        List<Branch_Location__c> lstBranch = new List<Branch_Location__c>();
        lstBranch.add(aBranch1);
        lstBranch.add(aBranch2);

        Test.startTest();
        try{            
            DatabaseUtil.insertSObjectDoNotAllowPartial(lstBranch);            
        }catch(Exception e){
            System.debug('Fail Silently and catch an exception');
        }

        Test.stopTest();
        lstBranch = [SELECT Id FROM Branch_Location__c];

        System.assertEquals(0, lstBranch.size(), 'No branch location should be inserted');
    }


    @isTest static void testDeleteSObjectDoNotAllowPartial(){
        
        Branch_Location__c aBranch1 = createBranchLocationSObject('America/Los_Angeles');
        Branch_Location__c aBranch2 = createBranchLocationSObject('America/New_York');

        List<Branch_Location__c> lstBranch = new List<Branch_Location__c>();
        List<Branch_Location__c> lstBranchToDelete = new List<Branch_Location__c>();
        lstBranch.add(aBranch1);
        lstBranch.add(aBranch2);
        DatabaseUtil.insertSObjectDoNotAllowPartial(lstBranch);    

        Test.startTest();
        DatabaseUtil.deleteSObjectDoNotAllowPartial(lstBranch);    
        Test.stopTest();
        lstBranch = [SELECT Id FROM Branch_Location__c];
        System.assertEquals(0, lstBranch.size(), 'All branch locations should be deleted.');
    }

    @isTest static void testDeleteSObjectAllowPartial(){
        
        Branch_Location__c aBranch1 = createBranchLocationSObject('America/Los_Angeles');
        Branch_Location__c aBranch2 = createBranchLocationSObject('America/New_York');

        List<Branch_Location__c> lstBranch = new List<Branch_Location__c>();
        List<Branch_Location__c> lstBranchToDelete = new List<Branch_Location__c>();
        lstBranch.add(aBranch1);
        lstBranch.add(aBranch2);
        DatabaseUtil.insertSObjectDoNotAllowPartial(lstBranch);    

        Test.startTest();
        DatabaseUtil.deleteSObjectAllowPartial(lstBranch);    
        Test.stopTest();
        lstBranch = [SELECT Id FROM Branch_Location__c];
        System.assertEquals(0, lstBranch.size(), 'All branch locations should be deleted.');
    }

    private static Branch_Location__c createBranchLocationSObject(String strTimezone){

        Branch_Location__c aBranch = new Branch_Location__c();
        aBranch.Appointment_Type_Id__c = 't3_sanfrancisco_santaclara';
        aBranch.Name = 'CA - San Francisco IV (Santa Clara)';
        aBranch.Display_Location_Name__c = 'CA - San Francisco I (Santa Clara)';
        aBranch.CRM_Location_Name__c = 'San Francisco IV - Santa Clara';
        aBranch.Store_Number__c = STORE_NUMBER;
        aBranch.Active__c = true;
        aBranch.Timezone_IANA__c = strTimezone;
        STORE_NUMBER ++;

        return aBranch;
    }

}