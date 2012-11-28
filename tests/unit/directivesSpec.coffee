describe 'Directives', ->
    beforeEach ->
        module 'kstep'

    describe 'totop', ->
        element = undefined
        scope = undefined

        beforeEach inject ($compile, $rootScope) ->
            scope = $rootScope.$new()
            element = $compile('<totop></totop>')(scope)

        it 'should scroll to top on click', inject ($window) ->
            # TODO: fake onclick and test scrollTop position
            expect(true).toBeTruthy()

    describe 'ngMeta', ->
        scope = undefined

        beforeEach inject ($rootScope) ->
            scope = $rootScope.$new()

        it 'should set scope variable', inject ($compile) ->
            element = $compile('<ng-meta name="var" value="\'value\'" />')(scope)

            expect(scope.var).toEqual 'value'

        it 'should update objects in scope', inject ($compile) ->
            scope.var = {}
            element = $compile('<ng-meta name="var" update="{prop: 1024}" />')(scope)

            expect(scope.var.prop).toEqual 1024

