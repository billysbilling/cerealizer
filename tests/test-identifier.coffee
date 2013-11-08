assert = require('assert')
serialize = require('../index')

describe 'serializing', ->
	describe 'default identifier', ->
		subject = undefined

		before ->
			data = []
			data.push
				majors:
					id: 'a'

			data.push
				majors:
					id: 'b'

			subject = serialize data

		it 'creates an array of majors with id attribute', ->
			assert.deepEqual subject.majors[0], { id: 'a' }
			assert.deepEqual subject.majors[1], { id: 'b' }

	describe 'simple identifier', ->
		subject = undefined

		before ->
			data = []
			data.push
				majors:
					alt: 'a'

			data.push
				majors:
					alt: 'b'

			subject = serialize data,
				identifier: 'alt'

		it 'creates an array of majors with alt attribute', ->
			assert.deepEqual subject.majors[0], { alt: 'a' }
			assert.deepEqual subject.majors[1], { alt: 'b' }

	describe 'combined identifier', ->
		subject = undefined

		before ->
			data = []
			data.push
				majors:
					type: 'sumting'
					alt: 'a'

			data.push
				majors:
					type: 'sumting'
					alt: 'b'

			subject = serialize data,
				identifier: ['type', 'alt']

		it 'creates an array of majors with type and alt attributes', ->
			assert.deepEqual subject.majors[0], { type: 'sumting', alt: 'a' }
			assert.deepEqual subject.majors[1], { type: 'sumting', alt: 'b' }
