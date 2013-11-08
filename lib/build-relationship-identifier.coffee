inflection = require 'inflection'

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
	relationshipIdentifier = inflection.singularize(collectionName)

	# Generate pascalcased identifier
	if Array.isArray(identifier)
		relationshipIdentifier += identifier.map((key) ->
			return inflection.capitalize(key)
		).join('')
	else
		relationshipIdentifier += inflection.capitalize(identifier)

	if plural
		relationshipIdentifier += 's'

	return relationshipIdentifier
