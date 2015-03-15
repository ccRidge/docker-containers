# rarflixtools

##### summary:
Dockerized set of supplemental tools for private Roku channel RARflix ( a modified Plex channel )

Docker comand to run:
```
docker run -d --name="rarflixtools" --net="host" -p 32499:32499/tcp -v "/path/to/rarflixtools/config":"/config":rw -v /etc/localtime:/etc/localtime:ro ccridge/rarflixtools
```

##### Description:
RARflixTools is intended to work alongside a plex media server install to supplement the client experience of plex running on the private roku channel RARflix.

Learn more about RARflix and RARflixTools here:
```
https://forums.plex.tv/index.php/topic/91896-rarflixtools-supplemental-tools-for-rarflix/
```
And here:
```
https://github.com/ljunkie/RARflixTools
```
