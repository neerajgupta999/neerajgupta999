@isTest
public class RestRouteTests {
    private static final String RESOURCE_URL = '/api/*';
    private static final String RESOURCE_PATH = '/services/apexrest' + RESOURCE_URL;

    @isTest
    public static void testEntryRoute() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(400, resp.statusCode, 'Incorrect path should throw 400');
    }

    @isTest
    public static void testEntryRouteCollections() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(400, resp.statusCode, 'Incorrect path should throw 400');
    }

    @isTest
    public static void testBaseRouteCollection() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode);
        RestRouteTestRoutes.Company[] respData = (RestRouteTestRoutes.Company[]) JSON.deserialize(
            resp.responseBody.toString(),
            List<RestRouteTestRoutes.Company>.class
        );

        System.assertEquals(2, respData.size(), '2 Companies records are expected');
    }

    @isTest
    public static void testNoResourceRoute() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/other/foo');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode);

        System.assertEquals('foo', resp.responseBody.toString(), 'response expected as foo');
    }

    @isTest
    public static void testBaseRouteCollection2() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode);
        RestRouteTestRoutes.Company[] respData = (RestRouteTestRoutes.Company[]) JSON.deserialize(
            resp.responseBody.toString(),
            List<RestRouteTestRoutes.Company>.class
        );

        System.assertEquals(2, respData.size(), '2 Companies records should be returned');
    }

    @isTest
    public static void testOperationNotSupportedPOST() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies', 'POST', null, Blob.valueOf('Hello'));
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(400, resp.statusCode, 'POST Method not supported');
    }

    @isTest
    public static void testOperationNotSupportedPUT() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies', 'PUT', null, Blob.valueOf('Hello'));
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(400, resp.statusCode, 'PUT Method not supported');
    }
    @isTest
    public static void testOperationNotSupportedDELETE() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2', 'Delete', null, null);
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(404, resp.statusCode, 'DELETE Method not supported');
    }
    @isTest
    public static void testBaseRouteSingle() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-1');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode);
        RestRouteTestRoutes.Company respData = (RestRouteTestRoutes.Company) JSON.deserialize(
            resp.responseBody.toString(),
            RestRouteTestRoutes.Company.class
        );

        System.assertEquals('c-1', respData.id, ' Resource id should be c-1 as per URI');
    }

    @isTest
    public static void testSingleExpanded() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-1', new Map<String, String>{ 'expand' => '1' });
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode, ' Response should be success');

        // TODO make useful assertions
        // System.assertEquals('', resp.responseBody.toString());
    }

    @isTest
    public static void testCollectionExpanded() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies', new Map<String, String>{ 'expand' => '1' });
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode, 'all companies with locations should be returned');

        // TODO make useful assertions
        // System.assertEquals('', resp.responseBody.toString());
    }

    @isTest
    public static void testNestedRouteCollection() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2/locations');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode);
        RestRouteTestRoutes.CompanyLocation[] respData = (RestRouteTestRoutes.CompanyLocation[]) JSON.deserialize(
            resp.responseBody.toString(),
            List<RestRouteTestRoutes.CompanyLocation>.class
        );

        System.assertEquals(1, respData.size(), '1 location is expected in response.');
        System.assertEquals('LA', respData[0].name, ' locaiton name should be LA');
    }

    @isTest
    public static void testAlternateRoute() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/employees', new Map<String, String>{ 'companyId' => 'c-2' });
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode);
        RestRouteTestRoutes.CompanyEmployee[] respData = (RestRouteTestRoutes.CompanyEmployee[]) JSON.deserialize(
            resp.responseBody.toString(),
            List<RestRouteTestRoutes.CompanyEmployee>.class
        );

        System.assertEquals(3, respData.size(), '3 records should be returned.');
        System.assertEquals('Iron Man', respData[0].name , 'First test result should be Iron Man');
    }

    @isTest
    public static void testRouteCollectionFilter() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2/employees', new Map<String, String>{ 'role' => 'CEO' });
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode);
        RestRouteTestRoutes.CompanyEmployee[] respData = (RestRouteTestRoutes.CompanyEmployee[]) JSON.deserialize(
            resp.responseBody.toString(),
            List<RestRouteTestRoutes.CompanyEmployee>.class
        );

        System.assertEquals(2, respData.size(), ' 2 records with Role as CEO should be returned.');
        System.assertEquals('Iron Man', respData[0].name, 'Iron Man is the first employee in collection with role as CEO.');
    }

    @isTest
    public static void testNestedRouteSingle() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-1/employees/e-2');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(200, resp.statusCode);
        RestRouteTestRoutes.CompanyEmployee respData = (RestRouteTestRoutes.CompanyEmployee) JSON.deserialize(
            resp.responseBody.toString(),
            RestRouteTestRoutes.CompanyEmployee.class
        );

        System.assertEquals('e-2', respData.id, ' Resource id from URI should be e-2');
    }

    @isTest
    public static void testNestedRouteSingleNotRelated() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2/employees/e-2');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(404, resp.statusCode);
        RestRouteError.Response[] respData = RestRouteTestUtil.parseResponseErrors(resp);

        System.assertEquals(1, respData.size(), 'exact one record is expected.');
        System.assertEquals('NOT_FOUND', respData[0].errorCode, 'Not Found exception');
    }

    @isTest
    public static void testNoRouteFound() {
        RestRouteTestUtil.setupRestContext(RESOURCE_PATH, '/api/v1/companies/c-2/asdf');
        RestResponse resp = RestContext.Response;

        RestRouteTestRoutes.APIEntryRoute router = new RestRouteTestRoutes.APIEntryRoute();
        router.execute();

        System.assertEquals(404, resp.statusCode);
        RestRouteError.Response[] respData = RestRouteTestUtil.parseResponseErrors(resp);

        System.assertEquals(1, respData.size(), ' 1 response record expected');
        System.assertEquals('NOT_FOUND', respData[0].errorCode, 'Incorrect URI should result into not found resoruce');
    }
}