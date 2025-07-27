@isTest
private class MSP_TerminationDtoTest {
    @IsTest
    static void testMSPTerminationDto() {
        // Create an instance of MSP_TerminationDto
        MSP_TerminationDto dto = new MSP_TerminationDto();
        
        // Set properties
        dto.createFinalBill = true;
        dto.entityId = '001xx000003DGbP';
        dto.entityType = 'HOUSEHOLD';
        dto.liquidateModelHoldings = false;
        
        // Assert that the properties are set correctly
        System.assert(dto.createFinalBill == true, 'createFinalBill should be true');
        System.assertEquals('001xx000003DGbP', dto.entityId, 'entityId should be 001xx000003DGbP');
        System.assertEquals('HOUSEHOLD', dto.entityType, 'entityType should be HOUSEHOLD');
        System.assert(dto.liquidateModelHoldings == false, 'liquidateModelHoldings should be false');
    }
}