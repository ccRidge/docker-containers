# surlatablo

##### summary:
Dockerized surlatablo for querying and converting media from a Tablo device (OTA PVR and streaming) to be used by Plex Media Server

Docker run comand:
```
docker run -d --name="surlatablo" --net="bridge" -v "/path/to/surlatablo/config":"/config":rw -v "/path/to/surlatablo/data":"/data":rw -v "/path/to/surlatablo/transcode":"/transcode":rw -v /etc/localtime:/etc/localtime:ro ccridge/surlatablo
```

##### description:
This docker sets up a daily cron job utilizing SurLaTablo to automate pulling media from a Tablo device based on query criteria configurable by the user.

After running the docker command, there are a couple to-dos:

1.  An example global configuration file is provided, but it will need to be edited for your environment.  Rename the "example_surlatablo.conf" file to just "surlatablo.conf" in your configuration directory, and update with the proper TABLO_IPS and LOCAL_TIMEZONE values.  Those might be the only values to change, but further customization can also take place here if you desire.

2.  An example cron.daily file is provided, but it will also need to be edited for your specific use case.  Rename "example_cpFromTablo" to just "cpFromTablo", then edit for a tablo query behavior of your liking.  The default will convert all files on the tablo with meta data matching a last air date of "Yesterday" or "Today".  Timezone support may not work well outside of the United States and Canada, so your mileage may vary.

Learn more about SurLaTablo [here](http://community.tablotv.com/discussion/1411/surlatablo-py-python-program-to-query-and-convert-tablo-recordings), and [here](http://endlessnow.com/ten/SurLaTablo/).
