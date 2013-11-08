assert = require('assert')
serialize = require('../index')

describe 'serializing', ->
	describe 'joined tables', ->
		subject = []

		before ->
			data = []
			data.push
				majors:
					id: 1
				minors:
					id: 'a'
				majorMinors:
					majorId: 1
					minorId: 'a'

			data.push
				majors:
					id: 1
				minors:
					id: 'b'
				majorMinors:
					majorId: 1
					minorId: 'b'

			data.push
				majors:
					id: 2
				minors:
					id: 'b'
				majorMinors:
					majorId: 2
					minorId: 'b'

			data.push
				majors:
					id: 2
				minors:
					id: 'c'
				majorMinors:
					majorId: 2
					minorId: 'c'

			subject = serialize data

		it 'merges many to many relationships', ->
			assert.deepEqual(subject.majors[0].minorIds, ['a', 'b'])
			assert.deepEqual(subject.minors[1].majorIds, [1, 2])

		it 'serializes all non-join tables', ->
			assert.equal subject.majors.length, 2
			assert.equal subject.minors.length, 3

	describe 'joined many-to-many', ->
		subject = []

		before ->
			data = []
			data.push
				majors:
					id: 1
				majorMinors:
					majorId: 1
					minorId: 'a'

			data.push
				majors:
					id: 1
				majorMinors:
					majorId: 1
					minorId: 'b'

			subject = serialize data

		it 'without both sides', ->
			assert.equal subject.hasOwnProperty('minors'), false
