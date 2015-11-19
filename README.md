# NoPaste

## Description

NoPaste Application, written by perl5.

## Install

1.create database
```sql
mysql> create database no_paste;
```

2.migrate
```bash
$mysql -uroot no_paste < sql/schema.sql
```

3.cpanm install
```bash
$cpanm --installdeps .
```

4.plackup
```bash
$plackup app.psgi
```

## Author

[MacoTasu](https://github.com/MacoTasu)
