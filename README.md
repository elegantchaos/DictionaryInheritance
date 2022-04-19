# DictionaryResolver

This library implements a simple inheritance system for a collection of dictionaries.

You can define raw dictionary records with any properties you like, and add them to the resolver, tagging each one with a unique identifier.

Once all records have been added to the index, you can resolve it.

This process examines each record in turn for a special key (by default, the key is `inherits`). This key, if present, should contain a list of one or more other record identifiers.

The properties of each inherited record are merged with the properties of the inheriting record. The process of inheritance is recursive, so inherited records can in turn inherit from other records.   

Once resolution has completed, every record in the index contains a full complement of all the properties that it inherited. 

Note that inherited properties are copies of the original properties from the inherited record. If the inherited property is a value type, changing it for a resolved record won't affect other resolved records that also inherited the value. If the inherited property is a reference type however, then all records that inherit it will hold the same reference; changing something in that reference will affect anything that holds it.   
