# About Geocoding
The current geocoding process uses geosupport desktop linux and python-geosupport binder to geocode addresses. 

## Important: 
* function ```1A```: the actual information
* function ```1E```: theoretical information
* function ```1B```: a combination of above two. 
* we are running the functions with ```regular+tpad``` as the mode

## Issues: 
* Theoretically, with ```regular+tpad``` switched on, we should expect more addresses to be geocoded, however,
based on observation. when :
    * using function ```1B```, there are fewer hits than using ```1B``` with mode ```regular```
    * using function ```1A```, there are more hits than using ```1A``` with mode ```regular```(which follows expectation)
* to further investigate the discrepencies between different modes and different functions, here are the few strange cases we encountered: 

__same function call with different mode yielded different results__
```
>>> g['1A'](house_number='204-11', street_name='38 ave', borough_code='qn')['Longitude']
'-73.781607'
>>> g['1A'](house_number='204-11', street_name='38 ave', borough_code='qn', mode='regular+tpad')['Longitude']
''
```
## learned knowledge:
* ```1E``` does not return longitude and latitude information (when the mode is ```regular```)
* ```1E``` does not support TPAD switches
* ```1E``` does return longitude and latitude when the mode is ```extended```
