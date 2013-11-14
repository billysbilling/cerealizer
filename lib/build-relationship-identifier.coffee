inflectors = require 'inflectors'

# Build identifier for relationship from name of the collection and
# identifier array or string. If identifier is an array, key are combined by
# dashes.
#
# collectionName - The String of the relationship collection's name
# identifier     - The String or Array identifier
#
# Returns String of relationship identifier
module.exports = (collectionName, identifier, plural = false) ->
	# Inflect model name from collection name
	relationshipIdentifier = inflectors.singularize(collectionName)

	# Generate pascalcased identifier
	if Array.isArray(identifier)
		relationshipIdentifier += identifier.map((key) ->
			return inflectors.classify(key)
		).join('')
	else
		relationshipIdentifier += inflectors.classify(identifier)

	if plural
		relationshipIdentifier += 's'

	return relationshipIdentifier
