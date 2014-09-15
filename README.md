# TokiCLI

Toki.app command-line client and API server. 

Access your Toki data from the local database or from the App.net backup channel, via the CLI interface or the served API.

![TokiCLI](https://www.evernote.com/shard/s89/sh/dd392b00-82b6-4f13-b573-c925a99ae5a0/02aa5ea4266e8bc7e28d7c91ba8b922c/deep/0/toki-server.png)  


## Installation

`gem install TokiCLI`

## Usage

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

Total tracked time for an app

`toki app iterm`

You don't have to specify the exact name of the identifier: for example, typing 'iterm' will find 'com.googlecode.iterm2'.

However, you can specify a bundle identifier if you need it.

`toki app --bundle 'com.googlecode.iterm2'`

### App before

Total tracked time for an app before a specific day

`toki app_before iterm 2014-04-19`

`toki app_before --bundle 'com.googlecode.iterm2' 2014-04-19`


### App since

Total tracked time for an app since a specific day

`toki app_since iterm 2014-04-19`

`toki app_since --bundle 'com.googlecode.iterm2' 2014-04-19`


### App day

Total tracked time for an app on a specific day

`toki app_day iterm 2014-04-19`

`toki app_day --bundle 'com.googlecode.iterm2' 2014-04-19`

### App range

Total tracked time for an app between two specific days

`toki app_range iterm 2014-04-19 2014-04-23`

`toki app_range --bundle 'com.googlecode.iterm2' 2014-04-19 2014-04-23`


### Log

The **log** command shows the entire log (history) for one app.

`toki log iterm`

`toki log --bundle 'com.googlecode.iterm2'`

The results are sorted by ascending date and time.

### Scan

Scan for apps name.

Will crawl the Applications folder and try to resolve app names from bundle identifiers.

Toki will display apps names in results if apps have been scanned.  

### Auth

In order to be able to access your ADN channel (optional), TokiCLI has to obtain a "token" (secret code) from App.net.

Just do `toki auth` and follow the steps, this is fast and easy.  

### Global option: JSON

Export the Toki results as a JSON file with the `--json` option:

`toki total --json`

`toki day --json 2014-04-18`

`toki top -n10 -J` 

### Global option: CSV

Export the Toki results as a CSV file with the `--csv` option:

`toki total --csv`

`toki day --csv 2014-04-18`

`toki top -n10 -C` 

### Restore database from App.net

Toki.app backs up your Toki tracked apps data 'in the cloud' via an App.net channel.

TokiCLI should be able to download this data and *rebuild the Toki database* if you lost your local install or you're simply moving toki.app to a new machine.

`toki auth`

`toki restore`  

# API

## Local server for the API

`toki serve`  

You can see a list of requests on the index page: *http://localhost:4567*.

Examples of API calls with curl:

```
curl http://localhost:4567/api/apps/top/10
curl http://localhost:4567/api/find/safari/log
curl http://localhost:4567/api/find/safari/since/2014-05-27
curl http://localhost:4567/api/bundle/com.apple.Safari/before/2014-05-27
curl http://localhost:4567/api/apps/day/2014-05-27
curl http://localhost:4567/api/apps/range/2014-05-27/2014-05-30
```  

Remove the "/api" part of the URL to access rendered views of the responses.  

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

### Endpoints

Get the total time for an app, in seconds, given its exact bundle identifier:

`time = toki.bundle_total 'com.sublimetext.3'`

With a (partial) name:

`time = toki.name_total 'sublime'`

Get the total time for an app, in seconds, given its exact bundle identifier, since a specific day:

`time = toki.bundle_total_since 'com.sublimetext.3', '2014-05-15'`

With a (partial) name:

`time = toki.name_total_since 'sublime', '2014-05-15'`

Get the total time for an app, in seconds, given its exact bundle identifier, before a specific day:

`time = toki.bundle_total_before 'com.sublimetext.3', '2014-05-15'`

With a (partial) name:

`time = toki.name_total_before 'sublime', '2014-05-15'`

Get the total time for an app, in seconds, given its exact bundle identifier, before and since a specific day:

`time = toki.bundle_total_split 'com.sublimetext.3', '2014-05-15'`

With a (partial) name:

`time = toki.name_total_split 'sublime', '2014-05-15'`

Get the total time for an app, in seconds, given its exact bundle identifier, between two specific days:

`time = toki.bundle_total_range 'com.sublimetext.3', '2014-05-15', '2014-05-17'`

With a (partial) name:

`time = toki.name_total_range 'sublime', '2014-05-15', '2014-05-17'`

Get the total time of all apps used between day 1 and day 2:

`apps = toki.apps_range '2014-05-15', '2014-05-17'`

Get the total time of all apps used on a specific day:

`apps = toki.apps_day '2014-05-15'`

Get the total time of all tracked apps:

`apps = toki.apps_total`

Get the top x tracked apps (5 by default):

`apps = toki.apps_top 10`

Get the complete log for an app:

`log = toki.bundle_log 'com.sublimetext.3'`

With a (partial) name:

`log = toki.name_log 'sublime text'`


## Tools

Scan disk for installed apps and save the file:

`fileops.save_bundles`

The file will be automatically loaded in new FileOps instances:

`app_names = fileops.bundles`

# Toki

[Toki](https://itunes.apple.com/fr/app/toki/id861749202?mt=12) is a Mac OS X app written by [Keitaroh Kobayashi](http://app.net/keita).

It's a time tracker for your apps that sits in the menu bar.

## Important

**TokiCLI does _not_ track your apps.**

**Tracking is the job of Toki.app by @keita.**

TokiCLI interacts only with the Toki.app database or the App.net backup channel.

## Next

Teasing: TokiCLI has only read-only commands... for now. ;)

## Thanks

Keita was super nice and said "Awesome!" instead of just "Yes" or "GTFO" when I asked him if I could use the 'Toki' name for this companion Gem.

Many thanks and congrats to Keita! :)
