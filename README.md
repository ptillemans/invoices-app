# Invoice Scan Uploader


## Running the container

The application works in 2 phases :

Phase 1 copies the scanned file from the source folder to the target folder and
creates a record in the database for each file copied which is marked as not yet uploaded.

In Phase2 the database is scanned for files which are not yet uploaded anf
uploads them to Jira. When this is successfull the record is marked as uploaded.

The web frontend gives a user friendly view on the actual status. There are 2
roles defined: *admin* and *reader*. An admin can add new users, assign roles
and configure organizations.

### set the environment variables

    $ set SOURCE_DIR=<folder containing the incoming scans>
    $ set TARGET_DIR=<folder with the archived scans and database
    $ set PASSWORD=<the password to log into the jira server>


### start the application

Go to the folder where the file *docker-compose.yml* is located (or copy the
file to somewhere else. you should only need this file).

    $ docker-compose up
    ...
    frontend_1  | [2019-05-13 15:44:23] INFO  WEBrick 1.3.1
    frontend_1  | [2019-05-13 15:44:23] INFO  ruby 2.3.1 (2016-04-26)
    frontend_1  | [2019-05-13 15:44:23] INFO  WEBrick::HTTPServer#start
    worker_1    | /invoices/app/services/jira_interface.rb:29: warning
    worker_1    | /invoices/vendor/bundle/ruby/2.3.0/gems/jira4r-1.3.0

When starting you should see the output of the 2 processes

### test the frontend

Go with a browser to <http://localhost:3000> and login using your account.

## Development

For development in Windows best use the bash shell from Windows Subsystem for Linux.

### Build the docker container

    $ make docker

### Deploy to docker hub

    $ make deploy
