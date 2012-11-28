
describe 'RootCtl', ->

    scope = undefined
    controller = undefined
    beforeEach inject ($rootScope, $controller) ->
        scope = $rootScope.$new()
        controller = $controller('RootCtl', { '$scope': scope })
        scope.$apply()

    it 'should initialize social account list', ->
        expect(typeof scope.social_accounts).toBe 'Object'
        expect(scope.social_accounts[0]).toBeDefined()

    it 'should initialize page object', ->
        expect(typeof scope.page).toBe 'Object'

    it 'should setup locale', inject ($httpBackend) ->
        $httpBackend.whenGET('/i18n/en.json').respond 200, '{"title": "Test"}', {'Content-type': 'application/json'}
        #$httpBackend.flush()

        expect(scope.locale).toBeDefined()
        expect(scope.locale.title).toBe "Test"
        expect(scope.locale.lang).toBe "en"

