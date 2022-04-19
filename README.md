# DictionaryResolver

This library implements a simple inheritance system for a collection of dictionaries.

You can define raw dictionary records with any properties you like, and add them to the resolver, tagging each one with a unique identifier.

Once all records have been added to the index, you can resolve it.

This process examines each record in turn for a special key (by default, the key is `inherits`). This key, if present, should contain a list of one or more other record identifiers.

The properties of each inherited record are merged with the properties of the inheriting record. The process of inheritance is recursive, so inherited records can in turn inherit from other records.   

Once resolution has completed, every record in the index contains a full complement of all the properties that it inherited. 

Note that inherited properties are copies of the original properties from the inherited record. If the inherited property is a value type, changing it for a resolved record won't affect other resolved records that also inherited the value. If the inherited property is a reference type however, then all records that inherit it will hold the same reference; changing something in that reference will affect anything that holds it.   

## Custom Inheritance Of Properties

By default, if a record already has a value for an inherited property, the inherited value is ignored.

However, it is possible to install custom "combiner" functions which process certain properties in different ways.

If installed, each custom combiner is run in turn for each property that is being merged, and is passed the key, and the existing and inherited records. 

A combiner can run any code it needs in order to decide whether it should be applied. For example it might only apply for certain key values, or for certain value types.

The first combiner which returns true to say that it was applied will stop the merging process for that property. 

Not that the combiner has access to the full records, and not just the values of the property it is being asked to merge. If necessary, it can read other keys from the records and use them in the calculation of the merged value. However, care must be taken when reading other properties from the record we are merging into, as the merging process may or may not have already been run on them.
