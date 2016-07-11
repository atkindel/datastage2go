## Datastage2Go

Virtual machine for Stanford OpenEdX data management and analysis software.


### Configuration

`Vagrantfile`: Set `modulestore_location` to equal hostname where modulestore database backups (MongoDB `bson` files) live.

Once loaded:
* `su dataman`
* `cd ~/Code/json_to_relation`

Stanford's weekly refresh cron job is described in `cronDatabaseRefresh.sh`. For testing in the presence of a large set of logfiles, consider using the --pullLimit option on the main load script as follows:

`/home/dataman/Code/json_to_relation/scripts/manageEdxDb.py pullTransformLoad --pullLimit 3`

Optional software that may be helpful can be included in the VM installation by uncommenting portions of the `database_config.sh` provisioning script. Available software utilities include ETL software for edX forum data and Qualtrics surveys, packages for deriving engagement measures and item response theory datasets from tracking logs, and a Web-based GUI for exporting and hosting per-course table CSVs.
