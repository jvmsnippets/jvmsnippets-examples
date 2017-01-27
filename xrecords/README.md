# XRecords: Tabular Record File Conversion Framework #

`xrecords` is a small
[framework](http://en.wikipedia.org/wiki/Software_framework) for
converting a wide variety of tabular data file formats including (but
not limited to):

- Relational database tables
- Comma-separated values (CSV)
- Delimited
- Fixed-length
- XML
- DBF (Xbase)

The `xrecords` framework is currently implemented in
[Java](https://www.java.com/en/), [Scala](http://scala-lang.org/) and
[Xtend](http://www.eclipse.org/xtend/) with more JVM languages coming
down the line.

`xrecords` is sufficiently simple to be easily understood by experienced
Java programmers. At the same time, however, it's not a trivial library
as it exercises real-world programming constructs implemented
idiomatically in each JVM programming language.

Check the
[blog entry](http://blog.xrrocha.net/2014/08/building-object-oriented-frameworks-1.html)
for a (somewhat outdated) discussion of the framework design.

`xrecords` is a
[blackbox](http://en.wikipedia.org/wiki/Extensibility#Black-Box_Extensibility)
framework and thus can be instantiated declaratively, without
programming.

File-conversion applications are written using
[YAML](http://en.wikipedia.org/wiki/YAML). Blackbox components can be
scripted in any JVM language supported by
[JSR-223](https://jcp.org/en/jsr/detail?id=223).

The following `xrecords` application populates a Postgres table from a
delimited file:

```yaml
source: !csvSource
    input: !fromLocation [data/acme-form4269.csv]
    fields: &myFields [
        { name: tariff, format: !integer },
        { name: desc,   format: !string  },
        { name: qty,    format: !integer },
        { name: price,  format: !double ['#,###.##'] },
        { name: origin, format: !string },
        { name: eta,    format: !date [dd/MM/yyyy] }
    ]

filter: !condition [tariff != 0] # javascript

destination: !databaseDestination
    tableName:  form4269
    columns: *myFields # CSV field names match column names
    dataSource: !!org.postgresql.ds.PGSimpleDataSource
        user: load
        password: load123
        serverName: customs.feudalia.gov
        databaseName: forms
```

`xrecords` uses the [SnakeYAML](https://code.google.com/p/snakeyaml/)
and [YamlTag](https://github.com/xrrocha/yamltag) libraries.

