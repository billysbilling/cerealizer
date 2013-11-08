assert = require('assert')
serialize = require('../index')

describe 'serializing', ->
	subject = undefined

	before ->
		data = []
		data.push
			majors:
				id: '1'
			minors:
				id: 'a'
				majorId: '1'
			'subs:thing':
				id: 'c'

		data.push
			majors:
				id: '2'
			minors:
				id: 'b'
				majorId: '2'
			'subs:thing':
				id: 'd'

		subject = serialize data

	it 'creates an array based off of namespaced attributes', ->
		assert(subject.hasOwnProperty('subs'))

	it 'creates an array of included identifiers', ->
		assert.deepEqual subject.majors[0].minorIds, ['a']
		assert.deepEqual subject.majors[1].minorIds, ['b']
