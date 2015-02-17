# UNIMARC to RDF

XSL transformation to convert [UNIMARC](http://www.ifla.org/publications/unimarc-bibliographic-3rd-edition-updates-2012) serialized in [MARCXML](http://www.loc.gov/standards/marcxml/) syntax to RDF.

## Usage

The main XSL driving the transformation is [`unimarc_to_rdf.xsl`](https://github.com/jindrichmynarz/UNIMARC-to-RDF/blob/master/unimarc_to_rdf.xsl). This stylesheet imports a tiny [functions library](https://github.com/jindrichmynarz/UNIMARC-to-RDF/blob/master/lib/functions.xsl) and a [stylesheet for transforming locally defined fields](https://github.com/jindrichmynarz/UNIMARC-to-RDF/blob/master/lib/local.xsl) from the 9XX range. You can overwrite the imported stylesheet with mapping of your locally defined fields.

The stylesheets accepts a single parameter called `ns` that sets the default namespace in which resource URIs will be created. The URI patterns follow the guidance of the [COMSODE](http://www.comsode.eu/) project [methodology](http://www.comsode.eu/wp-content/uploads/Annex1_D5.1-Documentation_of_practices.pdf); i.e. practice P02A03-05 in particular. 

## Limitations

* The scope of the transformation is limited. It only covers some of the most frequently occuring fields and subfields of UNIMARC. If you want to know frequency statistics of your MARCXML dataset, you can use [this XQuery 3.0 query](https://gist.github.com/jindrichmynarz/3fe8392fe9ecfe0a5e3f). 
* The transformation uses direct Java calls to `java.util.UUID#randomUUID` method for generating URIs. This is supported by a few XSL processors, such as [Saxon](http://saxonica.com/products/products.xml) in the personal or enterprise edition.

## Acknowledgements

The transformation was originally developed for the [Slovak National Library](http://www.snk.sk/en) in the course of the [COMSODE](http://www.comsode.eu/) project.

## License

Copyright &copy; 2015 Jindřich Mynarz

Distributed under the Eclipse Public License version 1.0.
