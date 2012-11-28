describe 'Filters', ->
    beforeEach -> module 'kstep'

    describe 'strip_tags', ->

        strip_tags = undefined

        beforeEach inject ($filter) ->
            strip_tags = $filter 'strip_tags'

        it 'should remove all tags from a string', ->
            string = '<p><b>bold text</b><br /><a href="#">&</a><span class="red label" onclick="alert(\'clicked!\')">spanned text</span></p><hr/>'
            expect(strip_tags string).toBe 'bold text&spanned text'

    describe 'rot13', ->
        rot13 = undefined
        string = 'Hello, world!'
        rstring = 'Uryyb, jbeyq!'

        beforeEach inject ($filter) ->
            rot13 = $filter 'rot13'

        it 'should return rotated string', ->
            expect(rot13 string).toBe rstring

        it 'should be reversable', ->
            expect(rot13 rot13 string).toBe string

    describe 'asdate', ->
        asdate = undefined
        date = undefined
        now = new Date

        beforeEach inject ($filter) ->
            asdate = $filter 'asdate'
            date = $filter 'date'

        it 'should be identical to date', ->
            expect(asdate now).toBe date now

        it 'should convert string to date', ->
            expect(asdate now.toString()).toBe date now

        it 'should convert timestamp to date', ->
            expect(asdate now.getTime()).toBe date now

    describe 'upper and lower', ->
        upper = undefined
        lower = undefined

        beforeEach inject ($filter) ->
            upper = $filter 'upper'
            lower = $filter 'lower'

        it 'should convert string to upper or lower case', ->
            expect(upper 'AbC').toBe 'ABC'
            expect(lower 'AbC').toBe 'abc'

