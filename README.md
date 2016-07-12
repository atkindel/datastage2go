## Datastage2Go

Virtual machine for Stanford OpenEdX data management and analysis software.

***

### Configuration

Install Vagrant, Virtualbox, and Ubuntu base box:
* `sudo apt-get install virtualbox`
* Ensure Vagrant version is up-to-date (vagrantup.com)
* `vagrant box add ubuntu/trusty64`

`Vagrantfile`:
* Set `modulestore_location` to equal hostname where modulestore database backups (MongoDB `bson` files) live.
* Add .s3cfg and .boto config files to `~/.ssh` directory
* If needed, make sure that the VM has an SSH key (e.g. `~/.ssh/id_rsa`) for the host where backups live. Scripts presume that the VM can retrieve files using `scp` without a password.

To build the VM and pull data:
* `vagrant up`
* `vagrant ssh`
* `su dataman` (pw: dataman)
* `cd ~/Code/json_to_relation`
* `/home/dataman/Code/json_to_relation/scripts/manageEdxDb.py pullTransformLoad --pullLimit 3`
* `mysql -u dataman -pdataman`

Stanford's weekly refresh cron job is described in `cronDatabaseRefresh.sh`. For testing in the presence of a large set of logfiles, consider using the --pullLimit option on the main load script as described above.

Note that the scripts assume tracking logs, database backups, and modulestore dumps are available in an unencrypted format. The scripts may need to be modified depending on whether data is encrypted on the host.

Optional software that may be helpful can be included in the VM installation by uncommenting portions of the `database_config.sh` provisioning script. Available software utilities include ETL software for edX forum data and Qualtrics surveys, packages for deriving engagement measures and item response theory datasets from tracking logs, and a Web-based GUI for exporting and hosting per-course table CSVs.
