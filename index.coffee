_ = require 'lodash'
inflectors = require 'inflectors'
buildId = require './lib/build-id'
buildReferenceIdentifier = require './lib/build-reference-identifier'
buildRelationshipIdentifier = require './lib/build-relationship-identifier'

# Serialize nested collection arrays into collections of arrays. An obivous
# usecase is a MySQL rows array, when nestTables is true, which would return an
# object containing arrays for each table name containing their rows without
# duplicates.
#
# array   - The Array of objects containing nested collections
# options:
#   identifier       - The String or Array identifier
#   _collectionNames - The Array of collection names
#
# Returns object with nested arrays
serializer = module.exports = (array, options) ->
	# Set default options
	options ?= {}
	options.identifier ?= 'id'
	options._collectionNames = []

	# Proces data in steps
	array = _mergeElements(array, options)
	array = _mergeNamespaces(array)
	array = _buildRelationships(array, options)
	array = _convertToArrays(array)

	return array

serializer.inflectors = inflectors

# Merges elements into collections (tables) containing record item objects
# instead of arrays (rows) containing hashes (tables). Also removes duplicate
# elements.
#
# elements - The Array containing object hashes
# options:
#   identifier       - The String or Array identifier
#   _collectionNames - The Array of collection names
#
# Returns collections for each table of item objects
_mergeElements = (elements, options) ->
	{_collectionNames, identifier} = options

	_.reduce elements, (object, element) ->
		for collection, fields of element
			# Create array of all collection names
			if _collectionNames.indexOf(collection) is -1
				_collectionNames.push(collection)

			# Safely add unique objects to collection
			object[collection] ?= {}
			object[collection][buildId(fields, identifier)] = fields

		return object
	, {}

# Merges namespaced collections into the namespace's collection.
#
# elements - The Object containing table collections
#
# Returns collections for each namespace of objects
_mergeNamespaces = (elements) ->
	_.reduce elements, (object, items, collectionName) ->
		# Search collection name for {collectionName} or {namespace}:{collectionName}
		parts = collectionName.match(/^([^:]+)(:([^:]+))*/)
		# Update collection name to namespace
		if parts[3]?
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
# options:
#   identifier       - The String or Array identifier
#   _collectionNames - The Array of collection names
#
# Returns collections for each namespace of objects
_buildRelationships = (elements, options) ->
	{_collectionNames, identifier} = options

	_.reduce elements, (object, items, collectionName) ->
		# Add to existing collection or create it
		if object[collectionName]?
			_.merge(object[collectionName], items)
		else
			object[collectionName] = items

		# Run through all items in the collection
		for id, item of items
			# Run through each collection name
			for refCollectionName in _collectionNames
				# Build item identifier based on item keys
				itemIdentifier = buildReferenceIdentifier(refCollectionName, item, identifier)

				# If no item identifier is found, don't continue with relationships for this
				if itemIdentifier?
					# Build collection identifier
					if itemIdentifier is 'id'
						# If using generic ID item identifier, build collection identifier from collection name
						collectionIdentifier = buildRelationshipIdentifier(collectionName, identifier, true)
					else
						# Otherwise just use pluralized version of item identifier
						collectionIdentifier = inflectors.pluralize(itemIdentifier)

					# Check for reference to collection
					if (refId = item[buildRelationshipIdentifier(refCollectionName, identifier)])?
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
#
# Returns object with nested arrays
_convertToArrays = (elements) ->
	_.reduce elements, (object, items, collectionName) ->
		# Convert collection to array
		object[collectionName] = _.toArray(items)

		return object
	, {}
