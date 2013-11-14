Cerealizer [![Build Status](https://travis-ci.org/billysbilling/cerealizer.png)](https://travis-ci.org/billysbilling/cerealizer)
================

The purpose of this module is to serialize an array of objects (each containing one or more collection objects) into collection arrays of objects with references to relationships.

## Usage

```javascript
var cerealizer = require('cerealizer');
var data = [
  {
    majors: { id: 1, name: 'Capital' },
    minors: { id: 'a', height: 33 }
  },
  {
    majors: { id: 1, name: 'Capital' },
    minors: { id: 'b', height: 20 }
  },
  {
    majors: { id: 2, name: 'Class' },
    minors: { id: 'b', height: 20 }
  }
];
console.log(cerealizer(data));
// Outputs
// {
//   majors: [
//     { id: 1, name: 'Capital', minorIds: ['a', 'b'] },
//     { id: 2, name: 'Class', minorIds: ['b'] }
//   ],
//   minors: [
//     { id: 'a', height: 33, majorIds: [1] },
//     { id: 'b', height: 20, majorIds: [1, 2] }
//   ]
// }
```

## Description

The Cerealizer runs through a series of operations, which are merging of elements, merging of namespaces, building of relationships, and converting to arrays.

### Merging of elements

This operation changes the data from being a single array of objects each containing one or more collection objects into an array for each collection containing all of their respective elements. The options identifier (default is `id`) is used to only add distinct entities to each collection.

### Merging of namespaces

This operation merges collections with the same namespace into a single collection. An example of common usage with MySQL is a table containing two different references to a single table, like a user having both a primary and a secondary group. The collections should then be named something like `groups:primary` and `groups:secondary`, which will cause both of them to be merged into the collection `groups`.

### Building of relationships

This operation builds relationships between entities. The options identifier (default is `id`) is used to find the identified relationship. Relationships are found by using singular collection names combined with the identifier (e.g. `groupId` for `groups`). It also handles many-to-many relationships, where the structure would be a collection called `userGroups` with `userId` and `groupId`, which will create a reference to `userId` and `groupId` on the corresponding group and user respectively. The `userGroups` collection will also be passed along.

### Converting to arrays

This operation runs through all collections and converts the object containing the entities into an array.

## API

### cerealizer(array[, options])

Serializes the array of objects into collection arrays of objects with references to relationships.

 - array: Array of objects (each containing one or more collection objects)
 - options (optional):
   - identifier: String or array of identifier keys

**Example**
```javascript
cerealizer([
  {
    majors: { id: 1 },
    minors: { id: 2 }
  }
]);
// Outputs
// {
//   majors: [ { id: 1 } ],
//   minors: [ { id: 2 } ]
// }
```

### cerealizer.inflectors

#### addRule(plural, singular)

Adds a rule to the Inflectors module that will override existing patterns. Rules added are used for both pluralization and singularization.

 - plural: String of the plural form to match (or respond with when singularizing)
 - singular: String of the singular form to match (or respond with when pluralizing)

**Example**
```javascript
cerealizer.inflectors.addRule('foo', 'bar');
cerealizer.inflectors.singularize('foo'); //-> bar
cerealizer.inflectors.pluralize('bar'); //-> foo
```

#### removeRule(plural)

Removes a rule from the Inflectors module.

 - plural: String of the plural form to remove

**Example**
```javascript
cerealizer.inflectors.addRule('foo', 'bar');
cerealizer.inflectors.singularize('foo'); //-> bar
cerealizer.inflectors.removeRule('foo');
cerealizer.inflectors.pluralize('bar'); //-> bars
```

================

Mmmm.. Cereal

![Homer Simpsons](http://images4.wikia.nocookie.net/__cb20121205194539/simpsons/images/7/7f/Mmm.jpg)
