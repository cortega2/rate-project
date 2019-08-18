# Rate Project 
## Description
This application keeps tracks of rates and is used to get rates for specified time ranges

# Requirements
ruby  2.6.3

## Install
* clone the repo
* bundle install
* bundle exec rake db:create
* bundle exec rake db:migrate

## Tests
This project uses rspec and the tests can be found in the spec folder.
To run the tests simply run `bundle exec rake spec`

## Run
### Dev
When running in dev the only thing that has to be done is `bundle exec rails s`. This is because the db it uses is sqlite.

### Prod
When moving to prod the following things need to be setup
* mysql database
* Environment variables
* `SQL_DB=`
* `SQL_HOST`
* `SQL_PORT`

## Docker
Included is a docker file which you can use to build the application simply do:
`docker build -t rate-server .`


There is also a docker-compose file included that you can use to build the image and run the stack:
1. `docker-compose build`
2. `docker-compose up`
3. The application will be listening to port 3000
4. The swagger server will be listening to port TODO

## Endpoints
### GET /rates
This is used to get any or all available rates. You can use query params to search for rates.
Here are some examples of available commands.

* `localhost:3000/rates?start=2015-07-01T07:00:00-05:00&end=2015-07-01T12:00:00-05:00`
This will search for a SINGLE rate that encapsulates the given date range. Note that the range cannot be more than a day appart.
* `localhost:3000/rates?start=2015-07-01T07:00:00-05:00`
This will search for all rates for that day of the week after the start time
* `localhost:3000/rates?end=2015-07-01T12:00:00-05:00`
This will search for all rates for that day of the week before the start time
* `localhost:3000/rates?`
This will search for all rates

#### Response
The GET endpoint is able to return in both plain text and JSON. Just make sure you pass the correct header. So `application/json` for JSON and `text/plain` for text

##### JSON
* `localhost:3000/rates?start=2015-07-01T07:00:00-05:00&end=2015-07-01T12:00:00-05:00`
```
{
    "rates": [
        {
            "days": "wed",
            "times": "0600-1800",
            "tz": "America/Chicago",
            "price": 1750
        }
    ]
}
```
* `localhost:3000/rates?start=2015-07-01T07:00:00-05:00`
```
{
    "rates": [
        {
            "days": "wed",
            "times": "0100-0500",
            "tz": "America/Chicago",
            "price": 1000
        },
        {
            "days": "wed",
            "times": "0600-1800",
            "tz": "America/Chicago",
            "price": 1750
        }
    ]
}
```
* `localhost:3000/rates?end=2015-07-01T12:00:00-05:00`
```
{
    "rates": [
        {
            "days": "wed",
            "times": "0600-1800",
            "tz": "America/Chicago",
            "price": 1750
        }
    ]
}
```
* `localhost:3000/rates?`
```
{
    "rates": [
        {
            "days": "sun,tues",
            "times": "0100-0700",
            "tz": "America/Chicago",
            "price": 925
        },
        {
            "days": "mon,wed,sat",
            "times": "0100-0500",
            "tz": "America/Chicago",
            "price": 1000
        },
        ...
    ]
}
```
* if there are no rates available you will get
```
{
    "rates": []
}
```
 
##### Text
* `localhost:3000/rates?start=2015-07-01T07:00:00-05:00&end=2015-07-01T12:00:00-05:00`
`1750.0`
* `localhost:3000/rates?start=2015-07-01T07:00:00-05:00`
`1000.0,1750.0`
* `localhost:3000/rates?end=2015-07-01T12:00:00-05:00`
`1750.0`
* `localhost:3000/rates?`
`925.0,1000.0,1500.0,1750.0,2000.0`
* if there are no rates available you will get
`Unavailable`

### POST /rates
The post rates endpoint allows for rates to be updated by passing a json file in the following format.
```
{
   "rates":[
      {
         "days":"mon,tues,thurs",
         "times":"0900-2100",
         "tz":"America/Chicago",
         "price":1500
      },
      {
         "days":"fri,sat,sun",
         "times":"0900-2100",
         "tz":"America/Chicago",
         "price":2000
      },
      ...
  ]
}
```

#### Errors
If there was a problem with the file you will get back a 422 status and either one of these json errors.
```
{
    "error": "One or more fields are not valid"
}
```

```
{
    "error": "The structure is incorrect"
}
```


#### Success
If the file that was submitted is correct you will recieve a 201 status and the following body.
```
{
    "error": null
}
```
