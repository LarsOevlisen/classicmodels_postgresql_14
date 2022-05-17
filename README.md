# ClassicModels Database
Repository contains a PostgreSQL build script for the BIRT (https://eclipse.github.io/birt-website/docs/template-sample-database) sample database as well as exercises and answers for Richard Watson's ClassicModels SQL question bank (https://www.richardtwatson.com/open/Reader/ClassicModels.html).

## Requirements
In order to create the database and load the data correctly, the following general steps should be undertaken before running the SQL build script:

1. Download and install PostgreSQL 14 (earlier versions might very well also work, but I have only tested using v14)
2. Since two tables will end up containing spatial information that is imported using a specific GIS function, PostGIS should be installed once PostgreSQL has been installed.

### macOS
If you are using macOS, an easy way to install PostgreSQL and PostGIS is to use postgresapp (https://postgresapp.com/). Once installed, log in to your local PostgreSQL installation using the `psql` terminal command and create a database with the name 'classicmodels'. While still logged into your PostgreSQL server, identify your recently created 'classicmodels' database in the list of databases by running the command `\l`. Exit `psql` by running the command `\q` and continue with the installation of PostGIS by running the following two commands in terminal:
```
psql -d classicmodels -f /Applications/Postgres.app/Contents/Versions/latest/share/postgresql/contrib/postgis-3.1/postgis.sql
psql -d classicmodels -f /Applications/Postgres.app/Contents/Versions/latest/share/postgresql/contrib/postgis-3.1/spatial_ref_sys.sql
```
With the two PostGIS installations completed, run the SQL build script 'classicmodels_psql_14.sql' by running the terminal command:
```
psql -d classicmodels -a -q -f /classicmodels_postgresql_14/classicmodels_psql_14_build/classicmodels_psql_14.sql
```
