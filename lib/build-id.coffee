_ = require 'lodash'

# Build ID from fields and identifier array or string. If identifier is
# an array, keys are combined by dashes.
#
# fields     - The Hash containing fields
# identifier - The String or Array identifier
#
# Returns String of ID
module.exports = (fields, identifier, strict = false) ->
	# Check for identifier array
	if Array.isArray(identifier)
		# Create array of identifier values
		values = []
		for key in identifier
			values.push(fields[key])

		# Return indentifier values combined by dashes
		return values.join('-')

	id = fields[identifier]

	# Check for identifier, else if not strict create ID of all fields
	if not id? and not strict
		id = _.values(fields).join('-')

	# Return identifier value
	return id