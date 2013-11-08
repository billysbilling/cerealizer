_ = require 'lodash'
buildId = require './build-id'
buildRelationshipIdentifier = require './build-relationship-identifier'

# Build relationship identifier from name of the collection and
# identifier array or string. If identifier is an array, key are combined by
# dashes. This method verifies the existance of the identifier among the fields
# passed as argument.
#
# collectionName - The String of the collection's name
# identifier - The String or Array identifier
#
# Returns String of identifier value or undefined if none is found
module.exports = (collectionName, fields, identifier) ->
	id = buildId(fields, identifier, true)
	if id?
		if Array.isArray(identifier)
			return identifier.join('-')

		return identifier

	refIdentifier = buildRelationshipIdentifier(collectionName, identifier)
	keys = Object.keys(fields)
	keys = _.filter keys, (key) ->
		return key isnt refIdentifier

	if keys.length is 1
		return keys[0]

	return undefined