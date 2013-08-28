describe 'Helper: valueFn', ->
    beforeEach -> module 'kstep'
    it 'should create function, which returns given value', ->
        testval = 'XXX'
        expect(valueFn(testval)()).toBe testval

describe 'Helper: attr', ->
    beforeEach -> module 'kstep'
    it 'should create function, which fetches given key from object', ->
        testobj = {'key': 'XXX'}
        expect(attr('key')(testobj)).toBe testobj.key

