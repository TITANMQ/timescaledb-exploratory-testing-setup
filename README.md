This is the setup script for TimescaleDB exploratory testing. 

# Requirements
You will need the following installed:
- [git](https://git-scm.com/downloads)
- Bash (included with git above)
- [Docker](https://www.docker.com/get-started/)


# Getting started
To get up and running, use 
```
./init_timescaledb_docker.sh
```

This will:
- create a TimescaleDB Docker container using the latest image 
    - `timescale-exploration` instance on port `32800`
- create two blank databases from the `./setup.sql`
   - `development` 
   - `production` 

To specify a certain version e.g. `2.13`, you can run
 ```
./init_timescaledb_docker.sh -d {version}
```

To get the connection details, you can run
 ```
./init_timescaledb_docker.sh -i
```

To see all the options (as mentioned above), you can run the help command
```
./setup.sh -?
```