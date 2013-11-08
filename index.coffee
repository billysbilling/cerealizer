inflection = require 'inflection'
_ = require 'lodash'

module.exports = (array, options) ->
	# Set default options
	options ?= {}
	options.identifier ?= 'id'
	options._collectionNames = []

	# Proces data in steps
	array = _mergeElements(array, options)
	array = _mergeNamespaces(array, options)
	array = _buildRelationships(array, options)
	array = _convertToArrays(array, options)

	return array

# Merges elements into collections (tables) containing record item objects
# instead of arrays (rows) containing hashes (tables). Also removes duplicate
# elements.
#
# elements - The Array containing object hashes
# options  - The Hash containing options
#
# Returns collections for each table of item objects
_mergeElements = (elements, options) ->
	_.reduce elements, (object, element) ->
		for collection, fields of element
			# Create array of all collection names
			if options._collectionNames.indexOf(collection) is -1
				options._collectionNames.push(collection)

			# Safely add unique objects to collection
			object[collection] ?= {}
			object[collection][_buildId(fields, options.identifier)] = fields

		return object
	, {}

# Merges namespaced collections into the namespace's collection.
#
# elements - The Object containing table collections
# options  - The Hash containing options
#
# Returns collections for each namespace of objects
_mergeNamespaces = (elements, options) ->
	_.reduce elements, (object, items, collectionName) ->
		# Search collection name for {collectionName} or {namespace}:{collectionName}
		parts = collectionName.match(/^([^:]+)(:([^:]+))*/)
		# Update collection name to namespace
		if parts[3]
			collectionName = parts[1]

		# Add to existing collection or create it
		if object[collectionName]?
			_.merge(object[collectionName], items)
		else
			object[collectionName] = items

		return object
	, {}

# Builds relationships between collection items, both one-to-many and many-to-
# many relationships.
#
# elements - The Object containing namespace collections
# options  - The Hash containing options
#
# Returns collections for each namespace of objects
_buildRelationships = (elements, options) ->
	_.reduce elements, (object, items, collectionName) ->
		# Add to existing collection or create it
		if object[collectionName]?
			_.merge(object[collectionName], items)
		else
			object[collectionName] = items

		# Run through all items in the collection
		for id, item of items

			# Run through each collection name
			for refCollectionName in options._collectionNames
				itemIdentifier = _buildReferenceIdentifier(refCollectionName, item, options.identifier)
				if not itemIdentifier?
					continue
				if itemIdentifier is 'id'
					collectionIdentifier = _buildRelationshipIdentifier(collectionName, options.identifier, true)
				else
					collectionIdentifier = inflection.pluralize itemIdentifier

				# Check for reference to collection
				if (refId = item[_buildRelationshipIdentifier(refCollectionName, options.identifier)])?

					# Check original collections object for existance of collection and item
					if elements[refCollectionName]? and elements[refCollectionName][refId]?

						# Safely add unique reference to this object from collection object
						object[refCollectionName] ?= {}
						object[refCollectionName][refId] ?= {}
						refCol = object[refCollectionName][refId][collectionIdentifier] ?= []
						if refCol.indexOf(item[itemIdentifier]) is -1
							refCol.push(item[itemIdentifier])

		return object
	, {}

# Converts first level of nested objects to arrays.
#
# elements - The Hash containing hashes of records
# options  - The Hash containing options
#
# Returns object with nested arrays
_convertToArrays = (elements, options) ->
	_.reduce elements, (object, items, col) ->
		# Convert collection to array
		object[col] = _.toArray(items)

		return object
	, {}

# Helper: Build relationship identifier from name of the collection and
# identifier array or string. If identifier is an array, key are combined by
# dashes. This method verifies the existance of the identifier among the fields
# passed as argument.
#
# collectionName - The String of the collection's name
# identifier - The String or Array containing identifier of one or more keys
#
# Returns String of identifier value or undefined if none is found
_buildReferenceIdentifier = (collectionName, fields, identifier) ->
	id = _buildId(fields, identifier, true)
	if id?
		if Array.isArray(identifier)
			return identifier.join '-'

		return identifier

	refIdentifier = _buildRelationshipIdentifier(collectionName, identifier)
	keys = Object.keys fields
	keys = _.filter keys, (key) ->
		return key isnt refIdentifier

	if keys.length is 1
		return keys[0]

	return undefined

# Helper: Build ID from fields and identifier array or string. If identifier is
# an array, keys are combined by dashes.
#
# fields     - The Hash containing fields
# identifier - The String or Array containing identifier of one or more keys
#
# Returns String of ID
_buildId = (fields, identifier, strict = false) ->
	# Check for identifier array
	if Array.isArray(identifier)
		# Create array of identifier values
		values = []
		for key in identifier
			values.push fields[key]

		# Return indentifier values combined by dashes
		return values.join '-'

	id = fields[identifier]

	# Check for identifier, else if not strict create ID of all fields
	if not id? and not strict
		id = _.values(fields).join '-'

	# Return identifier value
	return id

# Helper: Build identifier for relationship from name of the collection and
# identifier array or string. If identifier is an array, key are combined by
# dashes.
#
# collectionName - The String of the relationship collection's name
# identifier     - The String or Array containing identifier of one or more keys
#
# Returns String of relationship identifier
_buildRelationshipIdentifier = (collectionName, identifier, plural = false) ->
	# Inflect model name from collection name
	relationshipIdentifier = inflection.singularize collectionName

	# Generate pascalcased identifier
	if Array.isArray(identifier)
		relationshipIdentifier += identifier.map((key) ->
			return inflection.capitalize key
		).join('')
	else
		relationshipIdentifier += inflection.capitalize identifier

	if plural
		relationshipIdentifier += 's'

	return relationshipIdentifier
