import subprocess
import os
from sqlalchemy import create_engine
import json
import pandas as pd
import asyncio
import nest_asyncio
import uvloop
from geosupport import Geosupport

#using uvloop policy
asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

#enable nested asyncio
nest_asyncio.apply()

#import python-geosupport
g = Geosupport()

async def get_loc(uid, num, street, borough):
    try: 
        geo = g.address(house_number=num, street_name=street, borough_code=borough)
        try:
            sname = geo['BOE Preferred Street Name']
        except:
            sname = ''
        try:
            bbl = geo['BOROUGH BLOCK LOT (BBL)']['BOROUGH BLOCK LOT (BBL)']
        except:
            bbl = ''
        try:
            b_in = geo['Building Identification Number (BIN) of Input Address or NAP']
        except:
            b_in = ''
        try:        
            hnum = list(filter(lambda x: x['Street Name'] == sname, 
                        geo['LIST OF GEOGRAPHIC IDENTIFIERS']))[0]['Low House Number']
        except:
            hnum = ''
        try:
            bcode = geo['BOROUGH BLOCK LOT (BBL)']['Borough Code']
        except:
            bcode = ''
        try:
            cd = geo['COMMUNITY DISTRICT']['COMMUNITY DISTRICT']
        except:
            cd = ''
        try:
            nta = geo['Neighborhood Tabulation Area (NTA)']
        except:
            nta = ''
        try:
            ntan = geo['NTA Name']
        except:
            ntan = ''
        try:
            cblock = geo['2010 Census Tract']
        except:
            cblock = ''
        try:
            csd = geo['Community School District']
        except:
            csd = ''
        try:
            lat = geo['Latitude']
        except:
            lat = ''
        try:
            lon = geo['Longitude']
        except:
            lon = ''
        try: 
            council = geo['City Council District']
        except:
            council = ''
        loc = {'uid' : uid,
                'bbl' : bbl,
                'bin' : b_in,
                'hnum': hnum,
                'sname': sname,
                'bcode': bcode,
                'cd'   : cd,
                'nta'  : nta,
                'ntan' : ntan,
                'cblock': cblock,
                'csd'   : csd,
                'lat' : lat,
                'lon' : lon, 
                'council': council}
        return(loc)
    except:
        loc = {'uid' : '',
                'bbl' : '',
                'bin' : '',
                'hnum': '',
                'sname': '',
                'bcode': '',
                'cd'   : '',
                'nta'  : '',
                'ntan' : '',
                'cblock': '',
                'csd'   : '',
                'lat' : '',
                'lon' : '',
                'council': ''}
        return(loc)


async def bound_get_loc(sem, jobnum, num, street, borough):
    async with sem:
        return await get_loc(jobnum, num, street, borough)

async def run(r):
    #create a empty list of tasks
    tasks = []
    #create instance of Semaphore
    sem = asyncio.Semaphore(100000)
    for i in range(r):
        task = asyncio.ensure_future(bound_get_loc(sem, developments.loc[i,'job_number'],
                                                   developments.loc[i,'address_house'],
                                                   developments.loc[i,'address_street'],
                                                   developments.loc[i,'boro']))
        tasks.append(task)
    responses = await asyncio.gather(*tasks)
    return responses

if __name__ == "__main__":
    # make sure we are at the top of the repo
    wd = subprocess.check_output('git rev-parse --show-toplevel', shell = True)
    os.chdir(wd[:-1]) #-1 removes \n

    # load config file
    with open('developments.config.json') as conf:
        config = json.load(conf)

    DBNAME = config['DBNAME']
    DBUSER = config['DBUSER']
    DBPWD = config['DBPWD']

    # load necessary environment variables
    # set variables with following command: export SECRET_KEY="somesecretvalue"

    # connect to postgres db
    engine = create_engine('postgresql://{}:{}@localhost:5432/{}'.format(DBUSER, DBPWD, DBNAME))

    # read in housing table
    developments = pd.read_sql('SELECT job_number, address_house, address_street, boro\
                                      FROM developments;', engine)

    # replace single quotes with doubled single quotes for psql compatibility 
    developments['address_house'] = developments['address_house'].apply(lambda x: x.replace("'", "''"))
    developments['address_street'] = developments['address_street'].apply(lambda x: x.replace("'", "''"))

    #get the row number
    number = developments.shape[0]

    #start looping through different events
    loop = asyncio.get_event_loop()
    future = asyncio.ensure_future(run(number))
    lst = loop.run_until_complete(future)
    pd.DataFrame(lst).to_csv('developments_build/python/db-development-geocoding.csv', index=False)