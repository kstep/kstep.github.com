describe 'Directives', ->
    beforeEach ->
        module 'kstep'

    describe 'totop', ->
        element = undefined
        scope = undefined

        beforeEach inject ($compile, $rootScope) ->
            scope = $rootScope.$new()
            element = $compile('<totop></totop>') scope

        it 'should scroll to top on click', inject ($window) ->
            # TODO: fake onclick and test scrollTop position
            expect(true).toBeTruthy()

