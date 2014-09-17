# TokiCLI

Toki.app command-line client and API server. 

Access your Toki data from the local database or from the App.net backup channel, via the CLI interface or the served API.

![TokiServer example](https://www.evernote.com/shard/s89/sh/dd392b00-82b6-4f13-b573-c925a99ae5a0/02aa5ea4266e8bc7e28d7c91ba8b922c/deep/0/toki-server.png)  


## Installation

`gem install TokiCLI`

## Usage

### Help

`toki`

shows the basic commands.

`toki help <command>`

shows help and available options for a specific command.

Example:

`toki help bundle`

### Total

The **total** command shows the total usage time for all apps.

`toki total`

The results are sorted by ascending usage time.

### Top

The **top** command shows your top used apps.

`toki top`

TokiCLI shows the top 5 by default, but you can specify a number with the `-n` option:

`toki top -n 10`

### Day

The **day** command shows your top used apps on a specific day.

The date you type has to be formatted like this: year-month-day

`toki day 2014-04-19`

### Since

The **since** command shows your top used apps since a specific day.

`toki since 2014-04-19`

### Before

The **before** command shows your top used apps before a specific day.

`toki before 2014-04-19`

### Range

The **range** command shows your top used apps between two specific days.

`toki range 2014-04-17 2014-04-19`

### App

Complete log for an app

`toki app airmail`

Several apps may contain the same name. In that case, they will all be processed.

Example: `toki app apple`  

#### App before

Complete log for an app before a specific day

`toki app airmail --before 2014-04-19`


#### App since

Complete log for an app since a specific day

`toki app airmail --since 2014-04-19`


#### App day

Complete log for an app on a specific day

`toki app airmail --day 2014-04-19`


### Bundle

Complete log for an app, given its exact bundle ID.

Same features as for `app`, just give an app bundle instead of an app name.

This should always return only one app log.

`toki bundle it.bloop.airmail`
`toki bundle it.bloop.airmail --before 2014-04-19`
`toki bundle it.bloop.airmail --since 2014-04-19`
`toki bundle it.bloop.airmail --day 2014-04-19`

### Activity

Recent Toki activity log.

`toki activity`

#### Activity since

Complete Toki activity log since a specific day.

`toki activity --since 2014-04-19`

#### Activity day

Complete Toki activity log for a specific day.

`toki activity --day 2014-04-19`

### Scan

Scan for apps name.

Will crawl the Applications folder and try to resolve app names from bundle identifiers.

*Toki can display apps names in results only if apps have been scanned.* 
  

### Option: JSON

Export the Toki results as a JSON file with the `--json` option:

`toki total --json`

`toki day 2014-04-18 --json `

`toki top -n10 -J` 

### Option: CSV

Export the Toki results as a CSV file with the `--csv` option:

`toki total --csv`

`toki day 2014-04-18 --csv`

`toki top -n10 -C` 

### Delete

Completely delete all traces of an app in the database.

With backup:

`toki delete it.bloop.airmail`

Without backup:

`toki delete it.bloop.airmail --no-backup`

### Restore database from App.net

Toki.app backs up your Toki tracked apps data 'in the cloud' via an App.net channel.

TokiCLI should be able to download this data and *rebuild the Toki database* if you lost your local install or if it has been compromised.

`toki restore`  

# API

## Server for the API

`toki serve`  

You can see a list of requests on the index page: *http://localhost:4567*.

Examples of API calls with curl:

```
curl http://localhost:4567/api/apps/top/10
curl http://localhost:4567/api/apps/day/2014-05-27
curl http://localhost:4567/api/apps/range/2014-05-27/2014-05-30
curl http://localhost:4567/api/logs/app/safari/
curl http://localhost:4567/api/logs/app/safari/since/2014-05-27
curl http://localhost:4567/api/logs/bundle/com.apple.Safari/before/2014-05-27
```  

*Web: remove the "/api" part of the URL to access rendered views of the responses.*

## Library  

You can also use the TokiCLI API in another app:

`require 'TokiCLI'`  

### Basic

Create a basic TokiCLI API instance:

`toki = TokiCLI::TokiAPI.new("#{~/Library/path/to/tokiapp/db}")`

### With apps names

Create a TokiCLI FileOps instance:

`fileops = TokiCLI::FileOps.new`

Scan for apps names (see ##Tools):

`fileops.save_bundles`

Create a TokiCLI API instance:

`toki = TokiCLI::TokiAPI.new(fileops.db_file, fileops.bundles)`

*See `toki_api.rb` and `fileops.rb` for the list of available methods.*

# Toki

[Toki](https://itunes.apple.com/fr/app/toki/id861749202?mt=12) is a Mac OS X app written by [Keitaroh Kobayashi](http://app.net/keita).

It's a time tracker for your apps that sits in the menu bar.

## Important

**TokiCLI does _not_ track your apps.**

**Tracking is the job of Toki.app by @keita.**

TokiCLI interacts only with the Toki.app database or the App.net backup channel.

## Thanks

Keita was super nice and said "Awesome!" instead of just "Yes" or "GTFO" when I asked him if I could use the 'Toki' name for this companion Gem.

Many thanks and congrats to Keita! :)
